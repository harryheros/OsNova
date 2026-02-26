# 🚀 Harry Surpasser Debian Auto-Installer v1.3.8

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![OS Support](https://img.shields.io/badge/OS-Debian%2011%20%7C%2012%20%7C%2013-red.svg)](https://www.debian.org/)
[![Platform](https://img.shields.io/badge/Platform-BIOS%20%7C%20UEFI-orange.svg)](#)

Surpasser is a high-performance, BIOS + UEFI compatible automated network installer designed for VPS and bare-metal servers.  
Updated for 2026, it focuses on predictable deployment, visible installation progress, and maximum real-world compatibility.

This project is built for environments where **clarity, stability, and determinism matter more than theoretical elegance**.

---

## 🛠 Quick Start

Run as root.

Option 1: Default Installation (Recommended)

Installs Debian 12 with SSH port 22 and default root password.
```bash
bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/surpasser.sh)
```
Option 2: Custom Installation

Customize Debian version, root password, or SSH port.
```bash
bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/surpasser.sh) -d 13 -p "YourPassword" --port 7777
```
⚠️ DATA LOSS WARNING  
This script will completely wipe the system disk, remove all partitions, and reinstall the operating system.  
All existing data will be permanently erased.

---

## ✨ Key Features (v1.3.8)

- Cross-Platform Launcher  
  Supports execution from CentOS 7 / 8 / 9, Fedora, AlmaLinux, Rocky Linux, Debian, and Ubuntu.

- Official Debian Installer  
  All installation images are downloaded directly from deb.debian.org.  
  No mirrors, no third-party sources, no modification risk.

- BIOS + UEFI Compatible  
  Works reliably across legacy BIOS and modern UEFI environments.

- Deterministic GRUB Boot Handling  
  Automatically creates a dedicated Surpasser-AutoInstall boot entry and sets it as default.

- VNC-Friendly Visual Installation  
  Fixed vga=788 graphics mode ensures stable, visible output in VPS VNC consoles.  
  Designed specifically to avoid black screen and flicker issues.

- Visible Installation Process  
  Network configuration, installer source, and key progress steps are printed clearly to reduce misjudgment and panic reboots.

- Smart Network Detection  
  Automatically adapts to interface naming differences such as eth0, ens18, enpXsY without triggering installer interaction.

- Pure Server Installation  
  Installs a clean Debian server system with no desktop environment.

- Native Performance Optimization  
  Enables TCP BBR congestion control and FQ queue discipline by default.

- Reliable Boot-Time Networking  
  Uses both auto and allow-hotplug mechanisms for maximum compatibility across VPS platforms.

- Safety-Oriented Parameter Validation  
  Prevents invalid SSH ports and empty passwords from causing unpredictable installation behavior.

---

## 📂 Supported Operating Systems (2026)

Target installation systems:

- Debian 13 (Trixie) – Recommended
- Debian 12 (Bookworm) – Default
- Debian 11 (Bullseye)

Supported origin systems (script execution source):

- CentOS 7 / 8 / 9 (Stream)
- Fedora 30+
- AlmaLinux 8 / 9
- Rocky Linux 8 / 9
- Debian / Ubuntu

---

## 🛠 Advanced Parameters

-d [11|12|13]  
Select target Debian version.

-p "password"  
Set custom root password.

--port [number]  
Set custom SSH port (default: 22, valid range: 1–65535).

Example:
```bash
bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/surpasser.sh) -d 13 -p "YourSecurePassword" --port 7777
```
---

## 🔐 Default Credentials

If no parameters are provided, the script uses the following defaults:

Property | Default Value
--- | ---
OS Version | Debian 12 (Bookworm)
Username | root
Password | Harry888
SSH Port | 22

Default root password is set to avoid reinstall lockout.  
Please change it after first login.

---

## 🏆 Design Philosophy

Surpasser is not designed to be clever — it is designed to be reliable.

This script prioritizes:

- Predictable behavior
- Visible progress
- Deterministic boot flow
- Minimal environmental assumptions
- Compatibility over abstraction

It intentionally avoids:

- Serial console dependencies
- Experimental graphics fallback
- Over-engineered network logic
- Hidden automation
- Silent execution

The objective is simple:

A system reinstall process that operators can **see**, **understand**, and **trust** — even under poor VNC implementations.

---

## ⚖️ License & Author

Author: Harry  
Project: https://github.com/harryheros/LinuxTools  

Copyright (C) 2026 HarryLinux Tools.

Licensed under the GNU General Public License v3.0 (GPLv3).

You are free to use, modify, and redistribute this project under the GPLv3 license.  
Any derivative work must retain attribution and remain open-sourced under the same license.
