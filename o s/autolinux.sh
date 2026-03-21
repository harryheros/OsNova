#!/usr/bin/env bash
# ==============================================================================
# Project: AutoLinux - Unified Linux Auto-Installer
# Version: 2.0.1
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
ROOT_PASS=""
VERSION="2.0.1"
PASSWORD_WAS_GENERATED=0

generate_random_password() {
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 14
}

# --- Help ---
show_help() {
    echo -e "${CYAN}AutoLinux v${VERSION} - Unified Linux Auto-Installer${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  bash autolinux.sh [options]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${YELLOW}-d [11|12|13]${NC}       Install Debian (default: 12)"
    echo -e "  ${YELLOW}-u [22|24]${NC}          Install Ubuntu (default: 24)"
    echo -e "  ${YELLOW}-p password${NC}         Set root password (optional)"
    echo -e "  ${YELLOW}-port / --port N${NC}    Set SSH port (default: 22)"
    echo -e "  ${YELLOW}-h / --help${NC}         Show this help"
    echo ""
    echo -e "${BOLD}Notes:${NC}"
    echo -e "  • If ${YELLOW}-p${NC} is not provided, a random root password will be generated."
    echo -e "  • The generated password will be shown before reboot."
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  bash autolinux.sh"
    echo -e "  bash autolinux.sh -d 13"
    echo -e "  bash autolinux.sh -u"
    echo -e "  bash autolinux.sh -u 22"
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
            else
                echo -e "${RED}Error: Unsupported Debian version '$2'. (Available: 11, 12, 13)${NC}"; exit 1
            fi
            ;;
        -u)
            if [ "$DEBIAN_SET" -eq 1 ]; then
                echo -e "${RED}Error: Cannot use -d and -u together.${NC}"; exit 1
            fi
            UBUNTU_SET=1; OS_TYPE="ubuntu"
            if [[ "$2" =~ ^(22|24)$ ]]; then RELEASE="$2"; shift 2
            elif [[ -z "$2" || "$2" == -* ]]; then RELEASE="24"; shift 1
            else
                echo -e "${RED}Error: Unsupported Ubuntu version '$2'. (Available: 22, 24)${NC}"; exit 1
            fi
            ;;
        -p)
            if [ -z "$2" ] || [ "$2" == -* ]; then
                echo -e "${RED}Error: Password cannot be empty.${NC}"; exit 1
            fi
            ROOT_PASS="$2"; shift 2
            ;;
        -port|--port)
            if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 1 ] && [ "$2" -le 65535 ]; then
                SSH_PORT="$2"; shift 2
            else
                echo -e "${RED}Error: Invalid port number '$2' (1-65535)${NC}"; exit 1
            fi
            ;;
        -h|--help)
            show_help; exit 0
            ;;
        *)
            echo -e "${RED}Error: Invalid option '$1'${NC}"
            echo -e "${YELLOW}Hint: Use -d for Debian, -u for Ubuntu, -p for password, --port for SSH port.${NC}"
            exit 1
            ;;
    esac
done

if [ "$OS_TYPE" = "debian" ] && [ -z "$RELEASE" ]; then RELEASE="12"; fi
if [ "$OS_TYPE" = "ubuntu" ] && [ -z "$RELEASE" ]; then RELEASE="24"; fi

if [ -z "$ROOT_PASS" ]; then
    ROOT_PASS="$(generate_random_password)"
    PASSWORD_WAS_GENERATED=1
fi

clear
echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"
echo -e "${GREEN}${BOLD}            AutoLinux Unified Installer v${VERSION}${NC}"
echo -e "${GREEN}        Copyright (C) 2026 HarryLinux Tools / Harry${NC}"
echo -e "${CYAN}❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊❊${NC}"

if [ "$PASSWORD_WAS_GENERATED" -eq 1 ]; then
    echo -e "\n${YELLOW}${BOLD}No root password was provided.${NC}"
    echo -e "${YELLOW}A random password has been generated for this installation:${NC}"
    echo -e "${GREEN}${BOLD}${ROOT_PASS}${NC}"
    echo -e "${RED}${BOLD}Please save this password now. It will be required after installation.${NC}"
fi

echo -e "\n${BOLD}${CYAN}Step: Pre-installing essential tools...${NC}"
export DEBIAN_FRONTEND=noninteractive

IS_CENTOS7=0
if [ -f /etc/centos-release ] && grep -q "CentOS Linux release 7" /etc/centos-release; then
    IS_CENTOS7=1
    echo -e "${YELLOW}CentOS 7 detected (EOL). Ensuring Vault 7.9.2009 repo is available...${NC}"
    cat >/etc/yum.repos.d/autolinux-vault-7.9.2009.repo <<'VAULTEOF'
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
VAULTEOF
    yum clean all >/dev/null 2>&1 || true
