# PiCoolFanService

Service running on raspberry pi 3b+ ubuntu core 24 to controle and log pimodule.com PiCoolFan I2C module ([Instructions.pdf](https://www.pimodules.com/_pdf/PCFM_V1.05.pdf))

## Install
snap install docker

sudo mkdir -p /home/git-repositories/PiCoolFanService

cd /home/git-repositories/PiCoolFanService

sudo docker run --rm -v "$PWD":/repo -w /repo alpine/git clone https://github.com/benspeh/PiCoolFanService.git

sudo chmod +x ./setup_dynamicI2CoolingService.sh

sudo ./setup_dynamicI2CoolingService.sh
