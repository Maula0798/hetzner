#!/bin/bash
set -e

clear

echo "========================================"
echo "      HETZNER WINDOWS INSTALLER"
echo "               v1.0"
echo "========================================"
echo ""

read -p "Masukkan URL ISO Windows (Enter = Default): " ISO_URL

if [ -z "$ISO_URL" ]; then
    ISO_URL="https://archive.org/download/win-10.-pro.-aio.-u-34.-x-64.-wpe/WIN10.PRO.AIO.U34.X64.%28WPE%29.ISO"
fi

echo ""
echo "[*] Memeriksa disk..."

if [ -b /dev/nvme0n1 ]; then
    PARTISI="/dev/nvme0n1"
    TIPE="NVMe"
elif [ -b /dev/sda ]; then
    PARTISI="/dev/sda"
    TIPE="SATA"
else
    echo "[ERROR] Disk tidak ditemukan!"
    exit 1
fi

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "========================================"
echo " Informasi Installer"
echo "========================================"
echo "Disk      : $PARTISI"
echo "Tipe Disk : $TIPE"
echo "ISO URL   : $ISO_URL"
echo "VNC IP    : $IP"
echo "VNC PORT  : 5901"
echo "RDP PORT  : 3389"
echo "========================================"
echo ""

echo "[*] Download VKVM..."
wget -qO- https://dewa-rdp.com/vkvm-latest.tar.gz | tar xvz -C /tmp

cd /tmp

echo "[*] Download ISO..."

if ! wget -O windows.iso "$ISO_URL"; then
    echo ""
    echo "[ERROR] Gagal download ISO!"
    exit 1
fi

echo ""
echo "[*] Menjalankan Windows Installer..."
echo "[*] Hubungkan VNC ke:"
echo ""
echo "    ${IP}:5901"
echo ""
echo "[*] Setelah instalasi selesai, tutup QEMU lalu server akan reboot."
echo ""

sleep 3

./qemu-system-x86_64 \
-net nic \
-net user,hostfwd=tcp::3389-:3389 \
-m 10000M \
-localtime \
-enable-kvm \
-cpu core2duo,+nx \
-smp 2 \
-usbdevice tablet \
-k en-us \
-cdrom /tmp/windows.iso \
-hda "$PARTISI" \
-vnc :1 \
-boot d

echo ""
echo "[*] Reboot server..."
reboot
