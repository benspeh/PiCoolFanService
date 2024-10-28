cd /home/my-git-repositories/RaspIrrigation

sudo docker run --rm -v "$PWD":/repo -w /repo alpine/git pull origin main

sudo cp dynamicI2Cooling.service /etc/systemd/system/dynamicI2Cooling.service
sudo chmod +x /home/my-git-repositories/RaspIrrigation/dynamicI2CoolingRasPi.sh
sudo systemctl daemon-reload
sudo systemctl restart dynamicI2Cooling.service
sudo systemctl status dynamicI2Cooling.service
