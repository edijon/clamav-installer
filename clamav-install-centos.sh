#! /bin/bash

#-------------------------------
# Install required packages
#-------------------------------
sudo dnf install clamd clamav clamav-{data,filesystem,lib,update,devel}

#-------------------------------
# Configure clamav
#-------------------------------
echo -e "#CUSTOM \nOnAccessIncludePath /home \nOnAccessPrevention yes \nOnAccessExcludeRootUID yes \n" | sudo tee --append /etc/clamd.d/scan.conf


#-------------------------------
# Refresh virus signatures
#-------------------------------
sudo freshclam

#-------------------------------
# Start services
#-------------------------------
sudo systemctl enable --now clamav-freshclam clamd@scan clamonacc

