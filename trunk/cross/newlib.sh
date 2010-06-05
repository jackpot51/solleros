#!/bin/bash
if [ $UID -ne 0 ] && [ $UID -ne 1000 ]; then
	echo "$0 must be run as root"
	exit 1
fi
svndir=$PWD
cd /SollerOS/src || exit 0
rm -rf build-gcc-full build-newlib || exit 0

#echo Extracting Newlib source
#tar xvfz newlib-1.17.0.tar.gz || exit 0

echo Copying SollerOS configuration files
export TARGET=i586-pc-solleros
export PREFIX=/SollerOS/cross
mkdir build-newlib build-gcc-full
cp -r --remove-destination $svndir/*/ . || exit 0

echo Rebuilding autoconf caches
cd newlib-1.18.0/newlib/libc/sys
autoconf || exit 0
cd solleros
autoreconf || exit 0

export PATH=$PATH:$PREFIX/bin

echo Building Newlib
cd ../../../../../build-newlib
cd build-newlib
../newlib-1.18.0/configure --target=$TARGET --prefix=$PREFIX || exit 0
make || exit 0
make install || exit 0
