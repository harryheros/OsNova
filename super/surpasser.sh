#!/usr/bin/env bash
# ==============================================================================
# Project: Surpasser Debian Auto-Installer
# Version: 1.3.8
# Description: High-performance, BIOS + UEFI compatible automated network
#              installer for Debian systems.
#
# Author: Harry / HarryLinux Tools
# GitHub: https://github.com/harryheros/LinuxTools
# Copyright (C) 2026 HarryLinux Tools.
#
# License: GNU General Public License v3.0 (GPL-3.0)
# ==============================================================================

set -e

# --- Color and Formatting ---
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
BOLD='\033[1m'

# --- Defaults ---
RELEASE="12"; SSH_PORT="22"; ROOT_PASS="Harry888"; VERSION="1.3.8"
DEFAULT_PASSWORD_USED=1  # Only show reminder when default password is used

# --- Argument Parsing & Invalid Option Interception ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d)
            if [[ "$2" =~ ^(11|12|13)$ ]]; then
                RELEASE="$2"; shift 2
            else
                echo -e "${RED}Error: Unsupported Debian version '$2'. (Available: 11, 12, 13)${NC}"
                exit 1
            fi
            ;;
        -p)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Password cannot be empty.${NC}"
                exit 1
            fi
            ROOT_PASS="$2"
            DEFAULT_PASSWORD_USED=0
            shift 2
            ;;
        -port|--port)
            if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 1 ] && [ "$2" -le 65535 ]; then
                SSH_PORT="$2"; shift 2
            else
                echo -e "${RED}Error: Invalid port number '$2' (1-65535)${NC}"
                exit 1
            fi
            ;;
        -h|--help)
            echo -e "${CYAN}Usage: bash surpasser.sh [-d 11|12|13] [-p password] [--port number]${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Invalid option '$1'${NC}"
            echo -e "${YELLOW}Hint: Use -d for version, -p for password, --port for SSH port.${NC}"
            exit 1
            ;;
    esac
done

clear
echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"
echo -e "${GREEN}${BOLD}          Surpasser Linux Auto-Installer v${VERSION}${NC}"
echo -e "${GREEN}      Copyright (C) 2026 HarryLinux Tools / Harry${NC}"
echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"

echo -e "\n${BOLD}${CYAN}Step: Pre-installing essential tools...${NC}"

export DEBIAN_FRONTEND=noninteractive

IS_CENTOS7=0
if [ -f /etc/centos-release ] && grep -q "CentOS Linux release 7" /etc/centos-release; then
    IS_CENTOS7=1
    echo -e "${YELLOW}CentOS 7 detected (EOL). Ensuring Vault 7.9.2009 repo is available...${NC}"

    # Write a minimal deterministic Vault repo (do not touch existing repo files)
    cat >/etc/yum.repos.d/surpasser-vault-7.9.2009.repo <<'EOF'
[surpasser-vault-base]
name=Surpasser Vault 7.9.2009 - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
enabled=1
gpgcheck=0

[surpasser-vault-updates]
name=Surpasser Vault 7.9.2009 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
enabled=1
gpgcheck=0

[surpasser-vault-extras]
name=Surpasser Vault 7.9.2009 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
enabled=1
gpgcheck=0
EOF

    yum clean all >/dev/null 2>&1 || true
fi

if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y util-linux wget ca-certificates kexec-tools tar gzip cpio grub2-common

elif command -v dnf >/dev/null 2>&1; then
    dnf install -y util-linux wget ca-certificates kexec-tools tar gzip cpio grub2 grub2-tools
    # Fix for CentOS/RHEL family: Create a symlink so later code finds 'grub-probe'
    [ ! -f /usr/sbin/grub-probe ] && [ -f /usr/sbin/grub2-probe ] && ln -sf /usr/sbin/grub2-probe /usr/sbin/grub-probe

elif command -v yum >/dev/null 2>&1; then
    if [ "$IS_CENTOS7" -eq 1 ]; then
        # Ignore broken/duplicate system repos completely; use only our vault repo
        yum --disablerepo="*" --enablerepo="surpasser-vault-*" install -y util-linux wget ca-certificates kexec-tools tar gzip cpio grub2 grub2-tools
    else
        yum install -y util-linux wget ca-certificates kexec-tools tar gzip cpio grub2 grub2-tools
    fi
    [ ! -f /usr/sbin/grub-probe ] && [ -f /usr/sbin/grub2-probe ] && ln -sf /usr/sbin/grub2-probe /usr/sbin/grub-probe

