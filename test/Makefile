.ONESHELL:

all:
	rm -rf build
	mkdir -p build && cd build
	cmake .. -DCMAKE_TOOLCHAIN_FILE=/cross/cmake/toolchain.cmake
	make
