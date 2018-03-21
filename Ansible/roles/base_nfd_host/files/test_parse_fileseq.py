#! /usr/bin/python

import string
import sys
import math

logfile = open(sys.argv[1], 'r')

seqnos = []
duplicates = []
for line in logfile:
    if line.find("FileSync") != -1 and line.find("processReceiveData") != -1:
        if line.find("duplicate") != -1:
            print line
            seqno = line.split()[8].strip('()')
            print seqno
            duplicates.append(seqno)
        if line.find("data msg") != -1:
            #print line
            seqno = line.split()[7].strip('msg()')
            #print seqno
            seqnos.append(seqno)
        if line.find(" file (") != -1:
            #print line
            seqno = line.split()[8].strip('()')
            #print seqno
            seqnos.append(seqno)
            
seqnos.sort(key=int)
duplicates.sort(key=int)

last_seen = 1 #sorted_seq[0:0]
missing_seq = []
#print seqnos
for seq in seqnos:
    #print seq + " " + repr(last_seen)
    while int(seq) > last_seen:
        missing_seq.append(last_seen)
        print seq + " " + repr(last_seen)
        last_seen = int(last_seen) + 1
    last_seen = int(last_seen) + 1

        
print "max seq:" + repr(int(last_seen) - 1)
print "missing seq:" + repr(missing_seq)
print "duplicates:" + repr(duplicates)
