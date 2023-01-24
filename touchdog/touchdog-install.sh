sudo cp touchdog.sh /usr/local/bin/
sudo cp touchdog.service /etc/systemd/system/
sudo chmod +x /usr/local/bin/touchdog.sh
sudo systemctl enable touchdog.service

