#! /bin/bash

#
# Script for Clone Device Trees
#
#

# Clone Device Trees
cd $ROM
mv /tmp/cirrus-ci-build/$TARGET.json /tmp/cirrus-ci-build/$ROM/$TARGET.json
ls
count=$(jq length $TARGET.json)
for ((i=0;i<${count};i++));
do
   repo_url=$(jq -r --argjson i $[i] '.[$i].url' $TARGET.json)
   echo $repo_url
   branch=$(jq -r --argjson i $[i] '.[$i].branch' $TARGET.json)
   echo $branch
   target=$(jq -r --argjson i $[i] '.[$i].target_path' $TARGET.json)
   echo $target
   rm -rf $target
   if [ ! -d $target ]; then
       crlstatus=$(curl -s -m 5 -IL ${repo_url}|grep 200)
       echo $crlstatus
       if [[ -z "${crlstatus}" ]]; then
           echo "使用Manifest分支"
           git clone -b $BRANCH ${repo_url} ${target} --depth=1
       else
           echo "使用默认分支"
           git clone -b ${branch} ${repo_url} ${target} --depth=1
       fi
   fi
   ls ${target}
done
