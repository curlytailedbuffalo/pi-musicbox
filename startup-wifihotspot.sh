 #!/bin/bash
#
# Starup Wifi Hotspot Script
#
# This is executed by the startup.sh script run at boot.
#
SPEECHOUT='/opt/speech.sh '
# I've been told to start up a wifi hotspot for you to access. It shouldn't take long.
echo "Creating an ad-hoc network on wlan0"
$SPEECHOUT "mp3" 20 "/home/mopidy/notifications/radio-startup-hotspot.mp3"

echo "Killing wpa_supplicant..."
killall -9 wpa_supplicant

echo "Setting static ip address..."
ifconfig wlan0 192.168.1.1 netmask 255.255.255.0

echo "Starting wifi hostpot hostapd"
service hostapd start

echo "Killing wpa_supplicant - Didnt we do that already? Sorry boss, if the hack works don't fix it."
killall -9 wpa_supplicant

echo "Setting static ip address.. - Again, if it works, dont fix it."
ifconfig wlan0 192.168.1.1 netmask 255.255.255.0

echo "Starting DHCP server udhcpd "
service udhcpd start
service dnsmasq start
# I'm faster then I thought. The wifi hotspot Musicbox is up and running and I am ready to go.
$SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-faster-then-thought.mp3"

# Remember. Connect to my wifi, to access me at one nine two, dot, one six eight, dot, one, dot, one
$SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-remember-hotspot.mp3"

# And dont forget that you can connect me to a wifi network on my settings page under network.
$SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-dont-forget.mp3"

echo "Wifi hotspot has been created."
echo "You can connect to the hotspot to configure your wireless network -> Connect in browser -> Go to settings -> Enter your credentials under network."
echo "***** Connect to MusicBox in your browser using the following address - http://192.168.1.1 *****"
echo "***** If you have an apple device, or a device with itunes (zeroconf) you can use the following address in your bwowser -  http://$CLEAN_NAME.local "
echo "Enjoy"
