#!/bin/bash

# Send a speech string to google translate, limited to 100 characters, use mplayer for playback
saygoogle() { 
    local IFS=+;/usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols -softvol -volume $1 "http://translate.google.com/translate_tts?tl=en&q=${*:2}"; 
}

# Send an mp3 file to mplayer, used for tts mp3 files while offline and coannot connect to google
saymp3() {
    /usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols -softvol -volume $1 "$2"; 
}

TYPE=$1
VOL=$2

if [ "$TYPE" == "mp3" ]
then
    SPEECH=$3
    saymp3 $VOL $SPEECH
elif [ "$TYPE" == "google" ]
then
    SPEECH=${*:3}
    saygoogle $VOL $SPEECH
fi
