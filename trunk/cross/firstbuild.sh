#!/bin/bash
echo Press enter if you ran this as root
read throwaway

echo Setting up directory structure
svndir=$PWD
mkdir /SollerOS/ || exit 0
cd /SollerOS
mkdir src cross

echo Getting GCC source
cd src
wget http://ftp.gnu.org/gnu/binutils/binutils-2.19.1.tar.bz2 || exit 0
wget http://ftp.gnu.org/gnu/gcc/gcc-4.4.1/gcc-core-4.4.1.tar.bz2 || exit 0
wget ftp://sources.redhat.com/pub/newlib/newlib-1.17.0.tar.gz || exit 0

echo Extracting GCC source
tar xvfz newlib-1.17.0.tar.gz || exit 0
tar xvfj gcc-core-4.4.1.tar.bz2 || exit 0
tar xvfj binutils-2.19.1.tar.bz2 || exit 0

echo Copying SollerOS configuration files
export TARGET=i586-pc-solleros
export PREFIX=/SollerOS/cross
mkdir build-binutils build-newlib build-gcc build-gcc-full
cp -r --remove-destination $svndir/*/ . || exit 0

echo Rebuilding autoconf caches
cd newlib-1.17.0/newlib/libc/sys
autoreconf || exit 0
cd solleros
autoreconf || exit 0

echo Building Binutils
cd ../../../../../build-binutils
../binutils-2.19.1/configure --target=$TARGET --prefix=$PREFIX --disable-nls || exit 0
make all || exit 0
make install || exit 0
export PATH=$PATH:$PREFIX/bin

echo Building GCC
cd ../build-gcc
../gcc-4.4.1/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c --without-headers || exit 0
make all-gcc || exit 0
make install-gcc || exit 0
make all-target-libgcc || exit 0
make install-target-libgcc || exit 0

echo Building Newlib
cd ../build-newlib
../newlib-1.17.0/configure --target=$TARGET --prefix=$PREFIX || exit 0
make || exit 0
make install || exit 0

echo Building GCC with Newlib
cd ../build-gcc-full
../gcc-4.4.1/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c --with-headers || exit 0
make all-gcc || exit 0
make install-gcc || exit 0
make all-target-libgcc
make install-target-libgcc
