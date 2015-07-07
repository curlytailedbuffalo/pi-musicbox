import RPi.GPIO as GPIO
import time
import os

# Initialize the Raspberry Pi GPIO Pins Being Used
#  later to be assigned to variables
print('[ \033[0;33mWorking\033[0m ] Initializing pi GPIO\'s ...')
GPIO.setmode(GPIO.BCM)
GPIO.setup(13, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(19, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(6, GPIO.IN, pull_up_down=GPIO.PUD_UP)
print('[ \033[0;32mOK\033[0m ] GPIO\'s initialized.')

# Set the sleep timeout between aaccepting button presses
#  On off button has longer sleep to allow both buttons to 
#  get pressed at the same time.
print('[ \033[0;33mWorking\033[0m ] Setting sleep variables ...')
sleep_btn = 0.4
sleep_onoff = 0.5
sleep_loop = 0.2
print('[ \033[0;32mOK\033[0m ] Sleep variables set.')

# Continually loop, checking input values on each loop
#  Pressed button is set as False
print('[ \033[0;33mWorking\033[0m ] Starting while loop ...')
temp = 0

time.sleep(0.5)
monitor = True
while monitor == True:
    if temp == 0:
        print('[ \033[0;32mOK\033[0m ] Loop started.')
        time.sleep(0.2)
        print('[ \033[0;32mOK\033[0m ] Listening for button presses ... Writen progress is disabled')
        print(' ')
        temp = 1
        
    # Set initialized GPIO's as usable variables
    previous_track = GPIO.input(6)
    next_track = GPIO.input(19)
    volume_up = GPIO.input(13)
    volume_down = GPIO.input(26) 
    
    if volume_up == False and volume_down == False and next_track != False and previous_track != False:
        print('Toggle play/pause')
        os.system('mpc -q toggle')
        time.sleep(sleep_onoff)
    if volume_up == False and volume_down != False and next_track != False and previous_track != False:
        #print('Volume up...')
        os.system('mpc -q volume +2 ')
        time.sleep(0.2)
        vup = GPIO.input(13)
        while vup == False:
            vdown = GPIO.input(26)
            ntrack = GPIO.input(19)
            ptrack = GPIO.input(6)
            if vdown != False and ptrack != False and ntrack != False:
                os.system('mpc -q volume +5 ')
                #print('Volume up...')
                vup = GPIO.input(13)
                time.sleep(0.1)
            elif vdown == False and ptrack != False and ntrack != False:
                os.system('mpc -q toggle')
                print('Toggle play/pause')
                time.sleep(sleep_onoff)
                vup = True
    elif volume_down == False and volume_up != False and next_track != False and previous_track != False:
        #print('Volume down...')
        os.system('mpc -q volume -2')
        time.sleep(0.2)
        vdown = GPIO.input(26)
        while vdown == False:
            vup = GPIO.input(13)
            ntrack = GPIO.input(19)
            ptrack = GPIO.input(6)
            if vup != False and ptrack != False and ntrack != False:
                #print('Volume down...')
                os.system('mpc -q volume -5 ')
                vdown = GPIO.input(26)
                time.sleep(0.1)
            elif vup == False and ptrack != False and ntrack != False:
                os.system('mpc -q toggle')
                print('Toggle play/pause')
                time.sleep(sleep_onoff)
                vdown = True
    elif next_track == False and previous_track == False and volume_up != False and volume_down != False:
        print('Manual loading main playlist...')
        os.system('/opt/speech.sh "google" 10 "Reloading main radio playlist."')
        os.system('mpc -q clear')
        os.system('mpc -q load My-Radio-Stations')
        os.system('mpc -q play')
        time.sleep(sleep_onoff)
    elif next_track == False and previous_track != False and volume_up != False and volume_down != False:
        #print('Next station...')
        os.system('mpc -q next')
        time.sleep(0.2)
        ntrack = GPIO.input(19)
        while ntrack == False:
            ptrack = GPIO.input(6)
            vup = GPIO.input(13)
            vdown = GPIO.input(26)
            if ptrack == False and vup != False and vdown != False:
                print('Manual loading main playlist...')
                os.system('/opt/speech.sh "google" 10 "Reloading main radio playlist."')
                os.system('mpc -q clear')
                os.system('mpc -q load My-Radio-Stations')
                os.system('mpc -q play')
                ntrack = True
                time.sleep(sleep_onoff)
            else:
                ntrack = True
    elif previous_track == False and next_track != False and volume_up != False and volume_down != False:
        #print('Previous station...')
        os.system('mpc -q prev')
        time.sleep(0.2)
        ptrack = GPIO.input(6)
        while ptrack == False:
            ntrack = GPIO.input(19)
            vup = GPIO.input(13)
            vdown = GPIO.input(26)
            if ntrack == False and vup != False and vdown != False:
                print('Manual loading main playlist...')
                os.system('/opt/speech.sh "google" 10 "Reloading main radio playlist."')
                os.system('mpc -q clear')
                os.system('mpc -q load My-Radio-Stations')
                os.system('mpc -q play')
                ptrack = True
                time.sleep(sleep_onoff)
            else:
                ptrack = True
    elif volume_up == False and volume_down == False and next_track == False and previous_track == False:
        os.system('mpc -q stop')
        print('\n** Entering Game Mode **\n')
        os.system('python /opt/higherlower.py')
        monitor = False
    else:
        time.sleep(sleep_loop)
os.system('mpc -q stop')
print('[ \033[0;32mOK\033[0m ] Shutting down, button presses will be monitored by the new mode.')
