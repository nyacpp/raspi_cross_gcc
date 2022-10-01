set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_LIBRARY_ARCHITECTURE arm-linux-gnueabihf)
set(CMAKE_CROSSCOMPILING_EMULATOR /usr/bin/qemu-arm-static)
set(CMAKE_C_COMPILER /cross/bin/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER /cross/bin/arm-linux-gnueabihf-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_SYSROOT /raspi CACHE PATH "")

set(c_include_directories
		${CMAKE_SYSROOT}usr/include/arm-linux-gnueabihf
		${CMAKE_SYSROOT}/usr/include
)
set(cxx_include_directories
		${CMAKE_SYSROOT}/usr/include/arm-linux-gnueabihf/c++/10
		${CMAKE_SYSROOT}/usr/include/c++/10
		${c_include_directories}
)
list(APPEND CMAKE_C_STANDARD_INCLUDE_DIRECTORIES ${c_include_directories})
list(APPEND CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${cxx_include_directories})

set(linker_flags
		-L${CMAKE_SYSROOT}/usr/lib
		-L${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf
		-L${CMAKE_SYSROOT}/usr/lib/gcc/arm-linux-gnueabihf/10
		-Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib
		-Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf
		-Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/gcc/arm-linux-gnueabihf/10
)
string (REPLACE ";" " " linker_flags_string "${linker_flags}")

string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${linker_flags_string}")
string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${linker_flags_string}")