else
    echo -e "${RED}Error: Package manager not found. Please install wget manually.${NC}"
    exit 1
fi

echo -e "\n${BOLD}${CYAN}Step: Detecting environment and network...${NC}"

# --- Disk Detection ---
REAL_DISK=""
if [ -d /sys/block ]; then
    for dev in $(ls /sys/block | grep -E '^(sd|vd|nvme|hd)'); do
        if [ -f "/sys/block/$dev/removable" ] && [ "$(cat /sys/block/$dev/removable)" = "0" ]; then
            REAL_DISK="/dev/$dev"
            break
        fi
    done
fi
if [ -z "$REAL_DISK" ] && command -v lsblk >/dev/null; then
    REAL_DISK="/dev/$(lsblk -dn -o NAME | head -n1)"
fi
[ -z "$REAL_DISK" ] && REAL_DISK="/dev/sda"

# --- Network Detection ---
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
V_IP=$(ip -4 addr show "$INTERFACE" | grep inet | awk '{print $2}' | cut -d/ -f1)
V_GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
V_PREFIX=$(ip -4 addr show "$INTERFACE" | grep inet | awk '{print $2}' | cut -d/ -f2)

prefix_to_mask() {
    local i mask=""
    local full_octets=$(($1 / 8))
    local partial_octet=$(($1 % 8))
    for ((i=0; i<4; i++)); do
        if [ $i -lt $full_octets ]; then mask+="255"
        elif [ $i -eq $full_octets ]; then mask+=$((256 - 2**(8-partial_octet)))
        else mask+="0"; fi
        [ $i -lt 3 ] && mask+="."
    done
    echo "$mask"
}
V_NETMASK=$(prefix_to_mask "$V_PREFIX")

echo -e "      Target OS : ${YELLOW}Debian ${RELEASE}${NC}"
echo -e "      Root Disk : ${YELLOW}${REAL_DISK}${NC}"
echo -e "      IP Config : ${YELLOW}${V_IP} / ${V_NETMASK}${NC}"

echo -e "\n${BOLD}${CYAN}Step: Fetching network installer...${NC}"
case "$RELEASE" in
    "11") REL_NAME="bullseye" ;;
    "12") REL_NAME="bookworm" ;;
    *) REL_NAME="trixie" ;;
esac

MIRROR="https://deb.debian.org/debian/dists/${REL_NAME}/main/installer-amd64/current/images/netboot/"
WORKDIR="/var/tmp/netinst"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

# CentOS 7 wget is old: do NOT use --show-progress
wget -O "${WORKDIR}/netboot.tar.gz" "${MIRROR}netboot.tar.gz"

# --- Preseed Configuration with Optimized Dynamic Interface Fix ---
cat > "${WORKDIR}/preseed.cfg" <<EOF
d-i debconf/priority string critical
d-i auto-install/enable boolean true
d-i debian-installer/locale string en_US.UTF-8
d-i console-setup/ask_detect boolean false
d-i keyboard-configuration/xkb-keymap select us
d-i netcfg/choose_interface select auto
d-i netcfg/disable_autoconfig boolean true
d-i netcfg/get_ipaddress string ${V_IP}
d-i netcfg/get_netmask string ${V_NETMASK}
d-i netcfg/get_gateway string ${V_GATEWAY}
d-i netcfg/get_nameservers string 8.8.8.8 1.1.1.1
d-i netcfg/confirm_static boolean true

tasksel tasksel/first multiselect standard, ssh-server

d-i partman-auto/disk string ${REAL_DISK}
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string ${REAL_DISK}

d-i passwd/make-user boolean false
d-i passwd/root-password password ${ROOT_PASS}
d-i passwd/root-password-again password ${ROOT_PASS}
d-i finish-install/reboot_in_progress note

d-i preseed/late_command string in-target sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config; \\
    in-target sed -i 's/#Port 22/Port ${SSH_PORT}/g' /etc/ssh/sshd_config; \\
    in-target sed -i 's/^Port .*/Port ${SSH_PORT}/g' /etc/ssh/sshd_config; \\
    in-target sh -c "echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf"; \\
    in-target sh -c "echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf"; \\
    in-target sh -c "printf 'auto lo\niface lo inet loopback\n\n' > /etc/network/interfaces; for iface in \\\$(ip -o link show | awk -F': ' '{print \\\$2}' | grep -v lo); do printf \"auto \\\$iface\nallow-hotplug \\\$iface\niface \\\$iface inet static\n    address ${V_IP}\n    netmask ${V_NETMASK}\n    gateway ${V_GATEWAY}\n    dns-nameservers 8.8.8.8 1.1.1.1\n\n\" >> /etc/network/interfaces; done"
