#!/bin/bash
# We allow failures
#set -ex

max_attempts=5
attempt=1
while [[ ! -f /usr/bin/jq && $attempt -le $max_attempts ]]; do
	# install pre-requisites
 	# We need to disable 'set -ex' to retry
	./install_prerequisites.sh
	attempt=$((attempt + 1))
	if [[ ! -f /usr/bin/jq ]]; then
		echo "Prerequisites installation failed, retrying..."
		sleep 30  # Wait for locks to be released
	fi
done

export GPU="NVIDIA"

if [[ "$#" -gt 0 ]]; then
    INPUT=$1
    if [ "$INPUT" != "NVIDIA" ]; then
        echo "Error: Invalid GPU type. Only 'NVIDIA' is implemented for this OS."
	exit 1
    fi
fi

# set properties
source ./set_properties.sh

# remove packages requiring Ubuntu Pro for security updates
time $UBUNTU_COMMON_DIR/remove_unused_packages.sh

echo "Install utils"
time ./install_utils.sh

# install Lustre client
# $UBUNTU_COMMON_DIR/install_lustre_client.sh

# install DOCA OFED
# $UBUNTU_COMMON_DIR/install_doca.sh

# install PMIX
# $UBUNTU_COMMON_DIR/install_pmix.sh

# install mpi libraries
# $UBUNTU_COMMON_DIR/install_mpis.sh

echo "Install nvidia GPU driver"
attempt=1
while [[ ! -f /usr/bin/nvidia-smi && $attempt -le $max_attempts ]]; do
	time $UBUNTU_COMMON_DIR/install_nvidiagpudriver.sh
	attempt=$((attempt + 1))
	if [[ ! -f /usr/bin/nvidia-smi ]]; then
		echo "NVIDIA driver installation failed, retrying..."
		sleep 30  # Wait for locks to be released
	fi
done

echo "Install nvidia fabric manager"
attempt=1
while [[ ! -f /usr/bin/nv-fabricmanager && $attempt -le $max_attempts ]]; do
	add-apt-repository -y ppa:graphics-drivers/ppa
	apt-get update
	
	apt-get -y install nvidia-fabricmanager-560
	systemctl enable nvidia-fabricmanager
	systemctl start nvidia-fabricmanager
	attempt=$((attempt + 1))
	if [[ ! -f /usr/bin/nv-fabricmanager ]]; then
		echo "NVIDIA fabric manager installation failed, retrying..."
		sleep 30  # Wait for locks to be released
	fi
done

echo "Install NCCL"
time $UBUNTU_COMMON_DIR/install_nccl.sh

# Install NVIDIA docker container
# $UBUNTU_COMMON_DIR/install_docker.sh

# cleanup downloaded tarballs - clear some space
rm -rf *.tgz *.bz2 *.tbz *.tar.gz *.run *.deb *_offline.sh
rm -rf /tmp/MLNX_OFED_LINUX* /tmp/*conf*
rm -rf /var/intel/ /var/cache/*
rm -Rf -- */

echo "Install DCGM"
attempt=1
while [[ ! -f /usr/bin/dcgmi && $attempt -le $max_attempts ]]; do
	time $UBUNTU_COMMON_DIR/install_dcgm.sh
	attempt=$((attempt + 1))
	if [[ ! -f /usr/bin/dcgmi ]]; then
		echo "NVIDIA driver installation failed, retrying..."
		sleep 30  # Wait for locks to be released
	fi
done

echo "Install Intel libraries"
time $COMMON_DIR/install_intel_libs.sh

echo "Install diagnostic script"
time $COMMON_DIR/install_hpcdiag.sh

echo "Install persistent rdma naming"
time $COMMON_DIR/install_azure_persistent_rdma_naming.sh

echo "Install optimizations"
time $UBUNTU_COMMON_DIR/hpc-tuning.sh

# Install AZNFS Mount Helper
# $COMMON_DIR/install_aznfs.sh

# copy test file
# $COMMON_DIR/copy_test_file.sh

# install monitor tools
# $COMMON_DIR/install_monitoring_tools.sh

echo "Install AMD libs"
time $COMMON_DIR/install_amd_libs.sh

# install Azure/NHC Health Checks
# $COMMON_DIR/install_health_checks.sh

# disable cloud-init
# $UBUNTU_COMMON_DIR/disable_cloudinit.sh

# diable auto kernel updates
# $UBUNTU_COMMON_DIR/disable_auto_upgrade.sh

# Disable Predictive Network interface renaming
time $UBUNTU_COMMON_DIR/disable_predictive_interface_renaming.sh

echo "Install SKU Customization"
time $COMMON_DIR/setup_sku_customizations.sh

# clear history
# Uncomment the line below if you are running this on a VM
# $COMMON_DIR/clear_history.sh
