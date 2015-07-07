#!/bin/bash
    _IP=$(hostname -I) || true
    IFS=', ' read -a ipv4array <<< "$_IP"
    myipv4="${ipv4array[0]}";
    readablemyipv4=${myipv4//"0"/"zero "};
    readablemyipv4=${readablemyipv4//"1"/"one "};
    readablemyipv4=${readablemyipv4//"2"/"two "};
    readablemyipv4=${readablemyipv4//"3"/"three "};
    readablemyipv4=${readablemyipv4//"4"/"four "};
    readablemyipv4=${readablemyipv4//"5"/"five "};
    readablemyipv4=${readablemyipv4//"6"/"six "};
    readablemyipv4=${readablemyipv4//"7"/"seven "};
    readablemyipv4=${readablemyipv4//"8"/"eight "};
    readablemyipv4=${readablemyipv4//"9"/"nine "};
    readablemyipv4=${readablemyipv4//"."/",dot,"};
    echo $readablemyipv4;
