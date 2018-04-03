#!/bin/bash

if [ $# -ne 2 ]
then
  echo "Usage: $0 <VM Password> <# of HotSpots>"
  echo "Example: $0 xyzqr 4"
  echo "  would configure Ansible for a 4 Hotspot demo with user VM password xyzqr"
  exit 
else
  pw=$1
  numHotspots=$2
fi

source ~/.topology
if [ $numHotspots -eq 4 ]
then
  source ./Hosts_4
elif [ $numHotspots -eq 8 ]
then
  source ./Hosts_8
else
  source ./Hosts
fi

ANDROID_HOSTS=""
NFD_HOSTS=""
HOSTS=""
i=1
while [ $i -le $numHotspots ]
do
  AH=ANDROID_HOSTS${i}
  AAH=$AH
  ANDROID_HOSTS="$ANDROID_HOSTS ${!AAH} "
  NH=NFD_HOSTS${i}
  NNH=$NH
  NFD_HOSTS="$NFD_HOSTS ${!NNH} "
  i=$(($i+1))
done
HOSTS="$PDN_HOSTS $SERVER_HOSTS $ANDROID_HOSTS $NFD_HOSTS"

echo $HOSTS
#

echo "# Hosts list:" > ./DemoInventory
ANSIBLE_HOSTS_FILE=./roles/base_host/files/ansible_hosts_file
ANSIBLE_HOSTS_FILE2=./roles/android_base_host/files/ansible_hosts_file
echo "#ANSIBLE Maintained part of hosts file" > $ANSIBLE_HOSTS_FILE
for h in $HOSTS
do
  # h is of the form M1_host, we will use M1 as Name of entity
  #NAME=`echo $h | cut -d '_' -f 1`
  NAME=`echo $h | sed 's/_host//'`
  # the M1_host env variable is defined as h1x2 which we assign to HH
  HH=${!h}
  # hostnames like h1x2 are known to yp, get the address associated with it
  IPADDR=`ypcat hosts | grep "${HH}\$" | cut -d ' ' -f 1`
  #echo "h: $h HH: $HH"
  URI="udp4://${HH}"
  # all hosts/entities in ONL topology are of the form h#x2 with default route of h#x1
  IPROUTE1=`echo $IPADDR | cut -d '.' -f1,2,3`
  IPROUTE="$IPROUTE1"".1"
  IPROUTE_HOST1=`echo ${HH} | cut -d 'x' -f 1`
  IPROUTE_HOST="$IPROUTE_HOST1""x1"
  # now build Ansible host_vars file 
  echo "---" > ./host_vars/$h
  echo "default_prefix: /darpa/$NAME" >> ./host_vars/$h
  echo "device_name: $NAME" >> ./host_vars/$h
  echo "host_IP_Address: $IPADDR" >> ./host_vars/$h
  echo "host_URI: $URI" >> ./host_vars/$h
  echo "default_IP_route: $IPROUTE" >> ./host_vars/$h
  echo "server_host: $Server_host" >> ./host_vars/$h
  echo "ansible_host: ${!HH}" >> ./host_vars/$h
  echo "ansible_user: ${USER}" >> ./host_vars/$h
  echo "ansible_ssh_pass: ${pw}" >> ./host_vars/$h
  echo "ansible_sudo_pass: ${pw}" >> ./host_vars/$h
  # add this host to the ansibleHosts file for inclusion in /etc/hosts
  #echo "127.0.0.1 ${!HH}" >> $ANSIBLE_HOSTS_FILE
  echo "$IPROUTE $IPROUTE_HOST" >> $ANSIBLE_HOSTS_FILE
  echo "$IPADDR ${HH}" >> $ANSIBLE_HOSTS_FILE
done
cp $ANSIBLE_HOSTS_FILE $ANSIBLE_HOSTS_FILE2

for i in `seq 1 $numHotspots`;
do
  AH=ANDROID_HOSTS${i}
  AAH=$AH
  NH=NFD_HOSTS${i}
  NNH=${!NH}
  NNNH=${!NNH}
  NFD_HOST_IP_ADDR=`ypcat hosts | grep "${NNNH}\$" | cut -d ' ' -f 1`

  # add to the host_vars files for nfd_host, sync and data neighbors
  for ah in ${!AAH}
  do
    echo "nfd_host: $NFD_HOST_IP_ADDR" >> ./host_vars/$ah
    # User hosts have faces to all other User hosts on same HS and to PDN
    # these faces will be used for both sync and data
    SYNC_NEIGHBORS=""
    DATA_NEIGHBORS=""
    first=1
    for neighbor in ${!AAH}
    do
      if [ "$neighbor" != "$ah" ]
      then
        if [  $first -ne 1 ]
        then
          SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
          DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
        else
          first=0
          SYNC_NEIGHBORS="$neighbor"
          DATA_NEIGHBORS="$neighbor"
        fi
      fi
    done
    for neighbor in ${!NH}
    do
        if [ $first -ne 1 ]
        then
          SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
          DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
        else
          first=0
          SYNC_NEIGHBORS="$neighbor"
          DATA_NEIGHBORS="$neighbor"
        fi
    done
    echo "sync_neighbors: [${SYNC_NEIGHBORS}]" >> ./host_vars/$ah
    echo "data_neighbors: [${DATA_NEIGHBORS}]" >> ./host_vars/$ah
  done
  
  for nh in ${!NH}
  do
    # NFD hosts have faces to all User hosts and to PDN
    SYNC_NEIGHBORS=""
    DATA_NEIGHBORS=""
    first=1
    for neighbor in $PDN_HOSTS
    do
        if [ $first -ne 1 ]
        then
          SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
          DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
        else
          first=0
          SYNC_NEIGHBORS="$neighbor"
          DATA_NEIGHBORS="$neighbor"
        fi
    done
    for neighbor in ${!AAH}
    do
      if [  $first -ne 1 ]
      then
        SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
        DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
      else
        first=0
        SYNC_NEIGHBORS="$neighbor"
        DATA_NEIGHBORS="$neighbor"
      fi
    done
    echo "sync_neighbors: [${SYNC_NEIGHBORS}]" >> ./host_vars/$nh
    echo "data_neighbors: [${DATA_NEIGHBORS}]" >> ./host_vars/$nh
  done
done

for ph in $PDN_HOSTS
do
  # PDN hosts have faces to all User hosts and to Server
  # Server face will be used for both sync and data
  # User faces will be used for just sync 
  SYNC_NEIGHBORS=""
  DATA_NEIGHBORS=""
  first=1
  for neighbor in $SERVER_HOSTS
  do
      if [ $first -ne 1 ]
      then
        SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
        DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
      else
        first=0
        SYNC_NEIGHBORS="$neighbor"
        DATA_NEIGHBORS="$neighbor"
      fi
  done
  for neighbor in $NFD_HOSTS
  do
      if [ $first -ne 1 ]
      then
        SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
        DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
      else
        first=0
        SYNC_NEIGHBORS="$neighbor"
        DATA_NEIGHBORS="$neighbor"
      fi
  done
  #for neighbor in $ANDROID_HOSTS 
  #do
  #  if [ "$neighbor" != "$ph" ]
  #  then
  #    if [  $first -ne 1 ]
  #    then
  #      SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
  #    else
  #      first=0
  #      SYNC_NEIGHBORS="$neighbor"
  #    fi
  #  fi
  #done
  echo "sync_neighbors: [${SYNC_NEIGHBORS}]" >> ./host_vars/$ph
  echo "data_neighbors: [${DATA_NEIGHBORS}]" >> ./host_vars/$ph
done

for sh in $SERVER_HOSTS
do
  # SERVER hosts have faces to the PDN hosts
  # PDN faces will be used for both sync and data
  SYNC_NEIGHBORS=""
  DATA_NEIGHBORS=""
  first=1
  for neighbor in $PDN_HOSTS
  do
      if [ $first -ne 1 ]
      then
        SYNC_NEIGHBORS="$SYNC_NEIGHBORS,$neighbor"
        DATA_NEIGHBORS="$DATA_NEIGHBORS,$neighbor"
      else
        first=0
        SYNC_NEIGHBORS="$neighbor"
        DATA_NEIGHBORS="$neighbor"
      fi
  done
  echo "sync_neighbors: [${SYNC_NEIGHBORS}]" >> ./host_vars/$sh
  echo "data_neighbors: [${DATA_NEIGHBORS}]" >> ./host_vars/$sh
done

echo "[android_hosts]" >> ./DemoInventory
for ah in $ANDROID_HOSTS
do
  echo "$ah" >> ./DemoInventory
done

echo "[pdn_hosts]" >> ./DemoInventory
for ph in $PDN_HOSTS
do
  echo "$ph" >> ./DemoInventory
done

echo "[server_hosts]" >> ./DemoInventory
for sh in $SERVER_HOSTS
do
  echo "$sh" >> ./DemoInventory
done

echo "[hs_nfd_hosts]" >> ./DemoInventory
for nh in $NFD_HOSTS
do
  echo "$nh" >> ./DemoInventory
done

ORGANIZATION_PREFIX="/darpa"
AUTHORITY_NAME="auth"
DATA_NAME="tacdata"

echo "[all:vars]" >> ./DemoInventory
echo "ndnNetwork=/darpa" >> ./DemoInventory
#echo "hyperbolic_state=on" >> ./DemoInventory
echo "tcp_port=6363" >> ./DemoInventory
echo "udp_port=6363" >> ./DemoInventory
echo "multicast_port=56363" >> ./DemoInventory
echo "organization_prefix=$ORGANIZATION_PREFIX" >> ./DemoInventory
echo "authority_name=$AUTHORITY_NAME" >> ./DemoInventory
echo "data_name=$DATA_NAME" >> ./DemoInventory
echo "" >> ./DemoInventory


# Create the self-signed Authority Certificate
CWD=`pwd`
CERTIFICATE_DIR=${CWD}/roles/certificates/files/certs
mkdir -p $CERTIFICATE_DIR
export HOME=./roles/certificates/files
ndnsec-key-gen -t r ${ORGANIZATION_PREFIX}/${AUTHORITY_NAME} > $HOME/certs/$AUTHORITY_NAME.cert

