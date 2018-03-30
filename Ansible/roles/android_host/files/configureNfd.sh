#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: $0 <hostname or IP address of gw to connect to>"
  echo "Example: $0 192.168.26.2"
  exit 0
fi
GW=$1

source ./androidEnv

#echo "ADB: ${ADB}"
# make sure we are booted
while [ "`${ADB} shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do sleep 1; done

#${ADB} root
${ADB} shell "ndnsec key-gen /localhost/operator | ndnsec cert-install -"
${ADB} shell "nfdc face create udp://${GW}"
${ADB} shell "nfdc route add / udp://${GW}"
#${ADB} shell "ndnping -c 3 /ndn/nfd1"
