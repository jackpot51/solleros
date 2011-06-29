#!/bin/bash
if [ $UID -ne 0 ] && [ $UID -ne 1000 ]; then
	echo "$0 must be run as root"
	exit 1
fi

NEWV=1.19.0
GCCV=4.5.2
BINV=2.21

svndir=$PWD
cd /SollerOS/ || exit 0
rm -rf cross || exit 0
cd src || exit 0
rm -rf */ || exit 0

echo Extracting source
tar xvfz newlib-$NEWV.tar.gz || exit 0
tar xvfj gcc-core-$GCCV.tar.bz2 || exit 0
tar xvfj gcc-g++-$GCCV.tar.bz2 || exit 0
tar xvfj binutils-$BINV.tar.bz2 || exit 0

echo Copying SollerOS configuration files
export TARGET=i586-pc-solleros
export PREFIX=/SollerOS/cross
mkdir build-binutils build-newlib build-gcc
cp -r -f $svndir/binutils-$BINV/* binutils-$BINV/ || exit 0
cp -r -f $svndir/gcc-$GCCV/* gcc-$GCCV/ || exit 0
cp -r -f $svndir/newlib-$NEWV/* newlib-$NEWV/

#echo Rebuilding autoconf caches for g++
cd gcc-$GCCV/libstdc++-v3 || exit 0
#autoconf || exit 0
cd ../../

echo Rebuilding autoconf caches for newlib
cd newlib-$NEWV/newlib/libc/sys || exit 0
autoconf || exit 0
cd solleros || exit 0
autoreconf || exit 0

echo Building Binutils
cd ../../../../../build-binutils
../binutils-$BINV/configure --target=$TARGET --prefix=$PREFIX || exit 0
make || exit 0
make install || exit 0
export PATH=$PATH:$PREFIX/bin

echo Building GCC
cd ../build-gcc
../gcc-$GCCV/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c || exit 0
#,c++ || exit 0
make all-gcc || exit 0
make install-gcc || exit 0

echo Building Newlib
cd ../build-newlib
../newlib-$NEWV/configure --target=$TARGET --prefix=$PREFIX || exit 0
make || exit 0
make install || exit 0

#echo Building G++
#cd ../build-gcc
#make || exit 0
#make install || exit 0
