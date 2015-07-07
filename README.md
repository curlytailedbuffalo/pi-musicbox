Pi MusicBox - w/ Extras!
===================

Pi Musicbox with added features making it a truly headless media player.

Pi Musicbox is a headless media player OS for the raspberry pi. - [http://www.woutervanwijk.nl/pimusicbox/](http://www.woutervanwijk.nl/pimusicbox/)
It runs a version of [Rasbian](https://www.raspbian.org/) with the program [Mopidy](https://www.mopidy.com/) closely integrated into it to allow very easy music listening and internet radio streaming.

##Lacking from the Original

Both mopidy and pi musicbox are amazing systems, but there are a couple things I wanted that they did not have.

- **Truly headless operation** - pi musicbox can connect with a hardwired connection or wifi connection. without any type of connection it is impossible to configure the pi musicbox - to connect to a network you must first take out the sd card, modify a config file, and then reinsert the sd card - This is a pain and requires a pc or laptop.
- **Button interaction -** Interaction with pi musicbox is available through upnp, a webinterface, a config file, and even ssh - it does not have any libraries for dealing with buttons as a music player should (gpio buttons)(which makes sense, most people will have custom setups in that regard)
- **Interaction from the pi musicbox -** without a screen you don't know what is going on unless you have autoplay set, in which case a song will play when everything is ready to go.


##Added by Me

- **Truly headless experience** - with some added packages and some updates to the pi musicbox startup script, when it cannot connect to a network it will broadcast a wifi hotspot, which will allow access to the web interface and ssh
- **GPIO Buttons** - I have created a python script that runs in the background monitoring 4 buttons
- **I have added and modified a script to play prerecorded speech mp3s, or if online, use google translate for tts**


##Flaw in my Design

I do not know how to make my own image, that being said my instructions will begin with a fresh installation of pi musicbox on the raspberry pi. A fresh install of pi musicbox does not have my additions. To add the additions you will need a connection to the raspberry pi and the raspberry pi will need a connection to the internet.
I guess even I cannot say it is truly headless...... until after full setup anyways.



#Installation Information
===================

##Downloads You Will Need

Pi MusicBox Image - I have used 0.6, it is the most current, I have not tried with other versions.
[You can download it from here](http://www.woutervanwijk.nl/pimusicbox/)

**Additional packages being installed**
- hostapd 
- udhcpd - It looks like icm-dhcp-server runs on pi musicbox but I could not get it to work with that 
- mplayer - this is only used for the speech playback - mp3 and tts


##To Begin

First let me say that this will work much better if you have already installed Pi MusicBox before and figured out the configuration that works best for you. The english tutorial is [here](http://www.codeproject.com/Articles/838501/Raspberry-Pi-as-low-cost-audio-streaming-box) - 
Other languages can be found on the [Pi MusicBox download site](http://www.woutervanwijk.nl/pimusicbox/).

My setup will be based on using the actual 3.5mm port of RPI, if you have a USB soundcard the previous tutorial will walk you through the different steps for sound.


#Installation

1. Write Pi MusicBox image to your SD card. (do not remove SD card when complete)
2. Open the SD Card -> Config -> Settings.ini in a text editor
3. Change the MusicBox config settings, there is a config file below

The settings that matter are
```
[network]
wifi_network = YOUR_WIRELESS_NETWORK
wifi_password = PASSWORD_FOR_THAT_NETWORK
enable_ssh = true
wait_for_network = false

[musicbox]
root_password = ADD_A_ROOT_PASSWORD_HERE
resize_once = true
scan_once = true
\#scan_always = true

[audio]
output = analog
mixer_volume = 25
output = alsasink
mixer = software

[alsamixer]
card = 0
control =  PCM
```
```
################################# 
# Pi MusicBox / Mopidy Settings # 
################################# 
# 
# Edit the settings of your MusicBox and the Mopidy music server here
# This is a file read by both the MusicBox startup-scripts and Mopidy.
# For more info on the settings of Mopidy: http://docs.mopidy.com/en/latest/config/
# or the particular extenion's GitHub page 
#
# Every line starting with a # is a comment, it does not do anything until you remove the #

# --------------------
# | Network Settings |
# --------------------
[network]
**# Settings for your WiFi network, if you use a (supported) wifi-dongle
# Only supports WPA security, no WEP or access points without security (dive into the command line for that!)
wifi_network = NAMEOFNETWORK
wifi_password = PASSWORD** 

# Set the name of the MusicBox. 
# In this way you can identify and access different devices on the same network e.g. across different rooms.
# A MusicBox device named kitchen would be accessible from a web browser at http://kitchen.local/, from an MPD 
# client at kitchen.local and advertised as kitchen on AirTunes.
# The name is restricted to a maximum of 9 alphanumeric characters (no spaces, dots, etc).
# You can even have different devices with different Spotify accounts when needed.
name = MusicBox

# Mount Windows Network Drive on boot (via samba/cifs)
# The address is exactly how Samba mount works: //servername/mountpoint/directory
# e.g. //192.168.1.5/musicmount or //server.local/shared/music
# if the mount needs a username/password, also set it (leave empty for guest-access)
# Don't forget to let Mopidy/MusicBox scan the contents at first boot (see below) 
mount_address = 
mount_user = 
mount_password = 

# Here you can change the default workgroup of the Windows network.
# This will set the workgroup to the name you want
workgroup = WORKGROUP

# Enable this to allow remote login via SSH on MusicBox
**enable_ssh = true**

# By default, MusicBox waits for the network to come up, since there is not much to do without a network.
# If you want to skip this, e.g. for testing purposes, uncomment this line
**wait_for_network = false**
#This is dealt with by our new scripts being added

# -----------
# | Spotify |
# -----------
# https://github.com/mopidy/mopidy-spotify
[spotify]
# Supply your PREMIUM account credentials to enable Spotify
enabled = false
username = 
password = 
# The bitrate, the quality of the music played by Spotify, can be set to 96, 160 (default) or 320
bitrate = 320
cache_dir = ""

# -----------
# | Last.fm |
# -----------
# https://github.com/mopidy/mopidy-scrobbler
# Supply your credentials to scrobble tracks to Last.fm
[scrobbler]
enabled = false
username = 
password = 

# --------------
# | SoundCloud |
# --------------
# https://github.com/mopidy/mopidy-soundcloud
# Supply your auth_token obtained from http://www.mopidy.com/authenticate
[soundcloud]
enabled = false
auth_token = 

# ----------------
# | Google Music |
# ----------------
# https://github.com/hechtus/mopidy-gmusic
# Supply your credentials to enable Google Music
# NOTE: If enabled this may slow down the start of MusicBox. Please be patient
[gmusic]
enabled = false
all_access = true
username  = 
password = 
deviceid = 

# -----------
# | YouTube |
# -----------
# https://github.com/dz0ny/mopidy-youtube
# Play music from Youtube
[youtube]
enabled = true

# ----------
# | Dirble |
# ----------
# https://github.com/mopidy/mopidy-dirble
# Play radio stations from Dirble
[dirble]
enabled = true
api_key = 473279e3fa0e7010cbbbb40ecc31890d46e57a2e
countries = US, NL, DE, NO, SE

# ------------
# | Subsonic |
# ------------
# https://github.com/rattboi/mopidy-subsonic
# Stream music from your Subsonic Music Streamer
[subsonic]
enabled = false
hostname = 
port = 
username = 
password = 
ssl = 

# ----------------
# | TuneIn Radio |
# ----------------
# https://github.com/kingosticks/mopidy-tunein
# Play radio stations from TuneIn
[tunein]
enabled = true

# ------------------------
# | The Internet Archive |
# ------------------------
# http://mopidy-internetarchive.readthedocs.org/en/latest/config.html
# Listen to sounds and music from the Internet Archive
[internetarchive]
enabled = false

# -----------
# | Soma FM |
# -----------
# https://github.com/AlexandrePTJ/mopidy-somafm
# Play radio stations from Soma FM
[somafm]
enabled = false
encoding = mp3
quality = fast

# -----------
# | Podcast |
# -----------
# https://github.com/tkem/mopidy-podcast
# Play podcasts from different sources
[podcast]
# Note: You cannot add settings for [podcast-itunes] or [podcast-gpodder]
# because it breaks the startup script (won't read dashes in section names
enabled = true
feeds = 

# ---------------
# | AudioAddict |
# ---------------
# https://github.com/nilicule/mopidy-audioaddict
# Play music from all the AudioAddict network of sites (login optional)
[audioaddict]
enabled = false


# ---------------------
# | MusicBox Settings |
# ---------------------
**[musicbox]
# To secure your device, change the default password to something else.
# For security, the value in this file will be automatically cleaned out when the password is set in MusicBox
root_password =** 

# Automatically resize the filesystem and use all available space on your SD card. 
# Use at your own risk, you could lose data on your card.  
# (If so, you can put the original MusicBox image on it again and start over) 
**resize_once = true**

**# Scan on startup for new music files on the SD card or the network shares (could take a while!).
# Local files work ok for moderate size collections. Large music database sizes could cause problems.
# IMPORTANT: if you enable scan_always this will scan on every boot.
# If your music doesn't change or you only stream music set scan_once instead. 
#scan_once = true
scan_always = true**

# MusicBox can automatically start playing a stream/song after startup.
# It will wait up to autoplaymaxwait seconds before trying to do so for the system to first become ready.
# The wait required varies per device, network and configuration so if it doesn't work then increase the time.
# e.g. autoplay = http://nprdmp.ic.llnwd.net/stream/nprdmp_live01_mp3 or local:track:MusicBox/Music%20File.mp3 (on the SD Card)
autoplay = 
autoplaymaxwait = 60

# -------------
# | Streaming |
# -------------
# Set these options to enable streaming to Pi MusicBox
# AirTunes (using Shairport-sync):
**enable_shairport = true**

# DLNA/uPnP/OpenHome (using upmpdcli):
**enable_upnp = true**

# ------------------
# | Audio Settings |
# ------------------
# Because of limitations with some USB-DACs, MusicBox downsamples USB sound to 44k by default. Set to false to disable.
downsample_usb = true

# Set default audio output. This overrides the automatic detection (which sets to usb audio if an usb audio device
# is found, else to hdmi (if hdmi is connected at boot), and otherwise just to the analog out).
# i2s cards (e.g. HifiBerry etc) are not detected automatically and must be explicitly set here.
# Options: analog, hdmi, usb, hifiberry_dac, hifiberry_digi, hifiberry_dacplus, hifiberry_amp, iqaudio_dac
**output = analog** 
# **This will be anolog for the 3.5mm jack on the RPI**

[audio]
# Set the startup volume of MusicBox
# Values: from 0 to 100
**mixer_volume = 25**
# This is the startup volume of the system

# --------------------------------------------------------------------------
# | OTHER Settings                                                         |
# | You probably don't want to edit the settings below this line. Really.  |
# | Unless you know what you're doing, or you want to change the webclient |
# --------------------------------------------------------------------------
# This sets the gstreamer buffer. It's a bit tricky...
# If you have problems with stuttering sound, try other values here, like:
# or
#output = alsasink buffer-time=300000 latency-time=20000
#output = alsasink buffer-time=200000 latency-time=10000
output = alsasink

mixer = software

# Optionally, you can use alsamixer. This enables you to use hardware mixers of usb/audiocards.
# Set the previous setting to:
#mixer = alsamixer
# And set the card and contol below. E.g. 
#card = 1 
#control = Master 
# Run the command 'amixer scontrols' from the commandline to list available controls on your system
# See https://github.com/mopidy/mopidy-alsamixer
[alsamixer]
**card =0** 
**control =PCM** 
#**The card and control settings can be retrieved be following the MusicBox tutorial discussed above. These should work for the 3.5mm jack 0, PCM, respectively**

[stream]
enabled = true

[http]
enabled = true
hostname = 0.0.0.0
port = 6680
#Disable zeroconf
zeroconf = ""

# -------------
# | Webclient |
# -------------
# Here you can change the default webclient
# options: /opt/webclient /opt/moped
static_dir = /opt/webclient

[musicbox_webclient]
enabled = true
musicbox = true

[websettings]
enabled = true
musicbox = true
config_file = /boot/config/settings.ini

[mpd]
hostname = 0.0.0.0

[logging]
config_file = /etc/mopidy/logging.conf
debug_file = /var/log/mopidy/mopidy-debug.log

[local]
enabled = true
**media_dir = /music**
**playlists_dir = /var/lib/mopidy/playlists**
data_dir = /var/lib/mopidy/localdata
#This sets the method of indexing local files
#You can set it to json or whoosh. Whoosh might be better with large collections, JSON is a bit more mature.
# TODO: You cannot add settings for [local-sqlite]
# because it breaks the startup script (won't read dashes in section names
library = sqlite

scan_timeout = 1000
scan_flush_threshold = 1000
excluded_file_extensions = .html, .jpeg, .jpg, .log, .nfo, .png, .txt, .mkv, .avi, .divx, .qt, .wmv, .htm, .zip, .rar, .gz, .pdf, .exe, .ini, .mid, .db, .m3u, .sfv, .midi

```
