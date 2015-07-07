#!/bin/bash
#
# MusicBox startup script
#
# This script is executed by /etc/rc.local
#

`echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

#set user vars
MB_USER=musicbox
CONFIG_FILE=/boot/config/settings.ini
NAME="MusicBox"
NEED_HOTSPOT="0"
CREATE_HOTSPOT='/opt/startup-wifihotspot.sh'
SPEECHOUT='/opt/speech.sh'
SSH_START='/etc/init.d/dropbear start'

# Hello there. My name is MusicBox.I will let you know when I am ready to use.
$SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-hello-there.mp3"

echo "Starting dropbear SSH daemon"

if [ ! -f "/etc/dropbear/dropbear_dss_host_key" ]
then
    echo "Create dss-key for dropbear..."
    dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
fi
if [ ! -f "/etc/dropbear/dropbear_rsa_host_key" ]
then 
    echo "Create rsa-key for dropbear..."
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
fi

$SSH_START
#open ssh port
iptables -A INPUT -p tcp --dport 22 -j ACCEPT > /dev/null 2>&1 || true
echo "SSH has been started"
# Define LSB log_* functions.
. /lib/lsb/init-functions

log_use_fancy_output
log_progress_msg "SSH has been initialized, user for music box has been chosen, config file has been declared."
log_begin_msg "Initializing MusicBox..."

# import ini parser
. /opt/musicbox/read_ini.sh

# convert windows ini to unix
dos2unix -n $CONFIG_FILE /tmp/settings.ini > /dev/null 2>&1 || true

#declare $INI before reading ini https://github.com/rudimeier/bash_ini_parser/issues/2
unset INI
declare -A INI
log_progress_msg "Loading configuration information from settings.ini"
# ini vars to mopidy settings
read_ini /tmp/settings.ini

rm /tmp/settings.ini > /dev/null 2>&1 || true

INI_READ=true

REBOOT=0
log_start_msg "Configuration has been loaded"

if [ "$INI__musicbox__resize_once" == "1" ]
then
    #set resize_once=false in ini file
    sed -i -e "/^\[musicbox\]/,/^\[.*\]/ s|^\(resize_once[ \t]*=[ \t]*\).*$|\1false\r|" $CONFIG_FILE
    log_progress_msg "Initalizing resize..." "$NAME"
    sh /opt/musicbox/resizefs.sh -y
    REBOOT=1
fi

#get name of device and trim
HOSTNM=`cat /etc/hostname | tr -cd "[:alnum:]"`
#get name in ini and trim
CLEAN_NAME=$(echo $INI__network__name | tr -cd "[:alnum:]")
#max 9 characters (max netbios length = 15, + '.local')
CLEAN_NAME=$(echo $CLEAN_NAME | cut -c 1-9)

if [ "$CLEAN_NAME" == "" ]
then
    CLEAN_NAME="MusicBox"
fi

if [ "$CLEAN_NAME" != "$HOSTNM" ]
then
    #if devicename is not the same as ini, change and reboot<-->
    echo "$CLEAN_NAME" > /etc/hostname
    echo "127.0.0.1       localhost $CLEAN_NAME" > /etc/hosts
    log_end_msg "Name of device set..." "$NAME"
    REBOOT=1
fi

if [ "$REBOOT" == 1 ]
then
    reboot
    exit
fi

log_progress_msg "MusicBox name is $CLEAN_NAME" "$NAME"

# do the change password stuff
if [ "$INI__musicbox__root_password" != "" ]
then
    log_progress_msg "Setting root user Password" "$NAME"
    echo "root:$INI__musicbox__root_password" | chpasswd
    #remove password
    sed -i -e "/^\[musicbox\]/,/^\[.*\]/ s|^\(root_password[ \t]*=[ \t]*\).*$|\1\r|" $CONFIG_FILE
fi

#allow shutdown for all users
chmod u+s /sbin/shutdown

# Just about ready. I just have to setup your network connections and you will be ready to play music
$SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-just-about.mp3"

if [ "$INI__network__wifi_network" != "" ]
then
    log_progress_msg "Wifi network SSID has been set in configuration"
    net_alive="0"
    log_progress_msg "Checking to see if configured wifi network is in range"
     while read -r line ; do
        first="ESSID\:"\";
        second="\"";
        sub="";
        line=${line/$first/$sub};
        line=${line/$second/$sub};
        log_progress_msg "Found wifi network with SSID - $line"

        if [ "$line" == "$INI__network__wifi_network" ]
        then
            log_progress_msg "Found wifi network - $line - matches configured network - $INI__network__wifi_network"
            log_progress_msg "Network configuration will use defaults - no wireless hotspot required."
           export net_alive="1"
        fi
    done< <(iwlist wlan0 scan | grep ESSID)
    if [ "$net_alive" == "1" ]
    then
        INI__network__wait_for_network="1"
        NEED_HOTSPOT="0"
        echo "Ad hoc startupp disabled, configuring wireless credentials"
    #put wifi settings for wpa roamin
cat >/etc/wpa.conf <<EOF
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    network={
        ssid="$INI__network__wifi_network"
        psk="$INI__network__wifi_password"
        scan_ssid=1
    }
EOF

    #enable wifi
    #ifdown wlan0
    ifup wlan0

    /etc/init.d/networking restart
    else
        INI__network__wait_for_network="0"
        NEED_HOTSPOT="1"
        echo "Could not find the configured wireless network. Initialize adhoc network."
        # I can't seem to find the network you have configured.
        $SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-cant-find-network.mp3"
        # I'll setup a wifi hotspot for you to access instead
        $SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-hotspot-instead.mp3"
    fi
else
    log_progress_msg "No wifi settings found in configuration file. Adhoc hostspot will be required."
    INI__network__wait_for_network="0"
    NEED_HOTSPOT="1"
    # It looks like you haven't configured a wifi connection yet. I will setup a wifi hotspot so you can still connect to me.
    $SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-no-wifi-configured.mp3"
    # I'll setup a wifi hotspot for you to access instead
    $SPEECHOUT "mp3" "/home/mopidy/notifications/radio-hotspot-instead.mp3"
fi
#include code from setsound script
. /opt/musicbox/setsound.sh

if [ "$INI__network__workgroup" != "" ]
then
    #change smb.conf workgroup value
    sed -i "s/workgroup = .*$/workgroup = $INI__network__workgroup/ig" /etc/samba/smb.conf
    #restart samba
    /etc/init.d/samba restart
fi

#redirect 6680 to 80
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 6680 > /dev/null 2>&1 || true

# start upnp if enabled
if [ "$INI__musicbox__enable_upnp" == "1" ]
then
    /etc/init.d/upmpdcli start
    ln -s /etc/monit/monitrc.d/upmpdcli /etc/monit/conf.d/upmpdcli > /dev/null 2>&1 || true
else
    rm /etc/monit/conf.d/upmpdcli > /dev/null 2>&1 || true
fi

# start shairport if enabled
if [ "$INI__musicbox__enable_shairport" == "1" ]
then
    /etc/init.d/shairport-sync start
    ln -s /etc/monit/monitrc.d/shairport /etc/monit/conf.d/shairport > /dev/null 2>&1 || true
else
    rm /etc/monit/conf.d/shairport > /dev/null 2>&1 || true
fi

service monit start

#check networking, sleep for a while
MYIP=$(hostname -I)
if [ "$MYIP" == "" -a "$INI__network__wait_for_network" != "0" ]
then
    log_progress_msg "Waiting 120 seconds for an IP Address from the configured wifi network."
    echo
    /etc/init.d/networking restart
    sleep 120
    MYIP=$(hostname -I)
    if [ "$MYIP" == "" ]
    then
        log_warning_msg "Could not get an IP address from the configured wifi network"
        NEED_HOTSPOT="1"
        # bad news. I found the wireless network you told me to look for, but it won't let me connect.
        $SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-network-wont-connect.mp3"
        # Don't worry though. I will setup a wifi hotspot so you can double check the configuration
        $SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-double-check.mp3"
    fi
fi

# set date/time
ntpdate ntp.ubuntu.com > /dev/null 2>&1 || true

if [ "$NEED_HOTSPOT" != "1" ]
then
    #mount windows share
    if [ "$INI__network__mount_address" != "" ]
    then
        #mount samba share, readonly
        log_progress_msg "Mounting Windows Network drive..." "$NAME"
        mount -t cifs -o sec=ntlm,ro,user=$INI__network__mount_user,password=$INI__network__mount_password $INI__network__mount_address /music/Network/
        #mount -t cifs -o sec=ntlm,ro,rsize=2048,wsize=4096,cache=strict,user=$INI__network__mount_user,password=$INI__network__mount_password $INI__network__mount_address /music/Network/
        #add rsize=2048,wsize=4096,cache=strict because of usb (from raspyfi)
    fi
fi

# scan local music files once
if [ "$INI__musicbox__scan_once" == "1" ]
then
    #set SCAN_ONCE = false
    sed -i -e "/^\[musicbox\]/,/^\[.*\]/ s|^\(scan_once[ \t]*=[ \t]*\).*$|\1false\r|" $CONFIG_FILE
fi

# scan local/networked music files if setting is true
if [ "$INI__musicbox__scan_always" == "1" -o "$INI__musicbox__scan_once" == "1" ]
then
    log_progress_msg "Scanning music-files, please wait..."
    /etc/init.d/mopidy run local scan
    #if somehow mopidy is not killed ok. kill manually
    killall -9 mopidy > /dev/null 2>&1 || true
    /etc/init.d/mopidy start
fi

#start mopidy
/etc/init.d/mopidy start

if [ "$INI__network__name" != "$CLEAN_NAME" -a "$INI__network__name" != "" ]
then
    log_warning_msg "The new name of your MusicBox, $INI__network__name, is not ok! It should be max. 9 alphanumerical characters."
fi

# CUSTOMSCRIPTS
python /home/mopidy/initbuttons &

# ./ END CUSTOMSCRIPTS

# renice mopidy to 19, to have less stutter when playing tracks from spotify (at the start of a track)
renice 19 `pgrep mopidy`
if [ "$NEED_HOTSPOT" == "1" ]
then
    # Dont run this in background with &. It has voice and terminal feedback
    $CREATE_HOTSPOT
    
else
    # Print the IP address
    _IP=$(hostname -I) || true
    if [ "$_IP" ]; then
    
        speakableipv4=$("/opt/getspeakableip.sh")
        
        $SPEECHOUT "google" 10 "Alright I am connected to the network, $INI__network__wifi_network "
        $SPEECHOUT "google" 10 "That means I am not confined to local music, I can use internet radio as well"
        $SPEECHOUT "google" 10 "While I finish setting up, I might as well give you some tips"
        $SPEECHOUT "google" 10 "The left and right arrow keys are for changing the song or stream that is playing."
        $SPEECHOUT "google" 10 "But, if you press them at the same time, you will load the default radio stations"
        $SPEECHOUT "google" 10 "Next, the up and down buttons represent volume, but, pushed together will toggle play and pause"
        $SPEECHOUT "google" 10 "Another tip, you can connect to me with a browser using 2 different methods"
        $SPEECHOUT "google" 10 "One, is using my i.p address, $speakableipv4"
        $SPEECHOUT "google" 10 "Two, is using $INI__network__name dot local, but only on apple and zeroconfig devices"
        # 3, 2, 1, and finished.
        $SPEECHOUT "mp3" 10 "/home/mopidy/notifications/radio-finished-321.mp3"
        $SPEECHOUT "google" 10 "I'm all yours"

        if [ "$INI__musicbox__autoplay" -a "$INI__musicbox__autoplaywait" ]
        then
            log_progress_msg "Waiting $INI__musicbox__autoplaywait seconds before autoplay." "$NAME"
            $SPEECHOUT "google" 10 "Looks like you want me to load some music. That's fine but I'm finished helping after that, ya dig?"
            sleep $INI__musicbox__autoplaywait
            log_progress_msg "Playing $INI__musicbox__autoplay" "$NAME"
            # Load single stream or URL
            #mpc play "$INI__musicbox__autoplay"
            
            # Load a playlist from the configured playlist folder. It must be named exactly as it shows in musicbox (no .m3u)
            mpc clear
            mpc load "$INI__musicbox__autoplay"
            mpc play
        fi
        log_progress_msg "My IP address is $_IP. Connect to MusicBox in your browser via http://$CLEAN_NAME.local or http://$_IP "
    fi
fi

# check and clean dirty bit of vfat partition not safely removed
fsck /dev/mmcblk0p1 -v -a -w -p > /dev/null 2>&1 || true
log_end_msg 0
