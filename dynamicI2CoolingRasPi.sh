# Raspberry cooling i2c module including environmental temperature, cpu temperature and fan controle on ubuntu core 24

## activate i2c bus 
# sudo snap install i2ctools --edge
# snap connections i2ctools
# snap interfaces|grep i2c
# snap connect i2ctools:i2c pi:i2c-1
# sudo reboot
# sudo i2ctools.i2cdetect -y 1

# sudo i2ctools.i2cdetect -y 1
#https://www.pimodules.com/_pdf/PCFM_V1.05.pdf

#!/bin/bash
#dynamische temp steuerung + Log

path_log = "/home/logs/deviceTemperature.txt"
temperature_cpu = "/sys/class/thermal/thermal_zone0/temp"
function fan_on () {
#cpu temperature and dynamic
   local t1=$(($(cat $temperature_cpu)/1000))

   if [ $t1 -ge 46 -a $t1 -le 50 ]; then
       sudo i2ctools.i2cset -y 1 0x6C 1 2
   elif [ $t1 -ge 51 -a $t1 -le 55 ]; then
       sudo i2ctools.i2cset -y 1 0x6C 1 3
   elif [ $t1 -ge 56 -a $t1 -le 60 ]; then
       sudo i2ctools.i2cset -y 1 0x6C 1 4
   elif [ $t1 -gt 60 ]; then
       sudo i2ctools.i2cset -y 1 0x6C 1 1
   fi
}

function fan_off () {
   local t1=$(($(cat $temperature_cpu)/1000))

   if [ $t1 -le 40 ]; then
       sudo i2ctools.i2cset -y 1 0x6C 1 0
   fi
}

function log () {

   local ts2=`date +%F_%H-%M-%S`
   local f1=$`sudo i2ctools.i2cget -y 1 0x6C 1 c`
   local f1=${f1:4:1}
   local t1=`cat $temperature_cpu`
   local t1=`echo "scale=2; "\`echo ${t1##*=}\`" / 1000" | bc`
   local t2=`vcgencmd measure_temp`
   local t2=${t2:5:4}
   local t3=$`sudo i2ctools.i2cget -y 1 0x6C 2 c`
   local t3=${t3:3:2}



#   if [ $f1 -eq 1 -o $f1 -eq 2 -o $f1 -eq 3 -o $f1 -eq 4 ]; then

      if [ $f1 -eq 0 ]; then
         sp="0"
	 st="off"
      elif [ $f1 -eq 2 ]; then
         sp="25"
	 st="on"
      elif [ $f1 -eq 3 ]; then
         sp="50"
	 st="on"
      elif [ $f1 -eq 4 ]; then
         sp="75"
	 st="on"
      elif [ $f1 -eq 1 ]; then
         sp="100"
	 st="on"
      else
         sp="NA"
         st="NA"
      fi
      #logfile
      file='/home/piFAN/temp_log.txt'

      if [ -f "$file" ]; then
         echo ''$ts2';'$t1';'$t2';'$t3';'$st';'$sp%'' >>$path_log
         echo ''$ts2';'$t1';'$t2';'$t3';'$st';'$sp%''
      else
         echo 'datetime;temp_cpu;temp_gpu;temp_board;status;speed' >>$path_log
#   fi
}

# set unconditional FAN ON
sudo i2ctools.i2cset -y 1 0x6C 0 1;

while true
do

# eval functions
fan_on ;
fan_off;
log;
# sleep
sleep 10s;

done

exit 0
