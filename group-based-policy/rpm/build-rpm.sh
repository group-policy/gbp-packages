#!/bin/bash
# Should be run from the root of the source tree

if [ ! -d rpm ]; then
   echo "Directory 'rpm' not found"
   exit 1
fi
SPEC_FILE_IN=`ls rpm/*.spec.in`
if [ -z $SPEC_FILE_IN ]; then
   echo "RPM spec file not found"
   exit 1
fi
BUILD_DIR=${BUILD_DIR:-`pwd`/rpmbuild}
mkdir -p $BUILD_DIR/BUILD $BUILD_DIR/SOURCES $BUILD_DIR/SPECS $BUILD_DIR/RPMS $BUILD_DIR/SRPMS
NAME=`python2 setup.py --name`
RELEASE=${RELEASE:-1}
VERSION_PY=`python2 setup.py --version`
VERSION=`echo $VERSION_PY | sed -nre 's,([^\.]+.[^\.]+.[^\.]+)((\.)(0[^\.]+))?((\.)(dev.*))?,\1 \4 \7,p' | sed -re 's/ *$//g' | sed -re 's/ +/~/g'`
SPEC_FILE=${SPEC_FILE_IN/.in/}
SPEC_FILE=${SPEC_FILE/rpm\//}
sed -e "s/@VERSION@/$VERSION/" \
    -e "s/@VERSION_PY@/$VERSION_PY/" \
    -e "s/@RELEASE@/$RELEASE/" \
    $SPEC_FILE_IN > $BUILD_DIR/SPECS/$SPEC_FILE
python2 setup.py sdist --dist-dir $BUILD_DIR/SOURCES
mv $BUILD_DIR/SOURCES/$NAME-$VERSION_PY.tar.gz $BUILD_DIR/SOURCES/$NAME-$VERSION.tar.gz
cp rpm/*.patch $BUILD_DIR/SOURCES
rpmbuild --clean -ba --define "_topdir $BUILD_DIR" $BUILD_DIR/SPECS/$SPEC_FILE

# Save the python2 packages
cp rpmbuild/RPMS/noarch/*.rpm .
cp rpmbuild/SRPMS/*.rpm .
rm -rf rpmbuild

# Prepare build scripts for python3
cp $SPEC_FILE_IN .

sed -i "s/python2/python3/g" $SPEC_FILE_IN
sed -i "s/Name:           %{srcname}/Name:           python3-%{srcname}/g" $SPEC_FILE_IN

BUILD_DIR=${BUILD_DIR:-`pwd`/rpmbuild}
mkdir -p $BUILD_DIR/BUILD $BUILD_DIR/SOURCES $BUILD_DIR/SPECS $BUILD_DIR/RPMS $BUILD_DIR/SRPMS
NAME=`python3 setup.py --name`
RELEASE=${RELEASE:-1}
VERSION_PY=`python3 setup.py --version`
VERSION=`echo $VERSION_PY | sed -nre 's,([^\.]+.[^\.]+.[^\.]+)((\.)(0[^\.]+))?((\.)(dev.*))?,\1 \4 \7,p' | sed -re 's/ *$//g' | sed -re 's/ +/~/g'`
SPEC_FILE=${SPEC_FILE_IN/.in/}
SPEC_FILE=${SPEC_FILE/rpm\//}
sed -e "s/@VERSION@/$VERSION/" \
    -e "s/@VERSION_PY@/$VERSION_PY/" \
    -e "s/@RELEASE@/$RELEASE/" \
    $SPEC_FILE_IN > $BUILD_DIR/SPECS/$SPEC_FILE
python3 setup.py sdist --dist-dir $BUILD_DIR/SOURCES
mv $BUILD_DIR/SOURCES/$NAME-$VERSION_PY.tar.gz $BUILD_DIR/SOURCES/$NAME-$VERSION.tar.gz
cp rpm/*.patch $BUILD_DIR/SOURCES
rpmbuild --clean -ba --define "_topdir $BUILD_DIR" $BUILD_DIR/SPECS/$SPEC_FILE

# restore the python2 packages
mv *.src.rpm rpmbuild/SRPMS/
mv *.noarch.rpm rpmbuild/RPMS/noarch/

# Restore the spec file
mv *.spec.in $SPEC_FILE_IN
