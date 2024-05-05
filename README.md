# Single GPU Passtrough on Wayland

I made this guide to ease the whole process of using KDE with wayland on a single GPU.

# Specs
 - Distro: CachyOS (Arch Linux)
 - CPU: Ryzen 3700x
 - MOBO: B450M Steel Legend
 - GPU: RTX 2060

 # 1. Configs on BIOS.
 - AMD CBS
    - NBIO Common Options
        - Enable IOMMU
        - Enable AER CAP
        - Enable ACS  

# 2. GRUB Parameters

Edit the grub file with
```
sudo nvim /etc/default/grub
```
On the **GRUB_CMDLINE_LINUX_DEFAULT** edit and add the following.


```
GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on iommu=pt video=efifb:off"
```

Update the grub config with the following command:
```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
**Reboot after this!**

# 3. Required Packages on Arch (or at least with CachyOS)

Install below packages:
```
sudo pacman -Su virt-manager qemu vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf qemu-hw-usb-host
```
## 3.1 Config Files

## 3.2 libvirtd.conf

```
sudo nvim /etc/libvirt/libvirtd.conf
```
Uncomment below lines:
```
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```
Add to the end of the file:
```
log_filters="3:qemu 1:libvirt"
log_outputs="2:file:/var/log/libvirt/libvirtd.log"

```

## 3.3 Adding user to the correct groups
```
sudo usermod -a -G kvm,libvirt $(whoami)
```

## 3.4 Starting libvirtd

```
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

## 3.5 qemu.conf

Edit below config:
```
sudo nvim /etc/libvirt/qemu.conf
```

Uncomment lines and change **root** to your **user** 
```
user = "root"
group = "root"
```
## Restart services and Network
```
sudo systemctl restart libvirtd
sudo virsh net-autostart default
```
**Reboot after this!**

# 4 Creating VM and Configuring TBD
# 5 Scripts start/stop TBD