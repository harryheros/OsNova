# OsNova

> System Deployment & Reinstallation Engine for VPS and bare-metal servers.

[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-VPS%20%7C%20Bare--metal-black.svg)](#)
[![OS Support](https://img.shields.io/badge/support-Debian%2011%2F12%2F13%20%7C%20Ubuntu%2022.04%2F24.04-green.svg)](#)
[![Language](https://img.shields.io/badge/language-Bash-informational.svg)](#)

---

## Overview

OsNova is an automated Linux deployment and reinstallation tool for VPS and bare-metal systems.

It provides a deterministic way to reinstall Debian or Ubuntu directly from the running system using official upstream resources, without requiring a rescue ISO or external recovery environment.

This project is intended for operators who need a fast, reproducible, infrastructure-oriented reinstall workflow.

Use only on systems you own or are explicitly authorized to manage.

---

## Quick Start

Requires Bash and root privileges.

Review before execution:

```bash
curl -fsSL -o reinstall.sh https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh
less reinstall.sh
```

Default installation (Debian 12):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh)
```

Debian 13 with custom password and SSH port:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh) -d 13 -p "YourPassword" --port 2222
```

Ubuntu 24.04:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh) -u 24
```

Ubuntu 22.04:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh) -u 22
```

Custom DNS example:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh) -u 24 --dns "1.1.1.1 9.9.9.9"
```

Full example:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/OsNova/main/os/reinstall.sh) -u 24 -p "SecurePassword" --port 2222 --dns "8.8.8.8 1.1.1.1"
```

---

## Data Loss Warning

> ⚠️ This tool will completely erase the primary disk and reinstall the operating system.
>
> All existing data on the target disk will be permanently destroyed.
>
> Do not run it unless you fully understand the consequences.

---

## Features

- Unified Debian and Ubuntu reinstall workflow  
- Works on both BIOS and UEFI systems  
- Cross-distribution execution support  
- Uses official upstream installer or image resources  
- Debian installation via official netboot installer and preseed automation  
- Ubuntu deployment via official cloud image and direct disk write  
- Automatic disk and network detection  
- Static IPv4 migration from the current system  
- Optional IPv6 carry-over when detected  
- Debian networking configured with systemd-networkd  
- Ubuntu networking configured with netplan rendered by systemd-networkd  
- Custom DNS server support via --dns  
- Automatic SSH root login configuration  
- Custom SSH port support  
- Automatic random root password generation when -p is not provided  
- Built-in FQ and BBR network optimization  
- Ubuntu EFI fallback boot path repair  
- CentOS 7 Vault fallback for legacy dependency installation  

---

## Supported Operating Systems

Debian:  
- Debian 13 (Trixie)  
- Debian 12 (Bookworm) — default  
- Debian 11 (Bullseye)  

Ubuntu:  
- Ubuntu 24.04 LTS (Noble) — default  
- Ubuntu 22.04 LTS (Jammy)  

---

## Installation Architecture

Debian path:  
1. Detect current disk and network configuration  
2. Download official Debian netboot installer  
3. Inject preseed configuration and post-install script into initrd  
4. Create a temporary GRUB boot entry  
5. Reboot into the automated Debian installer  

Ubuntu path:  
1. Detect current disk and network configuration  
2. Download official Ubuntu cloud image  
3. Mount the image through qemu-nbd  
4. Configure root password, SSH, sysctl, netplan, cloud-init seed, and DNS  
5. Repair EFI fallback boot path if needed  
6. Write the image directly to the target disk  
7. Reboot into the new system  

---

## Parameters

-d [11|12|13]   Install Debian (default: 12)  
-u [22|24]      Install Ubuntu (default: 24)  
-p PASSWORD     Set root password  
--port PORT     Set SSH port (default: 22)  
--dns "IP..."   Set DNS servers  
-h, --help      Show help  

---

## Default Behavior

- If -p is not provided, a random root password is generated automatically  
- The generated password is displayed before reboot and must be saved by the operator  
- SSH is configured to allow root login and password authentication  
- The detected primary disk is used as the installation target  
- Current network settings are reused for static configuration  
- Default DNS servers are 8.8.8.8 and 1.1.1.1 unless overridden  
- If --dns is provided, those DNS servers are written into the installed system  

---

## Network Configuration

Debian:  
OsNova installs a static systemd-networkd configuration using the detected IPv4 settings, optional IPv6 settings, and the selected DNS servers.  

Ubuntu:  
OsNova installs a static netplan configuration rendered by systemd-networkd, disables cloud-init network generation, and writes the selected DNS servers into the installed system.  

---

## Tested Environments

- KVM virtual machines  
- Common cloud VPS providers  
- BIOS systems  
- UEFI systems  

---

## Intended Use

OsNova is intended for:  

- VPS reprovisioning  
- Bare-metal operating system replacement  
- Clean system redeployment  
- Infrastructure rebuild workflows  
- Deterministic Debian and Ubuntu reinstall operations  

It is not designed as a rescue panel replacement or a consumer desktop installer.  

---

## License

GPL-3.0  

---

## Philosophy

Minimal assumptions. Direct execution. Reproducible results.
