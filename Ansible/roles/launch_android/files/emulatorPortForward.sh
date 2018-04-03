#!/bin/bash
#> echo "auth Yy71NKonI3J8IQcB";

EMULATOR_AUTH_TOKEN_FILE=$1
AUTH_TOKEN=`cat ${EMULATOR_AUTH_TOKEN_FILE}`
(
echo "auth $AUTH_TOKEN";
sleep 1;
echo "redir add udp:6364:6363";
sleep 1;
echo "quit";
) | telnet localhost 5554
exit 0
