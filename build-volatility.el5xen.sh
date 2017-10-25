#!/bin/bash
#
# Ponzu lime & volatilty build script
# Dannen Harris 2017 v. 2.0

OSVER=el5
ARCH=x86_64
KVER2=$1.${OSVER}xen
KVER1=$1.${OSVER}.noarch
KVER=$1.${OSVER}.${ARCH}

export KVER
export KVER1
export KVER2

#echo ${KVER}
#echo ${KVER1}
#echo ${KVER2}

# import KVER into bash environment
# this is used to override the default value in LiME build
if [[ ! -z "${KVER}" ]]; then
echo "export KVER=${KVER}" >> /tmp/.bashrc
source /tmp/.bashrc;
else
  exit 0
fi

#echo ${KVER}
#ls -1 /rpms/kernel-${KVER}.rpm
#exit 0
# look for local copies of rpms and install from vault if missing
if [ ! -f "/rpms/kernel-${KVER}.rpm" ]; then
  echo "No local rpms found, pulling from vault..."
  yum -y -q -e 0 install kernel-xen-${KVER} kernel-xen-devel-${KVER} kernel-headers-${KVER}
else
  echo "Local rpms found, installing..."
  yum install -y --nogpgcheck /rpms/kernel-xen-${KVER}.rpm /rpms/kernel-xen-devel-${KVER}.rpm /rpms/kernel-headers-${KVER}.rpm
  rpm -qa | grep kernel | sort
  #yum install -y -q -e 0 /rpms/kernel-${KVER}.rpm /rpms/kernel-devel-${KVER}.rpm /rpms/kernel-headers-${KVER1}.rpm
fi

# resource .bashrc
echo "export KVER=${KVER2}" >> /tmp/.bashrc
source /tmp/.bashrc;

# build basic volatility paths
mkdir -p /lime-module/${KVER}/boot/
mkdir -p /lime-module/${KVER}/volatility/tools/linux/

# build lime kernel module
cd /LiME/src
echo ""
echo ""
echo "Building lime module..."
#ls -1 /lib/modules
make > /tmp/log-file 2>&1
cp -v lime-${KVER}.ko /lime-module/${KVER}/
cp -v /boot/System.map-${KVER} /lime-module/${KVER}/boot/
# make clean

# build dwarfdump module
cd /volatility/tools/linux
patch < /module.c.patch
echo ""
echo ""
echo "Building dwarf module..."
make
cp module.dwarf /lime-module/${KVER}/volatility/tools/linux/
# make clean

# zip up results into a volatility formatted file
cd /
echo "Building ${KVER} volatility zip file..."
for f in /lime-module/${KVER}/*; do
  [ -e "$f" ] && rm -f /rpms/${KVER}_ponzu.zip && zip -9 -q -r /rpms/${KVER}_ponzu.zip /lime-module/${KVER}/
  # [ -e "$f" ] && zip -9 -r /rpms/${KVER}_lime_module.zip /lime-module/${KVER}/ &&\
  # rm -rf /lime-module/${KVER} &&\
  # yum -y remove kernel-${KVER} kernel-devel-${KVER} kernel-headers-${KVER1} &&\
  # rpm -qa |grep kernel|sort -df
done

# future: parse all files in /YourPath/rpms at once
# kernels=( $(ls -1 /YourPath/kernel-2*rpm |awk -F\/ '{print $2}' |sed 's/kernel-//' |sed 's/.rpm//' | sed 's/.x86_64//' | sed 's/.i386//' |sed 's/.el[5,6,7]//' |sort -V) )
#
# for kernel in ${kernels[@]}; do
# # echo "${kernel}: blah"
# done
