#!/bin/bash

  # http://hints.macworld.com/article.php?story=20100927161027611

  # detect Airport and Ethernet interfaces
  eth_dev=`networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: (USB 10\/100\/1000 LAN|Thunderbolt Ethernet?.*), Device: (en?.*)\)$/\2/p'`
  wifi_dev=`networksetup -listnetworkserviceorder | sed -En 's/^\(Hardware Port: (Wi-Fi|AirPort), Device: (en.)\)$/\2/p'`

function set_airport {

  new_status=$1

  if [ $new_status = "On" ]; then
    /usr/sbin/networksetup -setairportpower $wifi_dev on
    touch /var/tmp/prev_air_on
  else
    /usr/sbin/networksetup -setairportpower $wifi_dev off
    if [ -f "/var/tmp/prev_air_on" ]; then
	    rm /var/tmp/prev_air_on
	  fi
  fi
}

# Set default values
prev_eth_status="Off"
prev_air_status="Off"

eth_status="Off"

# Determine previous ethernet status
# If file prev_eth_on exists, ethernet was active last time we checked
if [ -f "/var/tmp/prev_eth_on" ]; then
  prev_eth_status="On"
fi

# Determine same for AirPort status
# File is prev_air_on
if [ -f "/var/tmp/prev_air_on" ]; then
  prev_air_status="On"
fi

# Check actual current ethernet status
if [ "`ifconfig $eth_dev | grep \"status: active\"`" != "" ]; then
  eth_status="On"
fi

# And actual current AirPort status
air_status=`/usr/sbin/networksetup -getairportpower $wifi_dev | awk '{ print $4 }'`

# If any change has occured. Run external script (if it exists)
if [ "$prev_air_status" != "$air_status" ] || [ "$prev_eth_status" != "$eth_status" ]; then
  if [ -f "./statusChanged.sh" ]; then
	  "./statusChanged.sh" "$eth_status" "$air_status" &
  fi
fi

# Determine whether ethernet status changed
if [ "$prev_eth_status" != "$eth_status" ]; then

  if [ "$eth_status" = "On" ]; then
    set_airport "Off"
    osascript -e 'display notification "Wired network detected. Turning WiFi off." with title "Network adapter"'
  else
    set_airport "On"
    osascript -e 'display notification "No wired network detected. Turning WiFi on." with title "Network adapter"'
  fi

# If ethernet did not change
else

  # Check whether AirPort status changed
  # If so it was done manually by user
  if [ "$prev_air_status" != "$air_status" ]; then
    set_airport $air_status

	  if [ "$air_status" = "On" ]; then
      osascript -e 'display notification "WiFi manually turned on." with title "Network adapter"'
	  else
      osascript -e 'display notification "WiFi manually turned off." with title "Network adapter"'
	  fi
  fi
fi

# Update ethernet status
if [ "$eth_status" == "On" ]; then
  touch /var/tmp/prev_eth_on
else
  if [ -f "/var/tmp/prev_eth_on" ]; then
	  rm /var/tmp/prev_eth_on
  fi
fi

exit 0