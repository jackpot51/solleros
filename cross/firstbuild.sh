#!/bin/bash
if [ $UID -ne 0 ] && [ $UID -ne 1000 ]; then
	echo "$0 must be run as root"
	exit 1
fi

NEWV=1.19.0
GCCV=4.5.2
BINV=2.21

echo Setting up directory structure
svndir=$PWD
mkdir /SollerOS/
cd /SollerOS || exit 0
mkdir src cross

echo Getting source
cd src || exit 0
wget -c ftp://ftp.gnu.org/pub/gnu/binutils/binutils-$BINV.tar.bz2 || exit 0
wget -c http://ftp.gnu.org/pub/gnu/gcc/gcc-$GCCV/gcc-core-$GCCV.tar.bz2 || exit 0
wget -c ftp://ftp.gnu.org/pub/gnu/gcc/gcc-$GCCV/gcc-g++-$GCCV.tar.bz2 || exit 0
wget -c ftp://sources.redhat.com/pub/newlib/newlib-$NEWV.tar.gz || exit 0

cd $svndir
./rebuild.sh
