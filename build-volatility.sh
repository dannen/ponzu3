#!/bin/bash
#
# Ponzu lime & volatilty build script
# Dannen Harris 2017 v. 3.0

KVER=$1-generic
export KVER

# import KVER into bash environment
# this is used to override the default value in LiME build
if [[ ! -z "${KVER}" ]]; then
echo "export KVER=${KVER}" >> /tmp/.bashrc
source /tmp/.bashrc;
else
  exit 0
fi

# look for local copies of rpms and install from vault if missing
if [ ! -f "/debs/linux-image-${KVER}.deb" ]; then
  echo "No local debs found, pulling from vault..."
  apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" linux-image-${KVER} linux-headers-${KVER}
else
 echo "Local debs found, installing..."
 apt install -y /debs/linux-image-${KVER}.deb /debs/linux-headers-${KVER}.deb
fi

# build basic volatility paths
mkdir -p /lime-module/${KVER}/boot
mkdir -p /lime-module/${KVER}/volatility/tools/linux/

# build lime kernel module
cd /LiME/src
echo "Building lime module..."
make > /tmp/log-file 2>&1
cp lime-${KVER}.ko /lime-module/${KVER}
cp /boot/System.map-${KVER} /lime-module/${KVER}/boot

# build dwarfdump module
cd /volatility/tools/linux
echo "Building dwarf module..."
make > /tmp/log-file 2>&1
cp module.dwarf /lime-module/${KVER}/volatility/tools/linux/

# zip up results into a volatility formatted file
cd /
echo "Building ${KVER} volatility zip file..."
for f in /lime-module/${KVER}/*; do
  [ -e "$f" ] && rm -f /debs/${KVER}_ponzu.zip && zip -9 -q -r /debs/${KVER}_ponzu.zip /lime-module/${KVER}/
done

# future: parse all files in /YourPath/rpms at once
# kernels=( $(ls -1 /YourPath/kernel-2*rpm |awk -F\/ '{print $2}' |sed 's/kernel-//' |sed 's/.rpm//' | sed 's/.x86_64//' | sed 's/.i386//' |sed 's/.el[5,6,7]//' |sort -V) )
#
# for kernel in ${kernels[@]}; do
# # echo "${kernel}: blah"
# done
