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
    local t1_base=(expr $t1_get / 1000)
    
    local t1=$(awk "BEGIN { printf \"%.2f\", $t1_get / 1000 }")  # CPU temperature in °C
    
    local t2=$(i2ctools.i2cget -y 1 0x6C 2 c)
    local t2=${t2#0x}  

    local f1=$(i2ctools.i2cget -y 1 0x6C 1 c)
    local f1=${f1:3:1}  

    # Return the values
    echo "$ts2 $t1_base $t1 $t2 $f1"
}

fan_on() {
    t1_base=$1
    if [ $t1_base -ge 51 ] && [ $t1_base -le 55 ]; then
        i2ctools.i2cset -y 1 0x6C 1 2  # Set fan speed to 25%
    elif [ $t1_base -ge 56 ] && [ $t1_base -le 60 ]; then
        i2ctools.i2cset -y 1 0x6C 1 3  # Set fan speed to 50%
    elif [ $t1_base -ge 61 ] && [ $t1_base -le 65 ]; then
        i2ctools.i2cset -y 1 0x6C 1 4  # Set fan speed to 75%
    elif [ $t1_base -gt 65 ]; then
        i2ctools.i2cset -y 1 0x6C 1 1  # Set fan speed to 100%
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

    case "$f1" in
        0) sp="0"; st="off" ;;
        2) sp="25"; st="on" ;;
        3) sp="50"; st="on" ;;
        4) sp="75"; st="on" ;;
        1) sp="100"; st="on" ;;
        *) sp="NA"; st="NA" ;;
    esac
      
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
    echo $read_values_output;
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
