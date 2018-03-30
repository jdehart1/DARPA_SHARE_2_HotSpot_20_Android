#!/bin/bash


source ~/.topology
source ../../../Hosts

CWD=`pwd`

HOSTS="$ANDROID_HOSTS1 $ANDROID_HOSTS2"

for h in $HOSTS
do
  HH=${!h}
  echo "Launch AVD on $h: (${!HH})"
  ssh -Y ${!HH} "cd $CWD; ./start_whiteboard.sh"    &
  #sleep 20
  sleep 2
done
