#!/bin/bash
if [ $UID -ne 0 ] && [ $UID -ne 1000 ]; then
	echo "$0 must be run as root"
	exit 1
fi
echo Setting up directory structure
svndir=$PWD
mkdir /SollerOS/
cd /SollerOS || exit 0
mkdir src cross

echo Getting source
cd src || exit 0
wget http://ftp.gnu.org/gnu/binutils/binutils-2.20.tar.bz2 || exit 0
wget http://ftp.gnu.org/pub/gnu/gcc/gcc-4.4.2/gcc-core-4.4.2.tar.bz2 || exit 0
wget http://ftp.gnu.org/pub/gnu/gcc/gcc-4.4.2/gcc-g++-4.4.2.tar.bz2 || exit 0
wget ftp://sources.redhat.com/pub/newlib/newlib-1.17.0.tar.gz || exit 0
wget http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.7.tar.gz || exit 0

cd $svndir
./rebuild.sh
