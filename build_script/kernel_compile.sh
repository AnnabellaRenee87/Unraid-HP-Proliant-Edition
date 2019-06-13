#!/bin/bash

##Cleanup any old files before starting
rm -rf ${D}/kernel
rm -f \
  FILE_LIST_CURRENT \
  linux-*.tar.xz \
  variables.sh \
  URLS_CURRENT

##Set branch to pull from for dependencies
set -ea

: "${DEPENDENCY_BRANCH:=master}"

##Pull variables from github
wget -nc https://raw.githubusercontent.com/linuxserver/Unraid-Dependencies/${DEPENDENCY_BRANCH}/build_scripts/variables.sh

source ./variables.sh

if [[ -z "$D" ]]; then
    echo "Must provide D in environment" 1>&2
    exit 1
fi

source ${D}/dvb-variables.sh

##Grab Slackware packages
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Install packages"
[ ! -d "${D}/packages" ] && mkdir ${D}/packages
  wget -nc -P ${D}/packages -i ${D}/URLS_CURRENT
  if [[ $? != 0 ]]; then
    echo "Package missing. Exiting..."
    exit 1
  fi

#Pull static gcc deps
  wget -nc -P ${D}/packages https://github.com/linuxserver/Unraid-Dependencies/raw/${DEPENDENCY_BRANCH}/gcc/gcc-8.3.0-x86_64-1.txz
  wget -nc -P ${D}/packages https://github.com/linuxserver/Unraid-Dependencies/raw/${DEPENDENCY_BRANCH}/gcc/gcc-g++-8.3.0-x86_64-1.txz

##Install packages  
installpkg ${D}/packages/*.*

#Change to current directory
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Change to current directory"
cd ${D}

##Download and Install Kernel
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Download and Install Kernel"
[[ $(uname -r) =~ ([0-9.]*) ]] &&  KERNEL=${BASH_REMATCH[1]} || return 1
  LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL}.tar.xz"
  rm -rf ${D}/kernel; mkdir ${D}/kernel
  [[ ! -f ${D}/linux-${KERNEL}.tar.xz ]] && wget $LINK -O ${D}/linux-${KERNEL}.tar.xz
  tar -C ${D}/kernel --strip-components=1 -Jxf ${D}/linux-${KERNEL}.tar.xz
  rsync -av /usr/src/linux-$(uname -r)/ ${D}/kernel/
  cd ${D}/kernel

  for p in $(find . -type f -iname "*.patch"); do patch -N -p 1 < $p
  done
  make oldconfig

##Make necessary changes to fix HP RMRR issues
cd $D
sed -i '/return -EPERM;/d' $D/kernel/drivers/iommu/intel-iommu.c

##Compile Kernel
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Compile Kernel"
cd ${D}/kernel
make -j $(grep -c ^processor /proc/cpuinfo)

#Package Up new bzimage
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Package Up new bzimage"
mkdir -p ${D}/${UNRAID_VERSION}
cp -f ${D}/kernel/arch/x86/boot/bzImage ${D}/${UNRAID_VERSION}/bzimage

##Calculate sha256 on new bzimage
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Calculate sha256 on new bzimage"
cd ${D}/${UNRAID_VERSION}/
sha256sum bzimage > bzimage.sha256

##Return to original directory
echo -e "${BLUE}Kernel Compile Module${NC}    -----    Return to original directory"
cd ${D}
  
