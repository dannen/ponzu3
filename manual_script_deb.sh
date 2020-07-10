#!/bin/bash
KVER=`uname -r`
export KVER

# banner
echo "this is just for building and testing, do not use on a compromised system."
sleep 5

# install build tools
sudo apt-get update
sudo apt-get -y upgrade
echo "reboot the system if the kernel upgrades."
sleep 10

sudo apt-get -y install autoconf build-essential dwarfdump git libelf-dev libtool pigz python zip

#  trigger basic sudo creds
sudo echo
#  grab src
git clone git://git.code.sf.net/p/libdwarf/code
git clone https://github.com/504ensicsLabs/LiME.git
git clone https://github.com/volatilityfoundation/volatility.git
cd ~

# build basic volatility paths
mkdir -p ~/lime-module/${KVER}/boot
mkdir -p ~/lime-module/${KVER}/volatility/tools/linux/

# build dwarfdump
cd ~/code && \
/bin/bash scripts/FIX-CONFIGURE-TIMES && \
autoreconf -f -i && \
./configure && \
make > /tmp/log-file 2>&1  && \
sudo cp -p ~/code/dwarfdump/dwarfdump /bin/dwarfdump && \
cd ~

# build lime kernel module
cd ~/LiME/src
echo "Building lime module..."
make > /tmp/log-file 2>&1
cp lime-${KVER}.ko ~/lime-module/${KVER}
sudo cp /boot/System.map-${KVER} ~/lime-module/${KVER}/boot

# build dwarfdump module
cd ~/volatility/tools/linux
echo "Building dwarf module..."
make > /tmp/log-file 2>&1
cp module.dwarf ~/lime-module/${KVER}/volatility/tools/linux/

# zip up results into a volatility formatted file
cd ~
sudo chown -R `whoami` ~/lime-module
echo "Building ${KVER} volatility zip file..."
for f in lime-module/${KVER}/*; do
  zip -9 -q -r ~/${KVER}_ponzu.zip lime-module/${KVER}/
done

# copy new profile into local volatility
cp ~/${KVER}_ponzu.zip ~/volatility/volatility/plugins/overlays/linux/

# assumes you have enough disk space in /home
echo "dumping ram"
cd ~

# mkfifo pipe to pigz to rapidly compress ram dump during insmod process
rm -f zap;mkfifo zap; pigz -1 -c < zap > ram.test.gz &
sudo /sbin/insmod ~/lime-module/${KVER}/lime-${KVER}.ko path=~/zap format=lime
sudo /sbin/rmmod lime

# old method
# sudo /sbin/insmod ~/lime-module/${KVER}/lime-${KVER}.ko path=~/ram.lime format=lime

# uncompress copy of ram file
pigz -d -c ~/ram.test.gz > ram.lime

# volatility test
#/usr/bin/env python ~/src/volatility/vol.py -d --profile Linux${KVER}_ponzuarm64 --plugins=tools/linux -f ~/ram/lime linux_bash
/usr/bin/env python ~/volatility/vol.py -d --profile "Linux`uname -r |sed 's/\./_/g'`_ponzuarm64" --plugins=tools/linux -f ~/ram.lime linux_bash