fi

if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y util-linux wget ca-certificates kexec-tools tar gzip cpio \
        grub2-common cloud-guest-utils e2fsprogs qemu-utils gdisk
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y util-linux wget ca-certificates kexec-tools tar gzip cpio qemu-img gdisk \
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

# --- Cleanup trap (Ubuntu path) ---
cleanup() {
    umount /tmp/img_root_mnt 2>/dev/null || true
    umount /tmp/efi_fix_mnt  2>/dev/null || true
    qemu-nbd --disconnect /dev/nbd0 2>/dev/null || true
}
trap cleanup EXIT INT TERM

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

# IPv6 detection (optional — not all VPS have IPv6)
V_IP6=$(ip -6 addr show "$INTERFACE" | grep "inet6" | grep -v "fe80" | awk '{print $2}' | cut -d/ -f1 | head -n1)
V_PREFIX6=$(ip -6 addr show "$INTERFACE" | grep "inet6" | grep -v "fe80" | awk '{print $2}' | cut -d/ -f2 | head -n1)
V_GATEWAY6=$(ip -6 route | grep default | awk '{print $3}' | head -n1)

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
        *)    REL_NAME="noble"; FULL_VER="24.04" ;;
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
# ==============================================================================
install_debian() {
    echo -e "\n${BOLD}${CYAN}Step: Fetching Debian network installer...${NC}"

    MIRROR="https://deb.debian.org/debian/dists/${REL_NAME}/main/installer-amd64/current/images/netboot/"
    wget -O "${WORKDIR}/netboot.tar.gz" "${MIRROR}netboot.tar.gz"

    cat > "${WORKDIR}/post-install.sh" <<POSTINSTALL
#!/bin/sh
set -e
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port ${SSH_PORT}/g' /etc/ssh/sshd_config
sed -i 's/^Port .*/Port ${SSH_PORT}/g' /etc/ssh/sshd_config
echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
printf 'auto lo\niface lo inet loopback\n\n' > /etc/network/interfaces
printf "auto ${INTERFACE}\nallow-hotplug ${INTERFACE}\niface ${INTERFACE} inet static\n" >> /etc/network/interfaces
printf "    address ${V_IP}\n    netmask ${V_NETMASK}\n    gateway ${V_GATEWAY}\n    dns-nameservers 8.8.8.8 1.1.1.1\n\n" >> /etc/network/interfaces
if [ -n "${V_IP6}" ] && [ -n "${V_PREFIX6}" ]; then
    printf "iface ${INTERFACE} inet6 static\n" >> /etc/network/interfaces
    printf "    address ${V_IP6}\n    netmask ${V_PREFIX6}\n" >> /etc/network/interfaces
    if [ -n "${V_GATEWAY6}" ]; then
        printf "    gateway ${V_GATEWAY6}\n" >> /etc/network/interfaces
    fi
    printf "\n" >> /etc/network/interfaces
fi
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
    NET_APPEND="netcfg/disable_autoconfig=true netcfg/get_ipaddress=${V_IP} netcfg/get_netmask=${V_NETMASK} netcfg/get_gateway=${V_GATEWAY} netcfg/get_nameservers=\"8.8.8.8 1.1.1.1\" netcfg/confirm_static=true"
    KERNEL_APPEND="auto=true priority=critical file=/preseed.cfg locale=en_US.UTF-8 keymap=us hostname=debian ${NET_APPEND} vga=788 --- quiet"
    GRUB_TITLE="AutoLinux-Debian${RELEASE}"
    UBUNTU_CLOUD=0
}

