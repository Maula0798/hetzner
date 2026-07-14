#!/bin/bash

echo "=================================="
echo " Windows Installer Hetzner"
echo "=================================="

echo ""
read -p "Masukkan URL ISO Windows: " ISO_URL

if [ -z "$ISO_URL" ]; then
    echo "URL ISO tidak boleh kosong!"
    exit 1
fi

echo ""
echo "Memeriksa jenis partisi..."

if [ -b /dev/nvme0n1 ]; then
    echo "Ditemukan partisi NVMe."
    PARTISI="/dev/nvme0n1"
else
    echo "Menggunakan partisi standar /dev/sda."
    PARTISI="/dev/sda"
fi

echo ""
echo "Memulai instalasi pada $PARTISI..."

wget -qO- https://dewa-rdp.com/vkvm-latest.tar.gz | tar xvz -C /tmp

cd /tmp

echo "Mengunduh ISO..."
wget -O windows.iso "$ISO_URL"

echo ""
echo "Menjalankan Windows Installer..."
echo "VNC : :1"

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

reboot
