#!/bin/bash
set -x

DATE=$(date +"%m/%d/%Y %R:%S :")

################################## Script ###################################

echo "$DATE Beginning of Startup!"

# Stop display manager

systemctl stop display-manager
systemctl --user -M hxn@ stop plasma*

# Unbind VTconsoles: might not be needed
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 5 

# Unload NVIDIA kernel modules
modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia i2c_nvidia_gpu 
#snd_hda_intel 

# Detach GPU devices from host
virsh nodedev-detach pci_0000_06_00_0
virsh nodedev-detach pci_0000_06_00_1
virsh nodedev-detach pci_0000_06_00_2
virsh nodedev-detach pci_0000_06_00_3


# Load vfio module
modprobe vfio-pci
modprobe vfio
modprobe vfio_iommu_type1
echo "$DATE End of Startup!"
