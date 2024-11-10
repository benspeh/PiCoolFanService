sudo mkdir -p /home/my-git-repositories/PiCoolFanService

cd /home/my-git-repositories/PiCoolFanService

sudo cp dynamicI2Cooling.service /etc/systemd/system/dynamicI2Cooling.service

sudo chmod +x /home/my-git-repositories/PiCoolFanService/dynamicI2CoolingRasPi.sh
sudo chmod +x /home/my-git-repositories/PiCoolFanService/Update_dynamicI2CoolingService.sh
sudo chmod +x /etc/systemd/system/dynamicI2Cooling.service

sudo systemctl daemon-reload
sudo systemctl enable dynamicI2Cooling.service
sudo systemctl start dynamicI2Cooling.service
sudo systemctl status dynamicI2Cooling.service
