#! /bin/bash

# Install clamav services with on-access scanning.
# watch home directory.

SCRIPT_DIRECTORY=$(readlink -f $0)
SCRIPT_DIRECTORY=$(cd $(dirname $SCRIPT_DIRECTORY); pwd)

main(){
    echo -e "CHECKING OS...\n"
    os=$(cat /etc/os-release | grep --word-regexp ID | awk -F '=' '{print $2}')
    if [ $os == "ubuntu" ]
    then
        _install_clamav_ubuntu
    else
        echo "NOT IMPLEMENTED"
        exit 1
    fi
}

_install_clamav_ubuntu(){
    clamav_configuration_file="/etc/clamav/clamd.conf"
    systemd_clamonacc_service_file="/etc/systemd/system/clamonacc.service"

    echo "CONFIGURATION FILE FOR CLAMAV : $clamav_configuration_file"
    echo "SERVICE UNIT FILE FOR CLAMONACC : $systemd_clamonacc_service_file"

    echo -e "INSTALL PACKAGES...\n"
    sudo apt update && \
    sudo apt install clamav-daemon
    echo ""

    _configure_clamav $clamav_configuration_file
    _configure_clamav_onaccess_scanning $systemd_clamonacc_service_file $clamav_configuration_file

    echo "START SERVICES..."
    _start_clamav
}

_configure_clamav(){
    clamav_configuration_file=$1

    sudo bash -c \
"cat << EOF >> $clamav_configuration_file
#CUSTOM
OnAccessPrevention yes
OnAccessDisableDDD yes
OnAccessExcludeUname clamav
OnAccessIncludePath /home
OnAccessExcludeRootUID yes
EOF"
}

_configure_clamav_onaccess_scanning(){
    systemd_clamonacc_service_file=$1
    clamav_configuration_file=$2

    sudo bash -c \
"cat << EOF > $systemd_clamonacc_service_file
[Unit]
Description=ClamAV On Access Scanner
Requires=clamav-daemon.service
After=clamav-daemon.service syslog.target network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/clamonacc -F --log=/var/log/clamav/clamonacc --config=$clamav_configuration_file
Restart=on-failure
RestartSec=120s

[Install]
WantedBy=multi-user.target
EOF"
}

_start_clamav(){
    sudo systemctl enable --now clamav-daemon.service && \
    sudo systemctl enable --now clamav-freshclam.service && \
    sleep 5 && \
    sudo systemctl enable --now clamonacc.service
}

main $@