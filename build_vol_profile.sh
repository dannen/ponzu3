#!/bin/bash
KVER=`uname -r`
export KVER

#  trigger basic sudo creds
sudo echo
#  grab src
git clone git://git.code.sf.net/p/libdwarf/code && \
git clone https://github.com/504ensicsLabs/LiME.git
git clone https://github.com/volatilityfoundation/volatility.git

# build basic volatility paths
mkdir -p ~/lime-module/${KVER}/boot
mkdir -p ~/lime-module/${KVER}/volatility/tools/linux/

# build dwarfdump
cd ~/code \
&& /bin/bash scripts/FIX-CONFIGURE-TIMES \
&& ./configure \
&& make > /tmp/log-file 2>&1 \
&& sudo cp -p ~/code/dwarfdump/dwarfdump /bin/dwarfdump \
&& cd ~

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
for f in ~/lime-module/${KVER}/*; do
  zip -9 -q -r ~/${KVER}_ponzu.zip ~/lime-module/${KVER}/
done
