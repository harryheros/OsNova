# 🚀 AutoLinux v2.0.1 — Unified Linux Provisioning & Reinstall Tool

![Version](https://img.shields.io/badge/version-2.0.1-green.svg)
![License](https://img.shields.io/badge/license-GPLv3-blue.svg)
![OS Support](https://img.shields.io/badge/OS-Debian%2011%20%7C%2012%20%7C%2013%20%7C%20Ubuntu%2022.04%20%7C%2024.04-red.svg)
![Platform](https://img.shields.io/badge/platform-BIOS%20%7C%20UEFI-orange.svg)
![Language](https://img.shields.io/badge/language-bash-black.svg)

AutoLinux is a high-performance Linux provisioning and reinstall tool for VPS and bare-metal servers.

It provides a deterministic and automated way to reinstall Debian or Ubuntu using official upstream resources — without requiring rescue environments.

> ⚠️ Intended for systems owned or managed by the operator.

---

## ⚡ Quick Start

> Requires bash (process substitution support)  
> Run as root

### Review script before execution

```bash
curl -fsSL https://raw.githubusercontent.com/harryheros/linuxtools/main/os/autolinux.sh
```

---

### Default installation (Debian 12)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/linuxtools/main/os/autolinux.sh)
```

---

### Debian 13 (custom password + SSH port)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/linuxtools/main/os/autolinux.sh) -d 13 -p "YourPassword" --port 2222
```

---

### Ubuntu 24.04

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/linuxtools/main/os/autolinux.sh) -u 24
```

---

### Ubuntu 22.04

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/linuxtools/main/os/autolinux.sh) -u 22
```

---

### Full example

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harryheros/linuxtools/main/os/autolinux.sh) -u 24 -p "SecurePassword" --port 2222
```

---

## ⚠ DATA LOSS WARNING

This tool will completely erase the primary disk and reinstall the system.

All existing data will be permanently destroyed.

Use only on systems you own or are authorized to manage.

---

## ✨ Features

- Unified Debian and Ubuntu installer
- Works on BIOS and UEFI systems
- Cross-distribution execution (Debian, Ubuntu, CentOS, etc.)
- Uses official upstream sources only
- Deterministic and predictable deployment model
- High-speed Ubuntu deployment via cloud images
- Automated SSH access configuration
- Built-in network optimization (FQ + BBR)
- Conditional IPv6 support

---

## 📂 Supported Operating Systems

**Target:**

- Debian 13 (Trixie)
- Debian 12 (Bookworm) — default
- Debian 11 (Bullseye)

- Ubuntu 24.04 LTS (Noble) — default
- Ubuntu 22.04 LTS (Jammy)

---

## 🏗 Installation Architecture

### Debian

1. Download netboot installer  
2. Inject configuration  
3. Reboot into installer  

### Ubuntu

1. Download cloud image  
2. Modify via qemu-nbd  
3. Write directly to disk  

---

## 🛠 Parameters

```
-d [11|12|13]    Debian version
-u [22|24]       Ubuntu version
-p password      Root password
--port N         SSH port
-h               Help
```

---

## 🔐 Security Model

- No embedded credentials  
- Operator-controlled execution  
- Runs entirely on target system  

---

## 🧪 Tested Environments

- KVM virtual machines  
- Cloud VPS providers  
- BIOS / UEFI systems  

---

## ⚖ License

GPLv3

---

## 🔗 Repository

https://github.com/harryheros/linuxtools
