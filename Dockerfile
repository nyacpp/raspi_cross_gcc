# https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
# https://solarianprogrammer.com/2018/05/06/building-gcc-cross-compiler-raspberry-pi/

FROM debian:bullseye AS deps

# Install some tools and compilers + clean up
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y bzip2 cmake git g++ python3 sudo wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add `pi` user and allow it sudo without password
RUN useradd -ms /bin/bash pi
RUN echo "pi:pi" | chpasswd
RUN echo "pi ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# BUILD
FROM deps AS build

# Download binutils
ENV BINUTILS_VERSION binutils-2.35.2
WORKDIR /home/pi
RUN wget https://ftp.gnu.org/gnu/binutils/${BINUTILS_VERSION}.tar.bz2 && \
    tar xjf ${BINUTILS_VERSION}.tar.bz2 && rm ${BINUTILS_VERSION}.tar.bz2

# Download gcc
ENV GCC_VERSION gcc-10.2.0
WORKDIR /home/pi
RUN wget https://ftp.gnu.org/gnu/gcc/${GCC_VERSION}/${GCC_VERSION}.tar.gz && \
    tar xf ${GCC_VERSION}.tar.gz && rm ${GCC_VERSION}.tar.gz
RUN cd ${GCC_VERSION} && contrib/download_prerequisites && rm *.tar.*

# Compilation arguments: https://gcc.gnu.org/install/configure.html
#
# --target shows that it is cross compilation
# --with-gcc-major-version-only makes path look similar to raspi: 10/ instead of 10.2.0/
# --with-arch --with-fpu --with-float are properties of RasPi Zero [W]
# --disable-multilib to build only one architecture
# --enable-multiarch provides arm-linux-gnueabihf subdirectories
# --prefix is compiler installation path
# --with-sysroot option is needed later for cmake to test the compiler without flags
#
ARG CONFIG_ARGS="--target=arm-linux-gnueabihf --with-gcc-major-version-only --with-arch=armv6 --with-fpu=vfp --with-float=hard --disable-multilib --enable-multiarch --prefix=/cross --with-sysroot=/raspi"

RUN mkdir -p /cross

# Build binutils
WORKDIR /home/pi/${BINUTILS_VERSION}/build
RUN ../configure ${CONFIG_ARGS}
RUN make -j$(nproc)
RUN make install

# Build gcc
WORKDIR /home/pi/${GCC_VERSION}/build
RUN mkdir -p /raspi/usr/include && touch /raspi/usr/include/stdc-predef.h  # https://wiki.debian.org/toolchain/BootstrapIssues#stdc-predef.h_not_found
RUN ../configure ${CONFIG_ARGS} --enable-languages=c,c++
RUN make -j$(nproc) all-gcc LIMITS_H_TEST=true
RUN make install-gcc

# RESULT
# Multistage build removes few GB from the image.
FROM deps

COPY --from=build /cross /cross
ENV PATH=/cross/bin:${PATH}

USER pi
COPY --chown=pi:pi toolchain.cmake /home/pi/
WORKDIR /home/pi/
