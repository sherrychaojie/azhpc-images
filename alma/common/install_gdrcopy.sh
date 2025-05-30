#!/bin/bash
set -ex

source ${COMMON_DIR}/utilities.sh

# Install gdrcopy
gdrcopy_metadata=$(get_component_config "gdrcopy")
GDRCOPY_VERSION=$(jq -r '.version' <<< $gdrcopy_metadata)
GDRCOPY_COMMIT=$(jq -r '.commit' <<< $gdrcopy_metadata)
GDRCOPY_DISTRIBUTION=$(jq -r '.distribution' <<< $gdrcopy_metadata)
nvidia_metadata=$(get_component_config "nvidia")
nvidia_driver_metadata=$(jq -r '.driver' <<< $nvidia_metadata)
NVIDIA_DRIVER_VERSION=$(jq -r '.version' <<< $nvidia_driver_metadata)

git clone https://github.com/NVIDIA/gdrcopy.git
pushd gdrcopy/packages/
git checkout ${GDRCOPY_COMMIT}

CUDA=/usr/local/cuda ./build-rpm-packages.sh -m
rpm -Uvh gdrcopy-kmod-${GDRCOPY_VERSION}dkms.${GDRCOPY_DISTRIBUTION}.noarch.rpm
rpm -Uvh gdrcopy-${GDRCOPY_VERSION}.${GDRCOPY_DISTRIBUTION}.x86_64.rpm
rpm -Uvh gdrcopy-devel-${GDRCOPY_VERSION}.${GDRCOPY_DISTRIBUTION}.noarch.rpm
rpm -Uvh gdrcopy-kmod-$(uname -r)-nvidia-${NVIDIA_DRIVER_VERSION}-${GDRCOPY_VERSION}.${GDRCOPY_DISTRIBUTION}.x86_64.rpm
sed -i "$ s/$/ gdrcopy*/" /etc/dnf/dnf.conf
popd

$COMMON_DIR/write_component_version.sh "GDRCOPY" ${GDRCOPY_VERSION}
