#!/bin/bash

#source ./androidEnv
#
#echo "about to launch emulator: "
#nohup ${ANDROID_SDK_ROOT}/Android/Sdk/emulator/emulator @Share_Build_64 -selinux permissive  >& /tmp/avd_emulator.log &
#echo "   launched!"


source ./androidEnv

cd ${ANDROID_SDK_ROOT}/Android/Sdk/emulator
#nohup ./emulator @Share_Build_64 -selinux permissive  >& /tmp/avd_emulator.log &
nohup ./emulator @Share_Build_64 -selinux permissive  &
#sleep 2
while [ "`$ADB shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do sleep 1; done


