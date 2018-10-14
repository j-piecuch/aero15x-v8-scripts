#!/bin/bash

sudo echo 'Starting patch and build of Nouveau module...'

orig_dir=$PWD

# Download linux kernel tree if not already there
if [ ! -d ./linux ]; then
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
fi

# Reset git tree and apply Karol's patch
cd linux
git reset --hard
git checkout v$(uname -r | cut -d'.' -f1-2)
patch -p1 < ../aero15x-scripts/nouveau-power.patch

# Build nouveau and install module
cd drivers/gpu/drm/nouveau
make -C /lib/modules/$(uname -r)/build M=$(pwd) clean
make -j6 -C /lib/modules/$(uname -r)/build M=$(pwd) modules
sudo make -C /lib/modules/$(uname -r)/build M=$(pwd) modules_install
make -C /lib/modules/$(uname -r)/build M=$(pwd) clean

# Remove module installed by Fedora kernel package
# (can reinstall with `dnf reinstall kernel-modules`)
sudo rm /lib/modules/$(uname -r)/kernel/drivers/gpu/drm/nouveau/nouveau.ko.xz

cd $orig_dir
echo 'Module installed.'
