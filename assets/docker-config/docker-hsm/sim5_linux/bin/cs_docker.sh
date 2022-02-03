#!/bin/bash
#
# SDK_INSTANCE_PATH is the environment variable set during build (default hsm). This should be a volume to store the keys of the net HSM
# or docker run

if [ -z ${SDK_PORT+x} ]
then
  SDK_PORT=3001
fi

SDK_BIN_PATH="$(dirname "$(readlink -f "$0")")"

if [ -z ${SDK_INSTANCE_PATH+x} ]
then
  SDK_INSTANCE_PATH="/.tmp"
fi

if [ ! -e "$SDK_INSTANCE_PATH/bin/bl_sim_instance" ]
then
  mkdir -p "$SDK_INSTANCE_PATH/bin" 
  cp "$SDK_BIN_PATH/bl_sim5"  "$SDK_INSTANCE_PATH/bin/bl_sim_instance" 
  cp "$SDK_BIN_PATH/cs_sim.ini" "$SDK_INSTANCE_PATH/bin"
  cp $SDK_BIN_PATH/*.so $SDK_INSTANCE_PATH/$i/bin 2> /dev/null
  mkdir -p "$SDK_INSTANCE_PATH/devices" 
  mkdir -p "$SDK_INSTANCE_PATH/log"
  cp  -r "$SDK_BIN_PATH/../devices"  "$SDK_INSTANCE_PATH/" 
  (export SDK_PORT=$SDK_PORT; $SDK_INSTANCE_PATH/bin/bl_sim_instance -h -o > $SDK_INSTANCE_PATH/log/bl_sim_$SDK_PORT.txt 2>&1 &)
else
  (export SDK_PORT=$SDK_PORT; $SDK_INSTANCE_PATH/bin/bl_sim_instance -h -o > $SDK_INSTANCE_PATH/log/bl_sim_$SDK_PORT.txt 2>&1 &)
fi

trap "exit 0" SIGINT SIGTERM

sleep infinity

pkill -SIGINT bl_sim_instance