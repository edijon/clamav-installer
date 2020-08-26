#! /bin/bash

#-------------------------------
# Install required packages
#-------------------------------
sudo dnf install --assumeyes --refresh clamd clamav clamav-{data,filesystem,lib,update,devel}

#-------------------------------
# Configure selinux
#-------------------------------
sudo setsebool antivirus_can_scan_system=1

#-------------------------------
# Configure clamav
#-------------------------------
sudo sed -i -E 's/^([a-zA-Z0-9])/#\1/' /etc/clamd.d/scan.conf
echo -e "#CUSTOM \nLocalSocket /run/clamd.scan/clamd.sock \nOnAccessPrevention yes \nOnAccessIncludePath /home \nOnAccessExcludeRootUID yes \n" | sudo tee --append /etc/clamd.d/scan.conf

#-------------------------------
# Refresh virus signatures
#-------------------------------
sudo freshclam

#-------------------------------
# Start services
#-------------------------------
sudo systemctl enable --now clamav-freshclam && \
sudo systemctl enable --now clamd@scan && \
sudo systemctl enable --now clamonacc

