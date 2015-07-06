Pi MusicBox - w/ Extras!
===================

Pi Musicbox with added features making it a truly headless media player.

Pi Musicbox is a headless media player OS for the raspberry pi. - [http://www.woutervanwijk.nl/pimusicbox/](http://www.woutervanwijk.nl/pimusicbox/)
It runs a version of [Rasbian](https://www.raspbian.org/) with the program [Mopidy](https://www.mopidy.com/) closely integrated into it to allow very easy music listening and internet radio streaming.

**WHAT THE ORIGINAL LACKS**

Both mopidy and pi musicbox are amazing systems, but there are a couple things I wanted that they did not have.
**1. Truly headless operation** - pi musicbox can connect with a hardwired connection or wifi connection. without any type of connection it is impossible to configure the pi musicbox - to connect to a network you must first take out the sd card, modify a config file, and then reinsert the sd card - This is a pain and requires a pc or laptop.
**2. Button interaction -** Interaction with pi musicbox is available through upnp, a webinterface, a config file, and even ssh - it does not have any libraries for dealing with buttons as a music player should (gpio buttons)(which makes sense, most people will have custom setups in that regard)
**3. Interaction from the pi musicbox -** without a screen you don't know what is going on unless you have autoplay set, in which case a song will play when everything is ready to go.


**WHAT HAS BEEN ADDED BY ME**

**1. Truly headless experience** - with some added packages and some updates to the pi musicbox startup script, when it cannot connect to a network it will broadcast a wifi hotspot, which will allow access to the web interface and ssh
**2. GPIO Buttons** - 
I have created a python script that runs in the background monitoring 4 buttons
		  **pressed single** - left/right/up/down - previous/next/volume up/volume down
		  **pressed togethe** - left/right - load default playlist
						                    - up/down - toggle play and pause
						                    - all 4 at same time enters what I am calling game mode ** much more to do
**3. I have added and modified a script to play prerecorded speech mp3s, or if online, use google translate for tts**


**FLAW IN MY DESIGN**

I do not know how to make my own image, that being said my instructions will begin with a fresh installation of pi musicbox on the raspberry pi. A fresh install of pi musicbox does not have my additions. To add the additions you will need a connection to the raspberry pi and the raspberry pi will need a connection to the internet.
I guess even I cannot say it is truly headless...... until after full setup anyways.



Install and Configure
===================

**DOWNLOADS YOU WILL NEED**

Pi MusicBox Image - I have used 0.6, it is the most current, I have not tried with other versions.
[You can download it from here](http://www.woutervanwijk.nl/pimusicbox/)

**Additional packages being installed**
		 - hostapd 
		 - udhcpd - It looks like icm-dhcp-server runs on pi musicbox but I could not get it to work with that 
		 - mplayer - this is only used for the speech playback - mp3 and tts


**TO BEGIN**

First let me say that this will work much better if you have already installed Pi MusicBox before and figured out the configuration that works best for you. The english tutorial is [here](http://www.codeproject.com/Articles/838501/Raspberry-Pi-as-low-cost-audio-streaming-box) - 
Other languages can be found on the [Pi MusicBox download site](http://www.woutervanwijk.nl/pimusicbox/).

My setup will be based on using the actual 3.5mm port of RPI, if you have a USB soundcard the previous tutorial will walk you through the different steps for sound.


**INSTALLATION**

1. Write Pi MusicBox image to your SD card. (do not remove SD card when complete)
2. Open the SD Card -> Config -> Settings.ini in a text editor
3. Change the MusicBox config settings... the ones you will need to change
'''
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

\# Options: analog, hdmi, usb, hifiberry_dac, hifiberry_digi, hifiberry_dacplus, hifiberry_amp, iqaudio_dac
output = analog

[audio]
\# Values: from 0 to 100
mixer_volume = 25

/# If you have problems with stuttering sound, try other values here, like:
/# or
/#output = alsasink buffer-time=300000 latency-time=20000
/#output = alsasink buffer-time=200000 latency-time=10000
output = alsasink

mixer = software
/#mixer = alsamixer
/#card = 1 
/#control = Master 

[alsamixer]
card = 0
control =  PCM
'''            