# ==============================================================================
# UBUNTU INSTALLATION PATH
# NBD mount → chroot config → EFI fix → disconnect → convert → reboot
# ==============================================================================
install_ubuntu() {
    echo -e "\n${BOLD}${CYAN}Step: Installing Ubuntu via QCOW2 Cloud Image...${NC}"
    case "$RELEASE" in
        22) IMG_URL="https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img" ;;
        *)  IMG_URL="https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img" ;;
    esac

    IMG_PATH="/var/tmp/ubuntu-cloud.img"
    echo -e "${CYAN}Downloading Ubuntu cloud image (~600MB)...${NC}"
    wget --continue --show-progress -O "${IMG_PATH}" "${IMG_URL}"

    echo -e "${CYAN}Mounting QCOW2 image via NBD...${NC}"
    modprobe nbd max_part=16
    sleep 1
    qemu-nbd --disconnect /dev/nbd0 2>/dev/null || true
    qemu-nbd --connect=/dev/nbd0 "${IMG_PATH}"
    sleep 2

    IMG_ROOT=$(lsblk -lnp -o NAME,FSTYPE,SIZE /dev/nbd0 2>/dev/null | grep "ext4" | sort -hk3 | tail -n1 | awk '{print $1}')
    IMG_EFI=$(lsblk -lnp -o NAME,FSTYPE /dev/nbd0 2>/dev/null | grep "vfat" | head -n1 | awk '{print $1}')
    echo -e "${CYAN}Root: ${IMG_ROOT} | EFI: ${IMG_EFI}${NC}"

    ROOT_MNT="/tmp/img_root_mnt"
    mkdir -p "${ROOT_MNT}"
    mount -t ext4 "${IMG_ROOT}" "${ROOT_MNT}"

    # 1. Root password
    echo "root:${ROOT_PASS}" | chroot "${ROOT_MNT}" chpasswd

    # 2. SSH — patch main config + write .d override
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "${ROOT_MNT}/etc/ssh/sshd_config"
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "${ROOT_MNT}/etc/ssh/sshd_config"
    sed -i "s/^#\?Port .*/Port ${SSH_PORT}/" "${ROOT_MNT}/etc/ssh/sshd_config"
    mkdir -p "${ROOT_MNT}/etc/ssh/sshd_config.d"
    rm -f "${ROOT_MNT}/etc/ssh/sshd_config.d/"*
    cat > "${ROOT_MNT}/etc/ssh/sshd_config.d/99-autolinux.conf" <<EOF
PermitRootLogin yes
PasswordAuthentication yes
Port ${SSH_PORT}
EOF

    # 3. BBR
    cat > "${ROOT_MNT}/etc/sysctl.d/99-autolinux-bbr.conf" <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

    # 4. Static netplan — match en* and eth* to cover any interface name
    rm -f "${ROOT_MNT}/etc/netplan/"*.yaml

    # Build addresses list (IPv4 always, IPv6 if detected)
    if [ -n "$V_IP6" ] && [ -n "$V_PREFIX6" ] && [ -n "$V_GATEWAY6" ]; then
        NETPLAN_ADDRESSES="[${V_IP}/${V_PREFIX}, ${V_IP6}/${V_PREFIX6}]"
        NETPLAN_ROUTES="[{to: default, via: ${V_GATEWAY}}, {to: \"::/0\", via: \"${V_GATEWAY6}\"}]"
    else
        NETPLAN_ADDRESSES="[${V_IP}/${V_PREFIX}]"
        NETPLAN_ROUTES="[{to: default, via: ${V_GATEWAY}}]"
    fi

    cat > "${ROOT_MNT}/etc/netplan/99-static-ip.yaml" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    all-en:
      match: {name: "en*"}
      dhcp4: false
      dhcp6: false
      addresses: ${NETPLAN_ADDRESSES}
      routes: ${NETPLAN_ROUTES}
      nameservers: {addresses: [8.8.8.8, 1.1.1.1]}
    all-eth:
      match: {name: "eth*"}
      dhcp4: false
      dhcp6: false
      addresses: ${NETPLAN_ADDRESSES}
      routes: ${NETPLAN_ROUTES}
      nameservers: {addresses: [8.8.8.8, 1.1.1.1]}
EOF
    chmod 600 "${ROOT_MNT}/etc/netplan/99-static-ip.yaml"

    # 5. Disable cloud-init network generation
    mkdir -p "${ROOT_MNT}/etc/cloud/cloud.cfg.d"
    echo "network: {config: disabled}" > "${ROOT_MNT}/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"

    # 6. Cloud-init seed — only growpart/resize (dynamic disk name)
    REAL_DISK_BASE=$(basename "${REAL_DISK}")
    if echo "${REAL_DISK_BASE}" | grep -q "nvme"; then
        REAL_PART="${REAL_DISK}p1"
        REAL_PART_NUM="1"
    else
        REAL_PART="${REAL_DISK}1"
        REAL_PART_NUM="1"
    fi
    mkdir -p "${ROOT_MNT}/var/lib/cloud/seed/nocloud"
    cat > "${ROOT_MNT}/var/lib/cloud/seed/nocloud/meta-data" <<EOF
instance-id: i-$(date +%s)
local-hostname: ubuntu
EOF
    cat > "${ROOT_MNT}/var/lib/cloud/seed/nocloud/user-data" <<EOF
#cloud-config
runcmd:
  - growpart ${REAL_DISK} ${REAL_PART_NUM} || true
  - resize2fs ${REAL_PART} || true
