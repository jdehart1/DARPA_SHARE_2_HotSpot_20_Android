#!/bin/bash

nfd-stop
sleep 5

nfd-start >& /dev/null
sleep 5

