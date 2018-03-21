#!/bin/bash
if [ $# -eq 1 ]
then
  route add -net 192.168.0.0/16 gw $1
fi
