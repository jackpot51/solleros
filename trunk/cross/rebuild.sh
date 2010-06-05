#!/bin/bash
if [ $UID -ne 0 ] && [ $UID -ne 1000 ]; then
	echo "$0 must be run as root"
	exit 1
fi
svndir=$PWD
cd /SollerOS/ || exit 0
rm -rf cross || exit 0
cd src || exit 0
rm -rf */ || exit 0

echo Extracting source
tar xvfz newlib-1.18.0.tar.gz || exit 0
tar xvfj gcc-core-4.4.2.tar.bz2 || exit 0
tar xvfj gcc-g++-4.4.2.tar.bz2 || exit 0
tar xvfj binutils-2.20.tar.bz2 || exit 0

echo Copying SollerOS configuration files
export TARGET=i586-pc-solleros
export PREFIX=/SollerOS/cross
mkdir build-binutils build-newlib build-gcc build-gcc-full build-ncurses
cp -r --remove-destination $svndir/*/ . || exit 0

echo Rebuilding autoconf caches for g++
cd gcc-4.4.2/libstdc++-v3 || exit 0
autoconf-2.59 || exit 0
cd ../../

echo Rebuilding autoconf caches for newlib
cd newlib-1.18.0/newlib/libc/sys || exit 0
autoconf || exit 0
cd solleros || exit 0
autoreconf || exit 0

echo Building Binutils
cd ../../../../../build-binutils
../binutils-2.20/configure --target=$TARGET --prefix=$PREFIX --disable-nls || exit 0
make all || exit 0
make install || exit 0
export PATH=$PREFIX/bin:$PATH

echo Building GCC
cd ../build-gcc
../gcc-4.4.2/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers || exit 0
make all-gcc || exit 0
make install-gcc || exit 0

echo Building Newlib
cd ../build-newlib
../newlib-1.18.0/configure --target=$TARGET --prefix=$PREFIX || exit 0
make || exit 0
make install || exit 0

echo Building GCC with Newlib
cd ../build-gcc-full
../gcc-4.4.2/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --with-headers || exit 0
make all-gcc || exit 0
make install-gcc || exit 0
make all-target-libgcc || exit 0
make install-target-libgcc || exit 0

echo Building G++
make || exit 0
make install || exit 0