EOF

# --- Process initrd ---
cd "$WORKDIR" && tar -xzf netboot.tar.gz
mkdir -p initrd_work && cd initrd_work
gzip -dc "../debian-installer/amd64/initrd.gz" | cpio -idmu >/dev/null 2>&1
cp "${WORKDIR}/preseed.cfg" ./preseed.cfg

# Clean old versions and write new kernel with numerical prefix to satisfy dpkg syntax
rm -f /boot/vmlinuz-*surpasser /boot/initrd-*surpasser.gz 2>/dev/null
find . | cpio -H newc -o 2>/dev/null | gzip -1 > /boot/initrd-${RELEASE}-surpasser.gz
cp "${WORKDIR}/debian-installer/amd64/linux" /boot/vmlinuz-${RELEASE}-surpasser

echo -e "\n${BOLD}${CYAN}Step: Patching GRUB bootloader...${NC}"
BOOT_UUID=$(/usr/sbin/grub-probe --target=fs_uuid /boot 2>/dev/null || grub-probe --target=fs_uuid /boot)
NET_APPEND="netcfg/disable_autoconfig=true netcfg/get_ipaddress=${V_IP} netcfg/get_netmask=${V_NETMASK} netcfg/get_gateway=${V_GATEWAY} netcfg/get_nameservers=8.8.8.8 netcfg/confirm_static=true"
APPEND="auto=true priority=critical file=/preseed.cfg locale=en_US.UTF-8 keymap=us hostname=debian $NET_APPEND vga=788 --- quiet"

# --- Create Custom GRUB Entry with Path Fix ---
cat > /etc/grub.d/40_custom <<EOF
#!/bin/sh
exec tail -n +3 \$0
menuentry 'Surpasser-AutoInstall' {
    load_video
    insmod gzio
    insmod part_gpt
    insmod part_msdos
    insmod ext2
    search --no-floppy --fs-uuid --set=root ${BOOT_UUID}
    if [ -f /boot/vmlinuz-${RELEASE}-surpasser ]; then
        linux /boot/vmlinuz-${RELEASE}-surpasser $APPEND
        initrd /boot/initrd-${RELEASE}-surpasser.gz
    else
        linux /vmlinuz-${RELEASE}-surpasser $APPEND
        initrd /initrd-${RELEASE}-surpasser.gz
    fi
}
EOF
chmod +x /etc/grub.d/40_custom

sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Surpasser-AutoInstall"/' /etc/default/grub

# Silence os-prober warnings
if [ -f /etc/default/grub ]; then
    sed -i '/GRUB_DISABLE_OS_PROBER/d' /etc/default/grub
    echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
fi

echo -e "\n${BOLD}${CYAN}Step: Updating GRUB configuration...${NC}"
if command -v update-grub >/dev/null 2>&1; then
    update-grub
else
    GRUB_CFG_PATH=$(find /boot/grub2 /boot/grub /etc -name grub.cfg 2>/dev/null | head -n1)
    [ -z "$GRUB_CFG_PATH" ] && GRUB_CFG_PATH="/boot/grub2/grub.cfg"
    grub2-mkconfig -o "$GRUB_CFG_PATH"
fi

echo -e "\n${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"
echo -e "${GREEN}[✔] Ready! (v${VERSION})${NC}  Target: ${CYAN}Debian ${RELEASE}${NC}"
echo -e "SSH Port: ${YELLOW}${SSH_PORT}${NC}  Password: ${YELLOW}${ROOT_PASS}${NC}"
echo -e "${RED}${BOLD}ATTENTION: The installation takes 5-15 minutes.${NC}"
echo -e "${RED}${BOLD}The system will reboot automatically when finished.${NC}"

if [ "$DEFAULT_PASSWORD_USED" -eq 1 ]; then
    echo -e "\nDefault root password is set to avoid reinstall lockout."
    echo -e "Please change it after first login."
fi

echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"

echo -ne "\nRebooting in "
for i in {10..1}; do echo -n "$i... "; sleep 1; done
echo -e "\n${RED}${BOLD}Rebooting now!${NC}"
sync && reboot -f
