#!/usr/bin/env bash
# ==============================================================================
# Project: AutoLinux - Unified Linux Auto-Installer
# Version: 2.0.0
# Description: High-performance, BIOS + UEFI compatible automated network
#              installer for Debian and Ubuntu systems.
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
OS_TYPE="debian"
RELEASE=""
SSH_PORT="22"
ROOT_PASS="Harry888"
VERSION="2.0.0"
DEFAULT_PASSWORD_USED=1

# --- Help ---
show_help() {
    echo -e "${CYAN}AutoLinux v${VERSION} - Unified Linux Auto-Installer${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  bash autolinux.sh [options]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${YELLOW}-d [11|12|13]${NC}       Install Debian (default: 12)"
    echo -e "  ${YELLOW}-u [22|24]${NC}           Install Ubuntu (default: 24)"
    echo -e "  ${YELLOW}-p password${NC}          Set root password (default: Harry888)"
    echo -e "  ${YELLOW}-port / --port N${NC}     Set SSH port (default: 22)"
    echo -e "  ${YELLOW}-h / --help${NC}          Show this help"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  bash autolinux.sh                  # Debian 12 (default)"
    echo -e "  bash autolinux.sh -d 13            # Debian 13"
    echo -e "  bash autolinux.sh -u               # Ubuntu 24.04"
    echo -e "  bash autolinux.sh -u 22            # Ubuntu 22.04"
    echo -e "  bash autolinux.sh -u 24 -p mypass --port 2222"
}

# --- Argument Parsing ---
DEBIAN_SET=0
UBUNTU_SET=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d)
            if [ "$UBUNTU_SET" -eq 1 ]; then
                echo -e "${RED}Error: Cannot use -d and -u together.${NC}"; exit 1
            fi
            DEBIAN_SET=1; OS_TYPE="debian"
            if [[ "$2" =~ ^(11|12|13)$ ]]; then RELEASE="$2"; shift 2
            elif [[ -z "$2" || "$2" == -* ]]; then RELEASE="12"; shift 1
            else echo -e "${RED}Error: Unsupported Debian version '$2'. (Available: 11, 12, 13)${NC}"; exit 1
            fi ;;
        -u)
            if [ "$DEBIAN_SET" -eq 1 ]; then
                echo -e "${RED}Error: Cannot use -d and -u together.${NC}"; exit 1
            fi
            UBUNTU_SET=1; OS_TYPE="ubuntu"
            if [[ "$2" =~ ^(22|24)$ ]]; then RELEASE="$2"; shift 2
            elif [[ -z "$2" || "$2" == -* ]]; then RELEASE="24"; shift 1
            else echo -e "${RED}Error: Unsupported Ubuntu version '$2'. (Available: 22, 24)${NC}"; exit 1
            fi ;;
        -p)
            if [ -z "$2" ]; then echo -e "${RED}Error: Password cannot be empty.${NC}"; exit 1; fi
            ROOT_PASS="$2"; DEFAULT_PASSWORD_USED=0; shift 2 ;;
        -port|--port)
            if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 1 ] && [ "$2" -le 65535 ]; then
                SSH_PORT="$2"; shift 2
            else echo -e "${RED}Error: Invalid port number '$2' (1-65535)${NC}"; exit 1
            fi ;;
        -h|--help) show_help; exit 0 ;;
        *)
            echo -e "${RED}Error: Invalid option '$1'${NC}"
            echo -e "${YELLOW}Hint: Use -d for Debian, -u for Ubuntu, -p for password, --port for SSH port.${NC}"
            exit 1 ;;
    esac
done

if [ "$OS_TYPE" = "debian" ] && [ -z "$RELEASE" ]; then RELEASE="12"; fi
if [ "$OS_TYPE" = "ubuntu" ] && [ -z "$RELEASE" ]; then RELEASE="24"; fi

clear
echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"
echo -e "${GREEN}${BOLD}            AutoLinux Unified Installer v${VERSION}${NC}"
echo -e "${GREEN}        Copyright (C) 2026 HarryLinux Tools / Harry${NC}"
echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"

echo -e "\n${BOLD}${CYAN}Step: Pre-installing essential tools...${NC}"
export DEBIAN_FRONTEND=noninteractive

IS_CENTOS7=0
if [ -f /etc/centos-release ] && grep -q "CentOS Linux release 7" /etc/centos-release; then
    IS_CENTOS7=1
    echo -e "${YELLOW}CentOS 7 detected (EOL). Ensuring Vault 7.9.2009 repo is available...${NC}"
    cat >/etc/yum.repos.d/autolinux-vault-7.9.2009.repo <<'EOF'
[autolinux-vault-base]
name=AutoLinux Vault 7.9.2009 - Base
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
enabled=1
gpgcheck=0

