#!/bin/bash

echo "This script only for Broadcom Corp. BCM43142 Bluetooth 4.0"
echo "checked on Zorin OS 18"

echo "installing Required firmwares"

sudo apt install  broadcom-sta-dkms 
sudo apt install bluez-firmware -y
echo "Reloading Bluetooth"
sudo systemctl restart bluetooth

ls /lib/firmware/brcm/ | grep -i 43142
echo "Downloading Main Firmware"
wget https://github.com/winterheart/broadcom-bt-firmware/raw/master/brcm/BCM43142A0-0a5c-21d7.hcd
echo "Moving firmware"
sudo cp BCM43142A0-0a5c-21d7.hcd /lib/firmware/brcm/

echo "Loading firmware to kernel"
sudo modprobe -r btusb
sudo modprobe btusb
sudo systemctl restart bluetooth
echo "Check now if it's ok"
bluetoothctl list
bluetoothctl show

