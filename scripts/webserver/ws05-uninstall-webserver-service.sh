#!/bin/bash
# Stop and disable webserver service
sudo systemctl stop webserver.service
sudo systemctl disable webserver.service

# Remove webserver service file
sudo rm /etc/systemd/system/webserver.service
sudo systemctl daemon-reload