[autolinux-vault-updates]
name=AutoLinux Vault 7.9.2009 - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
enabled=1
gpgcheck=0

[autolinux-vault-extras]
name=AutoLinux Vault 7.9.2009 - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
enabled=1
gpgcheck=0
EOF
    yum clean all >/dev/null 2>&1 || true
fi

if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y util-linux wget ca-certificates kexec-tools tar gzip cpio \
        grub2-common cloud-guest-utils e2fsprogs
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y util-linux wget ca-certificates kexec-tools tar gzip cpio \
        grub2 grub2-tools cloud-utils-growpart e2fsprogs
    [ ! -f /usr/sbin/grub-probe ] && [ -f /usr/sbin/grub2-probe ] && \
        ln -sf /usr/sbin/grub2-probe /usr/sbin/grub-probe
elif command -v yum >/dev/null 2>&1; then
    if [ "$IS_CENTOS7" -eq 1 ]; then
        yum --disablerepo="*" --enablerepo="autolinux-vault-*" install -y \
            util-linux wget ca-certificates kexec-tools tar gzip cpio \
            grub2 grub2-tools cloud-utils-growpart e2fsprogs
    else
        yum install -y util-linux wget ca-certificates kexec-tools tar gzip cpio \
            grub2 grub2-tools cloud-utils-growpart e2fsprogs
    fi
    [ ! -f /usr/sbin/grub-probe ] && [ -f /usr/sbin/grub2-probe ] && \
        ln -sf /usr/sbin/grub2-probe /usr/sbin/grub-probe
else
    echo -e "${RED}Error: Package manager not found. Please install wget manually.${NC}"; exit 1
fi

echo -e "\n${BOLD}${CYAN}Step: Detecting environment and network...${NC}"

# --- Disk Detection ---
REAL_DISK=""
if [ -d /sys/block ]; then
    for dev in $(ls /sys/block | grep -E '^(sd|vd|nvme|hd)'); do
        if [ -f "/sys/block/$dev/removable" ] && [ "$(cat /sys/block/$dev/removable)" = "0" ]; then
            REAL_DISK="/dev/$dev"; break
        fi
    done
fi
if [ -z "$REAL_DISK" ] && command -v lsblk >/dev/null; then
    REAL_DISK="/dev/$(lsblk -dn -o NAME | head -n1)"
fi
if [ -z "$REAL_DISK" ]; then
    REAL_DISK="/dev/sda"
    echo -e "${YELLOW}Warning: Disk auto-detection failed, defaulting to /dev/sda${NC}"
    echo -e "${YELLOW}If this is wrong, press Ctrl+C within 10 seconds to abort.${NC}"
    sleep 10
fi

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

# --- Resolve display names ---
if [ "$OS_TYPE" = "debian" ]; then
    case "$RELEASE" in
        "11") REL_NAME="bullseye" ;;
        "12") REL_NAME="bookworm" ;;
        *)    REL_NAME="trixie"   ;;
    esac
    DISPLAY_NAME="Debian ${RELEASE} (${REL_NAME})"
else
    case "$RELEASE" in
        "22") REL_NAME="jammy"; FULL_VER="22.04" ;;
        *)    REL_NAME="noble"; FULL_VER="24.04"  ;;
    esac
    DISPLAY_NAME="Ubuntu ${FULL_VER} (${REL_NAME})"
fi

echo -e "      Target OS : ${YELLOW}${DISPLAY_NAME}${NC}"
echo -e "      Root Disk : ${YELLOW}${REAL_DISK}${NC}"
echo -e "      IP Config : ${YELLOW}${V_IP} / ${V_NETMASK}${NC}"

WORKDIR="/var/tmp/autolinux"
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR"

