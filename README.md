# 🚀 AutoLinux — Unified Linux Auto Installer

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)  
[![OS Support](https://img.shields.io/badge/OS-Debian%2011%20%7C%2012%20%7C%2013%20%7C%20Ubuntu%2022.04%20%7C%2024.04-red.svg)](#)  
[![Platform](https://img.shields.io/badge/Platform-BIOS%20%7C%20UEFI-orange.svg)](#)

AutoLinux is a high-performance automated Linux reinstall tool designed for VPS and bare-metal servers.

It provides a unified installation workflow for Debian and Ubuntu, supports both legacy BIOS and modern UEFI environments, and focuses on deterministic behavior with minimal environmental assumptions.

AutoLinux is designed for operators who want a reinstall process that is:

- predictable
- transparent
- fast
- compatible across common hosting environments

At its core, AutoLinux is an IPv4-first deterministic Linux reinstall tool with best-effort IPv6 restoration for Debian and Ubuntu on supported environments.

---

# 📑 Table of Contents

- Quick Start
- Key Features
- Supported Operating Systems
- Installation Architecture
- Installation Flow
- Advanced Parameters
- Default Credentials
- Notes
- Security Notes
- Design Philosophy
- License

---

# 🛠 Quick Start

Run as root.

## Default Installation (Recommended)

Installs Debian 12 with SSH port 22 and the default root password.

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh)

## Install Debian

Example: Install Debian 13 with a custom password and SSH port.

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh) -d 13 -p "YourPassword" --port 7777

## Install Ubuntu

Example: Install Ubuntu 24.04.

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh) -u 24

## Default Version Behavior

- `-d` without a version defaults to Debian 12
- `-u` without a version defaults to Ubuntu 24.04

⚠️ DATA LOSS WARNING

This script will completely wipe the target system disk and reinstall the operating system.

All partitions and data on the selected primary disk will be permanently erased.

---

# ✨ Key Features

## Unified Debian + Ubuntu Installer

AutoLinux supports both Debian and Ubuntu installations through a single script.

- Debian uses the official Debian netboot installer
- Ubuntu uses official Ubuntu cloud images for fast deployment

This allows a single operational workflow across different deployment targets.

## BIOS + UEFI Compatible

AutoLinux is designed to work across:

- legacy BIOS systems
- modern UEFI servers
- VPS platforms with mixed boot environments

## Cross-Distribution Launcher

The script can be launched from a wide range of Linux environments, including:

- Debian
- Ubuntu
- CentOS 7
- AlmaLinux
- Rocky Linux
- Fedora

This allows a system to be reinstalled without requiring the source OS to already be Debian or Ubuntu.

## Official Upstream Sources

All installation assets are fetched from official upstream distribution sources.

Debian assets are downloaded from the Debian infrastructure.

Ubuntu images are downloaded from the Ubuntu cloud image infrastructure.

No third-party mirrors or modified images are used.

## Lightweight Disk and Network Detection

Before installation, AutoLinux performs lightweight environment detection to identify:

- the primary non-removable system disk
- the active default-route interface
- the current IPv4 address
- the current IPv4 prefix / netmask
- the current default gateway

If available, AutoLinux also detects an existing global IPv6 address, prefix, and gateway for later restoration.

If disk detection fails, AutoLinux falls back to `/dev/sda` after a short warning delay.

## Deterministic Debian Boot Handoff

For Debian targets, AutoLinux:

- downloads the official Debian netboot installer
- injects an automated preseed file
- injects a post-install configuration script
- creates a dedicated temporary GRUB menu entry
- reboots directly into the installer

This creates a predictable handoff from the source system into the Debian installer.

## Fast Ubuntu Cloud-Image Deployment

For Ubuntu targets, AutoLinux avoids a traditional network installer.

Instead, it:

- downloads the official Ubuntu cloud image
- attaches it via `qemu-nbd`
- mounts the image offline
- injects configuration directly into the filesystem
- writes the prepared image directly to disk using `qemu-img`

This deployment model is significantly faster than traditional network-based installs on many VPS platforms.

## SSH Access Configuration

AutoLinux explicitly configures remote access after installation by enabling:

- root login
- password authentication
- custom SSH port support

On Ubuntu cloud-image deployments, it also writes a dedicated SSH override configuration to ensure these settings are applied consistently.

## Native Performance Optimization

AutoLinux enables modern TCP performance tuning by default:

- FQ queue discipline
- TCP BBR congestion control

These settings are commonly used in high-performance server environments.

## Best-Effort IPv6 Restoration

AutoLinux supports best-effort IPv6 restoration for both Debian and Ubuntu installations.

When a usable global IPv6 address, prefix, and route information are detectable on the source system, AutoLinux attempts to carry that configuration into the installed system.

Implementation differs by target:

- Debian restores IPv6 through `/etc/network/interfaces`
- Ubuntu restores IPv6 through `netplan`

If the required IPv6 parameters are incomplete or unavailable, AutoLinux falls back to IPv4-only provisioning.

## Legacy System Compatibility

AutoLinux automatically detects certain end-of-life systems, such as CentOS 7, and temporarily enables CentOS Vault repositories so required packages can still be installed during migration.

This improves reliability when migrating older VPS environments to modern Debian or Ubuntu systems.

---

# 📂 Supported Operating Systems

## Target Installation Systems

### Debian

- Debian 13 (Trixie)
- Debian 12 (Bookworm) — Default
- Debian 11 (Bullseye)

### Ubuntu

- Ubuntu 24.04 LTS (Noble) — Default
- Ubuntu 22.04 LTS (Jammy)

## Supported Source Systems (Script Execution)

The installer can be launched from:

- Debian
- Ubuntu
- CentOS 7
- AlmaLinux
- Rocky Linux
- Fedora

---

# 🏗 Installation Architecture

AutoLinux uses different installation strategies depending on the target operating system.

## Debian (Netboot + GRUB Handoff)

For Debian targets, AutoLinux downloads the official Debian netboot installer, injects a preseed file and a late-stage post-install script, then creates a temporary GRUB entry that boots directly into the installer on the next reboot.

The Debian path performs:

1. Download official Debian netboot assets
2. Inject preseed configuration into the installer initrd
3. Inject a late-stage post-install script
4. Create a temporary GRUB boot entry
5. Reboot directly into the Debian installer
6. Complete automated installation with post-install SSH, network, and performance tuning

This path uses Debian’s official installer infrastructure while preserving a deterministic deployment flow.

## Ubuntu (Offline Cloud-Image Customization)

For Ubuntu targets, AutoLinux downloads the official Ubuntu cloud image, attaches it through `qemu-nbd`, mounts the filesystem offline, injects system configuration directly, and writes the finalized image to the target disk using `qemu-img`.

The Ubuntu path performs:

1. Download the official Ubuntu cloud image
2. Attach the image using `qemu-nbd`
3. Mount the root filesystem directly
4. Inject root password, SSH settings, sysctl tuning, and static netplan configuration
5. If available, inject IPv6 configuration into netplan
6. Seed minimal cloud-init metadata for first-boot resize tasks
7. Write the prepared image directly to the target disk
8. Repair GPT backup header metadata if needed

This approach avoids the overhead of a traditional network installer and provides a very fast deployment path on many VPS platforms.

---

# 🔄 Installation Flow

    Current Linux System
            │
            ▼
    AutoLinux Script Execution
            │
            ▼
    Detect Disk + Network Environment
            │
            ▼
    Choose Target OS
            │
      ┌─────┴─────┐
      ▼           ▼
    Debian      Ubuntu
    Netboot     Cloud Image
    Path        Path
      ▼           ▼
    Automated System Preparation
            │
            ▼
    Reboot into Installed System

---

# 🛠 Advanced Parameters

- `-d [11|12|13]`  
  Install Debian with the specified version. Default: 12

- `-u [22|24]`  
  Install Ubuntu with the specified version. Default: 24

- `-p password`  
  Set the root password. Default: Harry888

- `-port / --port N`  
  Set the SSH port. Valid range: 1–65535. Default: 22

- `-h / --help`  
  Show help information

Example:

    bash <(curl -sSL https://raw.githubusercontent.com/harryheros/LinuxTools/main/super/autolinux.sh) -u 24 -p "SecurePassword" --port 2222

---

# 🔐 Default Credentials

If no parameters are provided, AutoLinux uses the following defaults:

| Property | Default Value |
|---|---|
| OS Version | Debian 12 (Bookworm) |
| Username | root |
| Password | Harry888 |
| SSH Port | 22 |

You should change the password after the first login.

---

# 📝 Notes

- Installation is IPv4-first across all targets.
- AutoLinux writes static network configuration into the installed system.
- Public DNS resolvers `8.8.8.8` and `1.1.1.1` are written into generated network configuration.
- Debian uses `/etc/network/interfaces` for installed network configuration.
- Ubuntu uses `netplan` for installed network configuration.
- IPv6 restoration is best-effort and depends on usable host-side IPv6 parameters being detectable before installation.
- If required IPv6 parameters are incomplete, AutoLinux falls back to IPv4-only provisioning.
- Automatic disk selection is optimized for common VPS and single-disk server layouts.
- Ubuntu cloud-image deployments seed first-boot expansion commands for standard cloud-image disk layouts.

---

# 🔒 Security Notes

This project is intended for system reinstallation, migration, and recovery scenarios.

Operational recommendations:

- use a strong root password
- change the default password immediately if defaults were used
- change the SSH port if the server is exposed directly to the public internet
- disable password authentication after deployment if you intend to switch to SSH keys only

Because AutoLinux intentionally enables root login and password authentication to prevent lockout during automated reinstalls, post-install hardening is strongly recommended.

---

# 🏆 Design Philosophy

AutoLinux is not designed to be clever — it is designed to be reliable.

This project prioritizes:

- deterministic behavior
- predictable installation flow
- broad VPS compatibility
- minimal assumptions
- transparent execution

It intentionally avoids:

- hidden automation
- unverified mirrors
- distribution-specific guesswork
- unnecessary abstraction

The goal is simple:

A Linux reinstall workflow that operators can understand, trust, and run almost anywhere.

---

# ⚖️ License

Author: Harry

Project: https://github.com/harryheros/LinuxTools

Copyright (C) 2026 HarryLinux Tools.

Licensed under the GNU General Public License v3.0 (GPLv3).

You are free to use, modify, and redistribute this project under the GPLv3 license.

Any derivative work must retain attribution and remain open-sourced under the same license.
