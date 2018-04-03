#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: $0 <directory where launch_share.sh exists"
  echo "Example: $0 roles/launchAndroid/files"
  exit 0
else
  cd $1
fi

source ~/.topology
source ../../../Hosts

CWD=`pwd`

HOSTS="$ANDROID_HOSTS1 $ANDROID_HOSTS2"

for h in $HOSTS
do
  HH=${!h}
  echo "Launch AVD on $h: (${!HH})"
  ##ssh -Y $HH "cd $CWD; ./resizeAvd.sh SMALL ; ./launch_share.sh"   
  ssh -Y ${!HH} "cd $CWD; ./launch_share.sh"    &
  #sleep 20
  #sleep 10
  sleep 5
  #sleep 2
done