# ==============================================================================
# DEBIAN INSTALLATION PATH
# Netboot preseed — identical to surpasser.sh 1.3.8
# ==============================================================================
install_debian() {
    echo -e "\n${BOLD}${CYAN}Step: Fetching Debian network installer...${NC}"

    MIRROR="https://deb.debian.org/debian/dists/${REL_NAME}/main/installer-amd64/current/images/netboot/"
    wget -O "${WORKDIR}/netboot.tar.gz" "${MIRROR}netboot.tar.gz"

    cat > "${WORKDIR}/post-install.sh" <<POSTINSTALL
#!/bin/sh
set -e
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port ${SSH_PORT}/g' /etc/ssh/sshd_config
sed -i 's/^Port .*/Port ${SSH_PORT}/g' /etc/ssh/sshd_config
echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
printf 'auto lo\niface lo inet loopback\n\n' > /etc/network/interfaces
for iface in \$(ip -o link show | awk -F': ' '{print \$2}' | grep -v lo); do
    printf "auto \$iface\nallow-hotplug \$iface\niface \$iface inet static\n"
    printf "    address ${V_IP}\n    netmask ${V_NETMASK}\n    gateway ${V_GATEWAY}\n    dns-nameservers 8.8.8.8 1.1.1.1\n\n"
done >> /etc/network/interfaces
POSTINSTALL
    chmod +x "${WORKDIR}/post-install.sh"

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

d-i preseed/late_command string \
    cp /post-install.sh /target/tmp/post-install.sh; \
    in-target chmod +x /tmp/post-install.sh; \
    in-target /tmp/post-install.sh
EOF

    cd "$WORKDIR" && tar -xzf netboot.tar.gz
    mkdir -p initrd_work && cd initrd_work
    gzip -dc "../debian-installer/amd64/initrd.gz" | cpio -idmu >/dev/null 2>&1
    cp "${WORKDIR}/preseed.cfg" ./preseed.cfg
    cp "${WORKDIR}/post-install.sh" ./post-install.sh

    rm -f /boot/vmlinuz-*autolinux /boot/initrd-*autolinux.gz 2>/dev/null
    find . | cpio -H newc -o 2>/dev/null | gzip -1 > /boot/initrd-debian${RELEASE}-autolinux.gz
    cp "${WORKDIR}/debian-installer/amd64/linux" /boot/vmlinuz-debian${RELEASE}-autolinux

    KERNEL_PATH="/boot/vmlinuz-debian${RELEASE}-autolinux"
    INITRD_PATH="/boot/initrd-debian${RELEASE}-autolinux.gz"
    NET_APPEND="netcfg/disable_autoconfig=true netcfg/get_ipaddress=${V_IP} netcfg/get_netmask=${V_NETMASK} netcfg/get_gateway=${V_GATEWAY} netcfg/get_nameservers=8.8.8.8 netcfg/confirm_static=true"
    KERNEL_APPEND="auto=true priority=critical file=/preseed.cfg locale=en_US.UTF-8 keymap=us hostname=debian ${NET_APPEND} vga=788 --- quiet"
    GRUB_TITLE="AutoLinux-Debian${RELEASE}"
    UBUNTU_CLOUD=0
}

# ==============================================================================
# UBUNTU INSTALLATION PATH
# Cloud image + cloud-init injection → dd → reboot
# No partition table manipulation needed on live disk
# ==============================================================================
install_ubuntu() {
    echo -e "\n${BOLD}${CYAN}Step: Installing Ubuntu from official cloud image...${NC}"

    case "$RELEASE" in
        22) IMG_URL="https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img" ;;
        *)  IMG_URL="https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img" ;;
    esac

    IMG_NAME="$(basename "$IMG_URL")"
    IMG_PATH="${WORKDIR}/${IMG_NAME}"

    echo -e "${CYAN}Downloading Ubuntu cloud image (~600MB)...${NC}"
    wget --continue -O "${IMG_PATH}" "${IMG_URL}"

    # --- Mount image and inject cloud-init config BEFORE dd ---
    echo -e "${CYAN}Injecting cloud-init configuration into image...${NC}"
    LOOPDEV="$(losetup --find --show -P "${IMG_PATH}")"
    SRC_PART="${LOOPDEV}p1"
    if [ ! -b "${SRC_PART}" ]; then
        losetup -d "${LOOPDEV}" || true
        echo -e "${RED}Error: Could not find root partition in cloud image.${NC}"; exit 1
    fi

    SOURCE_MNT="${WORKDIR}/source_img"
    mkdir -p "${SOURCE_MNT}"
    mount "${SRC_PART}" "${SOURCE_MNT}"

    # Write cloud-init user-data (nocloud datasource)
    mkdir -p "${SOURCE_MNT}/var/lib/cloud/seed/nocloud"

    cat > "${SOURCE_MNT}/var/lib/cloud/seed/nocloud/meta-data" <<EOF
instance-id: autolinux-$(date +%s)
local-hostname: ubuntu
EOF

    HASHED_PASS="$(openssl passwd -6 "${ROOT_PASS}")"
    cat > "${SOURCE_MNT}/var/lib/cloud/seed/nocloud/user-data" <<EOF
#cloud-config
hostname: ubuntu
manage_etc_hosts: true

# Root login
disable_root: false
ssh_pwauth: true
chpasswd:
  list: |
    root:${ROOT_PASS}
  expire: false

