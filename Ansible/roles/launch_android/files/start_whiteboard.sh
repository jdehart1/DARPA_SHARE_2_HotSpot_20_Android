#!/bin/bash

#source ./androidEnv
#
#echo "about to launch emulator: "
#nohup ${ANDROID_SDK_ROOT}/Android/Sdk/emulator/emulator @Share_Build_64 -selinux permissive  >& /tmp/avd_emulator.log &
#echo "   launched!"


source ./androidEnv

while [ "`$ADB shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do sleep 1; done

#cd ${ANDROID_SDK_ROOT}/Android/Sdk/platform-tools
${ADB} shell am start-activity net.named_data.android.whiteboard/edu.ucla.cs.ndnwhiteboard.IntroActivity

