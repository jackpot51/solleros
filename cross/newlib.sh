#!/bin/bash
if [ $UID -ne 0 ] && [ $UID -ne 1000 ]; then
	echo "$0 must be run as root"
	exit 1
fi

NEWV=1.19.0

svndir=$PWD
cd /SollerOS/src || exit 0
rm -rf build-newlib || exit 0

echo Copying SollerOS configuration files
export TARGET=i586-pc-solleros
export PREFIX=/SollerOS/cross
mkdir build-newlib
cp -r -f $svndir/newlib-$NEWV/* newlib-$NEWV/ || exit 0

echo Rebuilding autoconf caches
cd newlib-$NEWV/newlib/libc/sys
autoconf || exit 0
cd solleros
autoreconf || exit 0

export PATH=$PATH:$PREFIX/bin

echo Building Newlib
cd ../../../../../build-newlib
cd build-newlib
../newlib-$NEWV/configure --target=$TARGET --prefix=$PREFIX || exit 0
make || exit 0
make install || exit 0
