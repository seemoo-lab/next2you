#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./capture.sh [band]"
    printf "\tband: 2 or 5\n"
    exit
fi
if [ "$1" -eq 2 ]; then
    CHANNEL="1/20"
elif [ "$1" -eq 5 ]; then
    CHANNEL="157/80"
else
    echo "invalid band..exit"
    exit
fi

echo "*** Installing firmware"
source ../../../../setup_env.sh
sudo -E make install-firmware
echo "*** Compiling configurator"
make -C utils/makecsiparams/
echo "*** Configuring CSI extractor"
CONFIG=$(./utils/makecsiparams/makecsiparams -c "$CHANNEL" -C 1 -N 1 -m aa:aa:aa:aa:aa:aa -b 0x88)
sleep 5
nexutil -Iwlan0 -s500 -b -l34 -v"$CONFIG"
sleep 1
echo "*** Creating monitor interface"
sudo -E iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor
sleep 1
sudo -E ifconfig mon0 up
sleep 2
echo "*** Start collecting data"
python3 ./collect.py
echo "*** Finished data collection"

