#!/bin/bash


source ~/.topology
source ../../../Hosts

CWD=`pwd`

HOSTS="$ANDROID_HOSTS1 "

NFD1="NFD1_host"
NFD2="NFD2_host"
N1=${!NFD1}
N2=${!NFD2}
N1_IPADDR=`ypcat hosts | grep "${N1}\$" | cut -d ' ' -f 1`
N2_IPADDR=`ypcat hosts | grep "${N2}\$" | cut -d ' ' -f 1`
echo "NFD1: $NFD1 N1: $N1 N1_IPADDR: $N1_IPADDR"

for h in $HOSTS
do
  HH=${!h}
  echo "Launch AVD on $h: (${!HH})"
  ssh -Y ${!HH} "cd $CWD; ./configureNfd.sh ${N1_IPADDR}"    &
  #sleep 20
  sleep 2
exit
done

HOSTS="$ANDROID_HOSTS2"

for h in $HOSTS
do
  HH=${!h}
  echo "Launch AVD on $h: (${!HH})"
  ssh -Y ${!HH} "cd $CWD; ./start_whiteboard.sh ${N2_IPADDR}"    &
  #sleep 20
  sleep 2
done
