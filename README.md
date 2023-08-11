# Cross-Compiler for RasPi Zero [W]

Supports RasPi OS based on `debian:bullseye` with RasPi Zero / Zero W machine, though probably can be modified for other configurations. The default GCC version is `10.2`.

## Build
Check version of your binutils and compiler with
```
ld -v
gcc -v
```

Set the versions with docker environment variables `BINUTILS_VERSION` and `GCC_VERSION`, but note that some  of them may not exist on ftp server, so try to fit at least Major and Minor versions.

Build the docker image
```
docker build -t nyacpp/raspi_cross_gcc .
```

The build time depends on your PC, but should be around 15 minutes.

## Test
Make sure gcc is installed on RasPi:
```
sudo apt install g++
```

Then on your PC, copy libraries from RasPi:
```
rsync -rlu --del --copy-unsafe-links --info=progress2 pi@<rpi>:/{lib,usr} ~/raspi
```

It takes around half an hour for clean system.

Build test application in the docker:
```
docker run -it --name test \
 -v $PWD/test:/home/pi/test \
 -v ~/raspi:/raspi \
 -v ~/raspi/usr/lib/gcc:/cross/lib/gcc \
 nyacpp/raspi_cross_gcc \
 make -C test
```

Then you can check the resulting file: 
```
file test/build/a
```

## Notes
The gcc/g++ cross-compiler can be used to speed up build significantly (e.g. hours instead of days).

The default `gcc-arm-linux-gnueabihf` package is not suitable, because it targets ARMv7 cpu, while RasPi Zero is ARMv6.

Also even though both are `hf` (hard float operations), the RasPi Zero cpu is `VFP2`, while ARMv7 is `VFP3` (Vector Floating Point).

The build of `libC` and `gccLib` is not needed, because the libraries already exist on RasPi machine, so it better to use native ones (also it's quite hard to cross compile those libraries with gcc-10). 

The configuration option `--prefix` in Dockerfile specifies compiler installation path. The path can be changed later with `gcc -B` option or `GCC_EXEC_PREFIX` environment variable. But unfortunately it influences all paths together, like `ld`, `.o`, `.so`, thus probably not suitable for cross compilation.

Instead of changing prefix, the needed object files and libraries are mounted into compiler specific directory. You can notice in the test above, `/cross/lib/gcc` directory was mounted for this purpose.

The `gcc --sysroot` option is not related to the above and used to search additional stuff like `crt1.o`.
