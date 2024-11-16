 #!/bin/bash
# Raspberry cooling i2c module including environmental temperature, cpu temperature and fan controle on ubuntu core 24

## activate i2c bus 
# sudo snap install i2ctools --edge
# snap connections i2ctools
# snap interfaces|grep i2c
# snap connect i2ctools:i2c pi:i2c-1
# sudo reboot
# sudo i2ctools.i2cdetect -y 1

#https://www.pimodules.com/_pdf/PCFM_V1.05.pdf

#dynamische temp steuerung + Log

path_log="/home/logs/deviceTemperature.txt";
temperature_cpu="/sys/class/thermal/thermal_zone0/temp";

function read_values() {
    local ts2=`date +%F_%H-%M-%S`

    local t1_get=$(cat "$temperature_cpu")
    local t1_base=$(($t1_get / 1000))
    
    local t1=$(awk "BEGIN { printf \"%.2f\", $t1_get / 1000 }")  # CPU temperature in °C

    local t2=$(`i2ctools.i2cget -y 1 0x6C 2 c`)
    local t2=${t2:3:2}  

    local f1=$(`i2ctools.i2cget -y 1 0x6C 1 c`)
    local f1=${f1:4:1}  
    echo "f1 value in read function: '$f1'"

    # Return the values
    echo "$ts2 $t1_base $t1 $t2 $f1"
}

function fan_on () {
   #cpu temperature and dynamic
   local t1_base=$1
   if [ $t1_base -ge 51 -a $t1_base -le 55 ]; then
       i2ctools.i2cset -y 1 0x6C 1 2
   elif [ $t1_base -ge 56 -a $t1_base -le 60 ]; then
       i2ctools.i2cset -y 1 0x6C 1 3
   elif [ $t1_base -ge 61 -a $t1_base -le 65 ]; then
       i2ctools.i2cset -y 1 0x6C 1 4
   elif [ $t1_base -gt 65 ]; then
       i2ctools.i2cset -y 1 0x6C 1 1
   fi
}

function fan_off () {
   local t1_base=$1
   if [ $t1_base -le 45 ]; then
       i2ctools.i2cset -y 1 0x6C 1 0
   fi
}

function log () {
    local ts2=$1
    local t1=$2
    local t2=$3
    local f1=$4
    local sp=""
    local st=""

    echo "f1 value in log function: '$f1'"
   #if [[ $f1 -eq 0 || $f1 -eq 1 || $f1 -eq 2 || $f1 -eq 3 || $f1 -eq 4 ]]; then
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
       # fi
      
      #logfile
      if [ -f "$path_log" ]; then
         echo ''$ts2';'$t1';'$t2';'$st';'$sp%'' >>"$path_log"
         echo ''$ts2';'$t1';'$t2';'$st';'$sp%''
      else
         echo 'datetime;temp_cpu;temp_environment;status;speed' >>"$path_log"
      fi
}

# set unconditional FAN ON
i2ctools.i2cset -y 1 0x6C 0 1;

while true
do
# Read values once at the start
    read_values_output=$(read_values);
    
    # Split the output into individual values
    read -r ts2 t1_base t1 t2 f1 <<< "$read_values_output";
    
    # Use the measured values in the fan control and logging function
    fan_on $t1_base;
    fan_off $t1_base;
    log $ts2 $t1 $t2 $f1;
    # sleep
    sleep 20s;

done

exit 0
