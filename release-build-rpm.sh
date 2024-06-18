export BUILD_DIR=$WORKSPACE/rpmbuild
export RELEASE=$BUILD_NUMBER
export CHANGE_INFO_FILE=$WORKSPACE/change-info.txt

for d in "group-based-policy" "group-based-policy-ui" "python-group-based-policy-client" "group-based-policy-automation" ; do
pushd $d
mv ../gbp-packages/$d/rpm .
rpm/build-rpm.sh
echo "*** `basename $PWD` ***" >> $CHANGE_INFO_FILE
git log -n1 >> $CHANGE_INFO_FILE
echo >> $CHANGE_INFO_FILE
popd
done
