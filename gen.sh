#!/bin/bash
set -euo pipefail

# Additional packages and services in the ISO
PKGS='bzip2 cryptsetup curl ddrescue gnupg2 git gptfdisk gzip efibootmgr lvm2 lz4 makepasswd mdadm mosh nano p7zip rsync wget vim unzip xz zip zstd'
SERVICES=''

# Base packages and services required for livecd
# Source: https://github.com/void-linux/void-mklive/blob/master/build-x86-images.sh.in
BASE_PKGS='dialog cryptsetup lvm2 mdadm void-docs-browse grub-i386-efi grub-x86_64-efi xtools-minimal NetworkManager'
BASE_SERVICES="sshd NetworkManager acpid wpa_supplicant"

# List of mirrors (see also: ci/set_repository.sh):
#   https://docs.voidlinux.org/xbps/repositories/mirrors/
REPO='https://mirrors.dotsrc.org/voidlinux'

# Set repository
rm -fr /etc/xbps.d
mkdir -p -m 755 /etc/xbps.d
echo "repository=${REPO}/current" > /etc/xbps.d/repo-main.conf
echo "repository=${REPO}/current/nonfree" > /etc/xbps.d/repo-nonfree.conf

xbps-install --yes -Su xbps
xbps-install --yes -Su
xbps-install --yes -S git make
cd '/root'
[ ! -d 'void-mklive-extras' ] && git clone https://github.com/dr-nemesis-96/void-mklive-extras 'void-mklive-extras'
cd 'void-mklive-extras'
make clean
make
./mklive.sh -a 'x86_64' -r "${REPO}" -p "${BASE_PKGS} ${PKGS}" -S "${BASE_SERVICES} ${SERVICES}"
