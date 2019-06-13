# Unraid HP Proliant Edition

## Introduction

It is well documen﻿ted that HP Proliant servers have RMRR issues using certain BIOS versions after about 2011 when trying to passthrough devices in a linux environment. Device passthrough fails and the onscreen error will show:

`vfio: failed to set iommu for container: Operation not permitted`

And a look further into the logs show:

`Device is ineligible for IOMMU domain attach due to platform RMRR requirement.  Contact your platform vendor.`

HP is aware of this problem and is not updating older machines. There are some bios options to try to fix this on newer models with some success.

This script will compile a new patched version of Unraid which bypasses the RMRR check.

## Usage

It is recommended to compile this in a **dedicated** folder, preferably on a cache device.

```
mkdir -p /mnt/cache/.rmrr
cd /mnt/cache/.rmrr
wget https://raw.githubusercontent.com/AnnabellaRenee87/Unraid-HP-Proliant-Edition/master/build_script/kernel_compile.sh
chmod +x kernel_compile.sh
./kernel_compile.sh
```

A new bzimage file is then compiled with the RMRR patch applied.

## Support

Discussion about this patch and it's use on Unraid should be directed to the [thread on the Unraid forums](https://forums.unraid.net/topic/72681-unraid-hp-proliant-edition-rmrr-error-patching/?tab=comments#comment-668032&searchlight=1).

## Dependencies

Dependencies are found in the [Unraid-Dependencies Repository](https://github.com/linuxserver/Unraid-Dependencies)

## Credits 

Maintainers: [AnnabelleRenee87](https://forums.unraid.net/profile/73615-annabellarenee87/) & [1812](https://forums.unraid.net/profile/70493-1812/)

This Unraid edition is based on the work of several others, and full credit is due to them.

First is the source of the patch code itself from the Promox forum users [here](https://forum.proxmox.com/threads/tutorial-compile-proxmox-ve-5-with-patched-intel-iommu-driver-to-remove-rmrr-check.36374/) & [here](https://forum.proxmox.com/threads/hp-proliant-microserver-gen8-raidcontroller-hp-p410-passthrough-probleme.30547/).

The second is [kabloomy](https://forums.unraid.net/profile/75139-kabloomy/) who successfully created a working edition using a modified DVB edition script on Unraid 6.4.1.

And last but not least, is the modified script currently in use provided by the totally awesome [CHBMB](https://github.com/CHBMB) (Thank you!!!)
