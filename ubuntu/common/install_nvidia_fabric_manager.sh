#!/bin/bash
set -ex

source ${COMMON_DIR}/utilities.sh

# Set NVIDIA fabricmanager version
sudo apt-get install nvidia-fabricmanager-560
sudo systemctl enable nvidia-fabricmanager
sudo systemctl start nvidia-fabricmanager
