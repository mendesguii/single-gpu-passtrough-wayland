# 🧾 Single-GPU Passthrough on Wayland

I made this guide to ease the whole process of using KDE with wayland on a single GPU. Please bear in mind this tutorial is written specifically for my case (below configs).

## 📌 Specs
- **Distro:** CachyOS (Arch Linux)
- **CPU:** Ryzen 3700x
- **Motherboard:** B450M Steel Legend
- **GPU:** RTX 4060 - [VFIO Bios Collection](https://www.techpowerup.com/vgabios/)

---

## ⚙️ 1 — BIOS Settings
- Go to AMD CBS → NBIO Common Options and enable:
    - Enable IOMMU
    - Enable AER CAP
    - Enable ACS

---

## 🛠️ 2 — GRUB Kernel Parameters
Edit `/etc/default/grub`:
```bash
sudo nvim /etc/default/grub
```
Add to `GRUB_CMDLINE_LINUX_DEFAULT`:
```text
amd_iommu=on iommu=pt video=efifb:off
```
Regenerate grub config and reboot:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

---

## 📦 3 — Required Packages (Arch/CachyOS)
Install packages:
```bash
sudo pacman -Su virt-manager qemu vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf qemu-hw-usb-host
```

### 3.1 — libvirtd configuration
Edit `/etc/libvirt/libvirtd.conf`:
```bash
sudo nvim /etc/libvirt/libvirtd.conf
```
Uncomment/set:
```text
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```
Add logging (end of file):
```text
log_filters="3:qemu 1:libvirt"
log_outputs="2:file:/var/log/libvirt/libvirtd.log"
```

Add your user to groups:
```bash
sudo usermod -a -G kvm,input,libvirt $(whoami)
```

Enable & start libvirtd:
```bash
sudo systemctl enable --now libvirtd
```

### 3.2 — qemu.conf
Edit `/etc/libvirt/qemu.conf` and set `user` and `group` to your user:
```bash
sudo nvim /etc/libvirt/qemu.conf
```
Example:
```text
user = "root"
group = "root"
```
(Replace `root` with your username - group must be root)

Restart services and enable default network:
```bash
sudo systemctl restart libvirtd
sudo virsh net-autostart default
```

Reboot to ensure all kernel options and services are applied.

---

## 🖥️ 4 — Create the Windows VM
1. Download Windows 11 ISO and [VirtIO drivers](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers).
2. In `virt-manager`, create a new VM and choose:
     - OS: Microsoft Windows (Win 10/11)
     - Firmware: UEFI (OVMF), Chipset: Q35
     - Select ISO as install media
     - Tick “Customize configuration before install”
3. Hardware choices:
     - NIC: virtio
     - Disk: virtio
     - Add a SATA CD-ROM with the VirtIO ISO for drivers

During Windows install, load the VirtIO storage driver (amd64 → correct win version) so the installer sees the disk.

### After Windows install
- Install the VirtIO drivers from the VirtIO ISO (look for .exe installer).
- If network fails, edit `/etc/libvirt/network.conf` and set `firewall_backend=iptables`, then restart `libvirtd`.[Source](https://bbs.archlinux.org/viewtopic.php?id=291898)
- Install RustDesk on the VM and a phone/another PC to ensure remote access for driver install.
    - Configure RustDesk for unattended access (single password) before proceeding.

Only after RustDesk is working (and can ran at login without any input):
- Remove any spice/vnc devices from the VM XML.
- Set a proper CPU topology in the VM XML.
- Add the GPU as a PCI Host Device (passthrough).
- Add any USB devices you want passed through.

---

## 🔁 5 — Hooks / Scripts
- Run `install_hooks.sh` to install the `hooks/` scripts into libvirt hooks or systemd as you need.
- Check logs at `/var/log/libvirt` for hook output and errors.

---

## ✅ 6 — Final Touches
- Start the VM, connect via RustDesk, and install the NVIDIA drivers inside Windows.
- The connected display should initialize once the driver is active.
- Tweak extra flags in the VM XML as needed (ex: hide vendor, reset options, etc.). [Source](https://github.com/iaoedsz2008/libvirt-stealth)

---

## 🙏 Credits & References
- https://github.com/QaidVoid/Complete-Single-GPU-Passthrough
- https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/home
- https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Passing_VM_audio_to_host_via_Scream_and_IVSHMEM

