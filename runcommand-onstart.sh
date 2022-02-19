#!/bin/sh
### Begin VideoLoading Screens Function
enablevideolaunch="true"
videoloadingscreens="/home/pi/RetroPie/videoloadingscreens/jarvis"
if [[ $enablevideolaunch == "true" ]]; then
 # Extract file name from called ROM
 gname="$(basename "$3")"
 # build path to file and remove extension from ROM to add mp4 extension
 # $HOME variable will help users that are not stick to raspberry ;)
 ifgame="$videoloadingscreens/$1/${gname%.*}.mp4"
 ifsystem="$videoloadingscreens/$1.mp4"
 default="$videoloadingscreens/default.mp4"

 # If condition to check filename with -f switch, f means regular file
 if [[ -f $ifgame ]]; then
    omxplayer --vol 500 --amp 250 -b "$ifgame" > /dev/null 2>&1
 elif [[ -f $ifsystem ]]; then
    omxplayer --vol 500 --amp 250 -b "$ifsystem" > /dev/null 2>&1
 elif [[ -f $default ]]; then
    omxplayer --vol 500 --amp 250 -b "$default" > /dev/null 2>&1
 fi
fi
### End VideoLoading Screens Function
