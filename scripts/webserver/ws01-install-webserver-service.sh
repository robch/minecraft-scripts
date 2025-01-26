#!/bin/bash
sudo cp webserver.service /etc/systemd/system/webserver.service
sudo systemctl daemon-reload
sudo systemctl enable webserver.service