#!/bin/sh
STASHED=0
VERSION="dev_version"
if [ "$1" != "" ]; then 
  VERSION=$1
#  perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/days_progress.scm
fi


csc -static days_progress.scm 
echo "Version: $VERSION"
version_dir="days_progress_$VERSION"
rm -rf $version_dir
mkdir $version_dir
cp days_progress $version_dir/
tar -czf $version_dir.tgz $version_dir
rm -rf $version_dir

echo "here's your SHA for homebrew"
shasum -a 256 $version_dir.tgz

echo "Examining binary for dylib requirements..."
# copy all the optional ones
# rm -rf dylibs/*
DYLIBS=`otool -L days_progress | grep "/opt" | awk -F' ' '{ print $1 }'`
for dylib in $DYLIBS
do 
  echo " - dylib $dylib"
  # base=$(basename $dylib)
  # cp $dylib dylibs/
  # install_name_tool -change $dylib "~/lib/$(basename $dylib)" oho
done

echo "Done."
