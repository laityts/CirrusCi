#! /bin/bash

#
# Script for sync
#
#

# Set repo
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH="~/bin:$PATH"

# mkdir LineageOS
mkdir $ROM
cd $ROM

# initialize LineageOS trees
repo init -u $MANIFEST -b $BRANCH --depth=1

# Sync LineageOS Source
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags || true
