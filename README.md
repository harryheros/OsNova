# 🚀 AutoLinux Unified Linux Auto-Installer v2.0

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)  
[![OS Support](https://img.shields.io/badge/OS-Debian%2011%20%7C%2012%20%7C%2013%20%7C%20Ubuntu%2022.04%20%7C%2024.04-red.svg)](#)  
[![Platform](https://img.shields.io/badge/Platform-BIOS%20%7C%20UEFI-orange.svg)](#)

AutoLinux is a high-performance automated Linux installer designed for VPS and bare-metal environments.

It provides a unified installation workflow for Debian and Ubuntu, supporting both legacy BIOS and modern UEFI systems while maintaining deterministic behavior and minimal environmental assumptions.

The project focuses on predictable deployment, compatibility across hosting platforms, and a transparent installation process.

---

# 🛠 Quick Start

Run as root.

Option 1 — Default Installation (Recommended)

Installs Debian 12 with SSH port 22 and default root password.

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh)

---

Option 2 — Install Debian

Example: Install Debian 13 with custom password and SSH port.

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh) -d 13 -p "YourPassword" -port 7777

---

Option 3 — Install Ubuntu

Example: Install Ubuntu 24.04.

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh) -u 24

---

⚠️ DATA LOSS WARNING

This script will completely wipe the system disk and reinstall the operating system.

All partitions and data on the primary disk will be permanently erased.

---

# ✨ Key Features (v2.0)

### Unified Debian + Ubuntu Installer

Supports both Debian and Ubuntu installations through a single script.

Debian uses the official Debian netboot installer, while Ubuntu uses official cloud images for faster deployment.

---

### BIOS + UEFI Compatible

Works reliably across:

- Legacy BIOS systems
- Modern UEFI servers
- VPS platforms with mixed boot environments

---

### Cross-Distribution Launcher

The script can be executed from many Linux environments, including:

- Debian
- Ubuntu
- CentOS 7
- AlmaLinux
- Rocky Linux
- Fedora

This allows reinstalling a system without requiring an existing Debian or Ubuntu environment.

---

### Official Distribution Sources

All installation images are downloaded from official upstream sources.

Debian installer images are downloaded from deb.debian.org.

Ubuntu cloud images are downloaded from cloud-images.ubuntu.com.

No third-party mirrors or modified images are used.

---

### Automatic Hardware Detection

AutoLinux automatically detects:

- Primary system disk
- Active network interface
- IPv4 address
- Netmask
- Default gateway

The installer reuses the existing network configuration to ensure reliable connectivity after installation.

---

### Deterministic Bootloader Handling

For Debian installations, AutoLinux automatically:

- Injects a preseed configuration
- Creates a dedicated GRUB boot entry
- Sets it as the default boot target

This ensures the installer runs immediately after reboot without manual intervention.

---

### Fast Ubuntu Deployment

Ubuntu installations use official cloud images with automated configuration via cloud-init.

The process is:

1. Download Ubuntu cloud image  
2. Inject cloud-init configuration  
3. Write image directly to disk  
4. Expand filesystem automatically  

This allows Ubuntu to be installed significantly faster than traditional installers.

---

### Native Performance Optimization

AutoLinux enables modern TCP networking optimizations by default:

- TCP BBR congestion control
- FQ queue discipline

These settings are widely used in high-performance server environments.

---

### Automatic Disk Expansion

For Ubuntu installations:

- Disk partition expansion is handled automatically
- Filesystem resizing is performed during first boot

This ensures the system uses the entire disk capacity without manual resizing.

---

### SSH Access Configuration

AutoLinux automatically configures:

- Root login enabled
- Password authentication enabled
- Custom SSH port (optional)

This prevents lockout after installation.

---

# 📂 Supported Operating Systems (2026)

### Target Installation Systems

Debian

- Debian 13 (Trixie)
- Debian 12 (Bookworm) — Default
- Debian 11 (Bullseye)

Ubuntu

- Ubuntu 24.04 LTS (Noble) — Default
- Ubuntu 22.04 LTS (Jammy)

---

### Supported Source Systems (Script Execution)

The installer can be launched from:

- Debian
- Ubuntu
- CentOS 7
- AlmaLinux
- Rocky Linux
- Fedora

---

# 🛠 Advanced Parameters

-d [11|12|13]

Install Debian with specified version.

-u [22|24]

Install Ubuntu with specified version.

-p password

Set custom root password.

--port N

Set SSH port (1–65535).

---

Example

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh) -u 24 -p "YourSecurePassword" --port 2222

---

# 🔐 Default Credentials

If no parameters are provided, the script uses the following defaults.

Property | Default Value
--- | ---
OS Version | Debian 12 (Bookworm)
Username | root
Password | Harry888
SSH Port | 22

The default root password prevents installation lockout.

You should change the password after first login.

---

# 🏗 Installation Architecture

AutoLinux uses different installation mechanisms depending on the target OS.

### Debian

- Official Debian Netboot Installer
- Automated via Preseed configuration
- Booted through GRUB chainloading

### Ubuntu

- Official Ubuntu Cloud Image
- Configuration via cloud-init
- Disk written directly using qemu-img

This hybrid architecture allows AutoLinux to combine:

- Debian’s reliable installer
- Ubuntu’s fast cloud deployment

---

# 🏆 Design Philosophy

AutoLinux is not designed to be clever — it is designed to be reliable.

This project prioritizes:

- Predictable behavior
- Deterministic installation flow
- Maximum VPS compatibility
- Minimal environmental assumptions
- Transparent execution

It intentionally avoids:

- Hidden automation
- Unverified mirrors
- Distribution-specific assumptions
- Over-engineered abstractions

The objective is simple:

A Linux reinstall process that operators can understand, trust, and run anywhere.

---

# ⚖️ License & Author

Author: Harry  
Project: https://github.com/harryheros/LinuxTools  

Copyright (C) 2026 HarryLinux Tools.

Licensed under the GNU General Public License v3.0 (GPLv3).

You are free to use, modify, and redistribute this project under the GPLv3 license.

Any derivative work must retain attribution and remain open-sourced under the same license.
