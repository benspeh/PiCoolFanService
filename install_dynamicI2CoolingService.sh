cd /home/my-git-repositories/PiCoolFanService

sudo cp dynamicI2Cooling.service /etc/systemd/system/dynamicI2Cooling.service

sudo chmod +x /etc/systemd/system/dynamicI2Cooling.service
sudo chmod +x ./dynamicI2CoolingRasPi.sh
sudo chmod +x ./update_dynamicI2CoolingService.sh

sudo systemctl daemon-reload
sudo systemctl enable dynamicI2Cooling.service
sudo systemctl start dynamicI2Cooling.service
sudo systemctl status dynamicI2Cooling.service