EOF

    sync
    umount "${ROOT_MNT}"
    echo -e "${GREEN}Root filesystem configured!${NC}"

    # --- Fix EFI fallback path ---
    if [ -n "$IMG_EFI" ] && [ -b "$IMG_EFI" ]; then
        echo -e "${CYAN}Fixing EFI fallback path...${NC}"
        EFI_MNT="/tmp/efi_fix_mnt"
        mkdir -p "${EFI_MNT}"
        if mount -t vfat "${IMG_EFI}" "${EFI_MNT}" 2>/dev/null; then
            mkdir -p "${EFI_MNT}/EFI/BOOT"
            if [ -f "${EFI_MNT}/EFI/ubuntu/shimx64.efi" ]; then
                cp "${EFI_MNT}/EFI/ubuntu/shimx64.efi" "${EFI_MNT}/EFI/BOOT/BOOTX64.EFI"
                cp "${EFI_MNT}/EFI/ubuntu/grubx64.efi" "${EFI_MNT}/EFI/BOOT/grubx64.efi" 2>/dev/null || true
                echo -e "${GREEN}EFI/BOOT/BOOTX64.EFI written!${NC}"
            fi
            sync
            umount "${EFI_MNT}"
        fi
    fi

    qemu-nbd --disconnect /dev/nbd0
    sleep 1

    echo -e "${CYAN}Writing image to ${REAL_DISK}...${NC}"
    qemu-img convert -f qcow2 -O raw -p "${IMG_PATH}" "${REAL_DISK}"

    echo -e "${CYAN}Fixing GPT backup header...${NC}"
    sgdisk -e "${REAL_DISK}" 2>/dev/null || true
    partx -u "${REAL_DISK}" 2>/dev/null || true
    partprobe "${REAL_DISK}" 2>/dev/null || true

    echo -e "${GREEN}Ubuntu written to disk!${NC}"
    GRUB_TITLE=""
    UBUNTU_CLOUD=1
}

# --- Run installer ---
if [ "$OS_TYPE" = "debian" ]; then
    install_debian
else
    install_ubuntu
fi

# ==============================================================================
# GRUB CONFIGURATION (Debian only)
# ==============================================================================
if [ "$OS_TYPE" = "debian" ]; then
    echo -e "\n${BOLD}${CYAN}Step: Patching GRUB bootloader (Debian)...${NC}"

    BOOT_UUID=$(/usr/sbin/grub-probe --target=fs_uuid /boot 2>/dev/null || grub-probe --target=fs_uuid /boot)
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
    echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
    update-grub || grub2-mkconfig -o /boot/grub/grub.cfg
fi

# ==============================================================================
# SUMMARY
# ==============================================================================
echo -e "\n${CYAN}◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎${NC}"
echo -e "${GREEN}${BOLD}                 AutoLinux Installation Summary${NC}"
echo -e "${CYAN}◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎◎${NC}"
echo -e "  OS       : ${YELLOW}${DISPLAY_NAME}${NC}"
echo -e "  Disk     : ${YELLOW}${REAL_DISK}${NC}"
echo -e "  IP       : ${YELLOW}${V_IP}/${V_PREFIX}${NC}"
echo -e "  Gateway  : ${YELLOW}${V_GATEWAY}${NC}"
[ -n "$V_IP6" ] && echo -e "  IPv6     : ${YELLOW}${V_IP6}/${V_PREFIX6}${NC}"
echo -e "  SSH Port : ${YELLOW}${SSH_PORT}${NC}"

if [ "$PASSWORD_WAS_GENERATED" -eq 1 ]; then
    echo -e "  Password : ${YELLOW}${ROOT_PASS}${NC} ${RED}(generated automatically — save it now)${NC}"
else
    echo -e "  Password : ${GREEN}(custom password set)${NC}"
fi

echo -e "${CYAN}◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌◌${NC}"

if [ "$PASSWORD_WAS_GENERATED" -eq 1 ]; then
    echo -e "\n${RED}${BOLD}IMPORTANT: Save the generated root password before reboot:${NC} ${YELLOW}${ROOT_PASS}${NC}"
fi

echo -ne "\nRebooting in "
for i in {10..1}; do echo -n "$i... "; sleep 1; done
echo -e "\n${RED}${BOLD}Rebooting now!${NC}"
sync && sleep 2

if [ "$OS_TYPE" = "debian" ]; then
    reboot -f
else
    pkill -TERM sshd 2>/dev/null || true
    sleep 1
    echo 1 > /proc/sys/kernel/sysrq 2>/dev/null || true
    echo b > /proc/sysrq-trigger 2>/dev/null || true
    reboot -f -n 2>/dev/null || true
    systemctl reboot --force --force 2>/dev/null || true
    python3 -c "import ctypes; ctypes.CDLL('libc.so.6').reboot(0x1234567)" 2>/dev/null || true
fi
