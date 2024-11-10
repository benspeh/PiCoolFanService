# PiCoolFanService

Service running on raspberry pi 3b+ ubuntu core 24 to controle and log pimodule.com PiCoolFan I2C module ([Instructions.pdf](https://www.pimodules.com/_pdf/PCFM_V1.05.pdf))

## Activate I2C bus
### ubuntu core 24 RaspberryPi Model 3B+ 
sudo snap install i2ctools --edge

snap connections i2ctools
snap interfaces|grep i2c
snap connect i2ctools:i2c pi:i2c-1
sudo reboot

sudo i2ctools.i2cdetect -y 1

## Install repo
snap install docker

sudo mkdir -p /home/git-repositories/PiCoolFanService

cd /home/git-repositories/PiCoolFanService

sudo docker run --rm -v "$PWD":/repo -w /repo alpine/git clone https://github.com/benspeh/PiCoolFanService.git

cd /home/git-repositories/PiCoolFanService

sudo chmod +x ./setup_dynamicI2CoolingService.sh

sudo ./setup_dynamicI2CoolingService.sh
