#!/bin/bash
set -x

DATE=$(date +"%m/%d/%Y %R:%S :")

################################## Script ###################################

echo "$DATE Beginning of Teardown!"

modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Attach GPU devices to host
virsh nodedev-reattach pci_0000_06_00_0
virsh nodedev-reattach pci_0000_06_00_1
virsh nodedev-reattach pci_0000_06_00_2
virsh nodedev-reattach pci_0000_06_00_3

# Rebind framebuffer to host
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Load NVIDIA kernel modules
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia
   
# Bind VTconsoles: might not be needed
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 1 > /sys/class/vtconsole/vtcon1/bind

# Restart Display Manager

systemctl start display-manager

echo "$DATE End of Teardown!"