# Network (written to netplan)
write_files:
  - path: /etc/netplan/99-autolinux.yaml
    permissions: '0600'
    content: |
      network:
        version: 2
        ethernets:
          ${INTERFACE}:
            dhcp4: false
            addresses:
              - ${V_IP}/${V_PREFIX}
            routes:
              - to: default
                via: ${V_GATEWAY}
            nameservers:
              addresses: [8.8.8.8, 1.1.1.1]
  - path: /etc/ssh/sshd_config.d/99-autolinux.conf
    content: |
      PermitRootLogin yes
      PasswordAuthentication yes
      Port ${SSH_PORT}
  - path: /etc/sysctl.d/99-autolinux-bbr.conf
    content: |
      net.core.default_qdisc=fq
      net.ipv4.tcp_congestion_control=bbr
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}

runcmd:
  - netplan apply || true
  - systemctl restart ssh || systemctl restart sshd || true
  - growpart /dev/sda 1 || true
  - resize2fs /dev/sda1 || true
EOF

    umount "${SOURCE_MNT}" || true
    losetup -d "${LOOPDEV}" || true

    # --- dd image to disk ---
    echo -e "${CYAN}Writing cloud image to ${REAL_DISK} via dd...${NC}"
    dd if="${IMG_PATH}" of="${REAL_DISK}" bs=4M status=progress conv=fsync

    UBUNTU_CLOUD=1
    GRUB_TITLE=""
}
# --- Run the appropriate installer ---
if [ "$OS_TYPE" = "debian" ]; then
    install_debian
else
    install_ubuntu
fi

# ==============================================================================
# GRUB CONFIGURATION
# Debian only — Ubuntu cloud image handles its own GRUB inside chroot
# ==============================================================================
if [ "${UBUNTU_CLOUD:-0}" -eq 0 ]; then
    echo -e "\n${BOLD}${CYAN}Step: Patching GRUB bootloader...${NC}"

    BOOT_UUID=$(/usr/sbin/grub-probe --target=fs_uuid /boot 2>/dev/null || \
                grub-probe --target=fs_uuid /boot)

    KERN_BN="$(basename "${KERNEL_PATH}")"
    INIT_BN="$(basename "${INITRD_PATH}")"

    cat > /etc/grub.d/40_custom <<EOF
#!/bin/sh
exec tail -n +3 \$0
menuentry '${GRUB_TITLE}' {
    load_video
    insmod gzio
    insmod part_gpt
    insmod part_msdos
    insmod ext2
    search --no-floppy --fs-uuid --set=root ${BOOT_UUID}
    if [ -f /boot/${KERN_BN} ]; then
        linux /boot/${KERN_BN} ${KERNEL_APPEND}
        initrd /boot/${INIT_BN}
    else
        linux /${KERN_BN} ${KERNEL_APPEND}
        initrd /${INIT_BN}
    fi
}
EOF
    chmod +x /etc/grub.d/40_custom

    sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=\"${GRUB_TITLE}\"/" /etc/default/grub
    sed -i '/GRUB_DISABLE_OS_PROBER/d' /etc/default/grub
    echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub

    echo -e "\n${BOLD}${CYAN}Step: Updating GRUB configuration...${NC}"
    if command -v update-grub >/dev/null 2>&1; then
        update-grub
    else
        GRUB_CFG_PATH=$(find /boot/grub2 /boot/grub /etc -name grub.cfg 2>/dev/null | head -n1)
        [ -z "$GRUB_CFG_PATH" ] && GRUB_CFG_PATH="/boot/grub2/grub.cfg"
        grub2-mkconfig -o "$GRUB_CFG_PATH"
    fi
fi

# ==============================================================================
# SUMMARY & REBOOT
# ==============================================================================
echo -e "\n${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"
echo -e "${GREEN}[✔] Ready! (v${VERSION})${NC}  Target: ${CYAN}${DISPLAY_NAME}${NC}"
echo -e "    Disk     : ${YELLOW}${REAL_DISK}${NC}"
echo -e "    IP       : ${YELLOW}${V_IP}${NC}"
echo -e "    SSH Port : ${YELLOW}${SSH_PORT}${NC}"
echo -e "    Password : ${YELLOW}${ROOT_PASS}${NC}"

if [ "${UBUNTU_CLOUD:-0}" -eq 1 ]; then
    echo -e "${RED}${BOLD}ATTENTION: Ubuntu written to disk. Rebooting directly into Ubuntu.${NC}"
else
    echo -e "${RED}${BOLD}ATTENTION: Installation takes 5-30 minutes depending on network speed.${NC}"
    echo -e "${RED}${BOLD}The system will reboot automatically when finished.${NC}"
fi

if [ "$DEFAULT_PASSWORD_USED" -eq 1 ]; then
    echo -e "\n${YELLOW}Default root password is set. Please change it after first login.${NC}"
fi

echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"

echo -ne "\nRebooting in "
for i in {10..1}; do echo -n "$i... "; sleep 1; done
echo -e "\n${RED}${BOLD}Rebooting now!${NC}"
sync && reboot -f
