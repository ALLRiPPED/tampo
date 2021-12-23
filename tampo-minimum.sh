#!/bin/bash
#Minimal TAMPO Script
ver="v1.01"
SCRIPT_LOC="/home/pi/.tampo/BGM.py"
INSTALL_DIR=$(dirname "${SCRIPT_LOC}")
MUSIC_DIR="/home/pi/RetroPie/roms/music"
MUSIC_DIR="${MUSIC_DIR/#~/$HOME}"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BACKTITLE="TAMPO Script $ver"
TITLE="TAMPO $ver"
AUTOSTART="/opt/retropie/configs/all/autostart.sh"
OLDIFS=$IFS
RUNONSTART="/opt/retropie/configs/all/runcommand-onstart.sh"
ES_SETTINGS="/opt/retropie/configs/all/emulationstation/es_settings.cfg"
SPL_DIR="/home/pi/RetroPie/splashscreens"
SPLSCREEN="/etc/splashscreen.list"
EXITSPLS="/opt/retropie/configs/all/emulationstation/scripts/shutdown/exit-splash"
EXITSPLR="/opt/retropie/configs/all/emulationstation/scripts/reboot/exit-splash"
VID_LOD_SCR="/home/pi/RetroPie/videoloadingscreens"

main_menu() {
stats_check
    local choice
    while true; do
        choice=$(dialog --colors --backtitle "TAMPO $ver  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay: $vpos$hpos  Resolution: $resolution" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "Choose An Option Below" 25 85 20 \
            01 "Theme Settings" \
            02 "Music Settings" \
            03 "Overlay Settings" \
            04 "Enable/Disable Exit Splash $exs" \
            05 "Enable/Disable Videoloadingscreens $vls" \
            06 "Set Videoloadingscreens Folder" \
            07 "View TAMPO Disclamer" \
            2>&1 > /dev/tty)
        case "$choice" in
            01) themesettings  ;;
            02) musicsettings  ;;
            03) overlay_menu  ;;
            04) exit_splash  ;;
            05) video_screens  ;;
            06) set_video_screens  ;;
            07) disclaim  ;;
            *) break  ;;
        esac
    done
}
themesettings() {
stats_check
    local choice
    while true; do
        choice=$(dialog --colors --backtitle "Theme Settings - Tampo $ver  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay: $vpos$hpos  Resolution: $resolution" --title " Theme Settings " \
            --ok-label OK --cancel-label Exit \
            --menu "Choose An Option Below" 25 85 20 \
            01 "Enable Halloween Theme" \
            02 "Enable Christmas Theme" \
            03 "Enable Stranger Things Theme" \
            04 "Reset Theme and Disable Music" \
           2>&1 > /dev/tty)
        case "$choice" in
            01) enable_halloween  ;;
            02) enable_xmas  ;;
            03) enable_stranger  ;;
            04) reset_theme  ;;
            *) break  ;;
        esac
    done
}
musicsettings() {
stats_check
    local choice
    while true; do
        choice=$(dialog --colors --backtitle "Music Settings - Tampo $ver  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay: $vpos$hpos  Resolution: $resolution" --title " Music Settings " \
            --ok-label OK --cancel-label Exit \
            --menu "Choose An Option Below" 25 85 20 \
            01 "Enable/Disable Background Music $bgms" \
            02 "Enable/Disable BGM On-Boot $bgmos" \
            03 "Music Selection $ms" \
            04 "Volume Control $vol" \
            05 "Music Start Delay $msd" \
           2>&1 > /dev/tty)
        case "$choice" in
            01) enable_music  ;;
            02) enable_musicos  ;;
            03) music_select  ;;
            04) set_bgm_volume  ;;
            05) music_startdelay  ;;
            *) break  ;;
        esac
    done
}
overlay_menu() {
stats_check
local choice
    while true; do
        choice=$(dialog --colors --backtitle "Choose OverLay Settings  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay: $vpos$hpos  Resolution: $resolution" --title " Overlay Menu " \
            --ok-label OK --cancel-label Back \
            --menu "What action would you like to perform?" 25 85 20 \
            01 "Enable/Disable Overlay $ovs" \
            02 "Enable/Disable Overlay Fadeout $ovf" \
            03 "Adjust Overlay Fadeout Time $oft" \
            04 "Enable/Disable Overlay Rounded Corners $ocr" \
            05 "Enable/Disable Overlay Line Separator $ons" \
            06 "Vertical Position: $vpos" \
            07 "Horizontal Position: $hpos" \
            2>&1 > /dev/tty)
        case "$choice" in
            01) overlay_enable  ;;
            02) overlay_fade_out  ;;
            03) overlay_fade_out_time  ;;
            04) overlay_rounded_corners  ;;
            05) overlay_replace_newline  ;;
            06) overlay_v_pos  ;;
            07) overlay_h_pos  ;;
            *)  break ;;
        esac
    done
}
set_bgm_volume() {
  local CUR_VOL
  CUR_VOL=$(grep "maxvolume =" "$SCRIPT_LOC"|awk '{print $3}' | awk '{print $1 * 100}')
  export CUR_VOL
  local NEW_VOL
  NEW_VOL=$(dialog \
	--backtitle "$BACKTITLE" \
	--title "$TITLE" \
	--rangebox "Set volume level (D+/U-): " 0 50 0 100 "$CUR_VOL" \
	2>&1 >/dev/tty)
if [ -z "$NEW_VOL" ] || [ "$NEW_VOL" == "$CUR_VOL" ]; then return; fi;
  echo "BGM volume set to $NEW_VOL%"
  NEW_VOL=$(echo  "$NEW_VOL" | awk '{print $1 / 100}')
  export NEW_VOL
  CUR_VOL=$(echo  "$CUR_VOL" | awk '{print $1 / 100}')
  export CUR_VOL
perl -p -i -e 's/maxvolume = $ENV{CUR_VOL}/maxvolume = $ENV{NEW_VOL}/g' $SCRIPT_LOC
bgm_check
stats_check
}
music_select() {
stats_check
local choice
    while true; do
        choice=$(dialog --colors --backtitle "Select Your Music Choice  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay POS: $vpos$hpos  Resolution: $resolution" --title " Music Selection " \
            --ok-label OK --cancel-label Back \
            --menu "What action would you like to perform?" 25 85 20 \
            01 "Change Music Folder" \
            02 "Disable Music Folder" \
            2>&1 > /dev/tty)
        case "$choice" in
            01) set_music_dir ;;
            02) disable_music_dir ;;
            *)  break ;;
        esac
    done
}
set_music_dir() {
stats_check
  CUR_DIR=""
  CUR_PLY=""
  SELECTION=""
  SELECT=""
  IFS=$'\n'
  local SELECTION
  CUR_DIR=$(grep "musicdir =" "$SCRIPT_LOC" |(awk '{print $3}') | tr -d '"')/
  export CUR_DIR
  while [ -z $SELECTION ]; do
    [[ "${CUR_DIR}" ]] && CUR_DIR="${CUR_DIR}"/
    local cmd=(dialog --colors \
      --backtitle "$BACKTITLE | Current Folder: $CUR_DIR  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay POS: $vpos$hpos  Resolution: $resolution" \
      --title "$TITLE" \
      --menu "Choose a music directory" 20 70 20 )
    local iterator=1
    local offset=-1
    local options=()
    if [ "$(dirname $CUR_DIR)" != "$CUR_DIR" ]; then
      options+=(0)
      options+=("Parent Directory")
      offset=$(($offset+2))
    fi
    options+=($iterator)
    options+=("<Use This Directory>")
    iterator=$(($iterator+1))
    for DIR in $(find "$CUR_DIR" -maxdepth 1 -mindepth 1 -type d | sort); do
      options+=($iterator)
      options+=("$(basename $DIR)")
      iterator=$(($iterator+1))
    done
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case $choice in
      0) CUR_DIR="$(dirname $CUR_DIR)" ;;
      1) SELECTION="$CUR_DIR" ;;
      '') return ;;
      *) CUR_DIR="$CUR_DIR${options[ $((2*choice + $offset )) ]}" ;;
    esac
  done
  [[ "${MUSIC_DIR}" ]] && MUSIC_DIR="${MUSIC_DIR}"
  if [ "$SELECTION" != "$MUSIC_DIR" ]; then
    echo "Music directory changed to '$SELECTION'"
    CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
    export CUR_PLY
    SELECT=$(echo $SELECTION | sed 's:/*$::')
    sed -i -E "s|musicdir = ${CUR_PLY}|musicdir = \"${SELECT}\"|g" $SCRIPT_LOC
    bgm_check
  elif [ "$SELECTION" == "$MUSIC_DIR" ]; then
    echo "Music directory is already '$SELECTION'"
  else
    return
  fi
  IFS=$OLDIFS
bgm_check
stats_check
}
music_startdelay() {
oldstartdelaytime=$(grep "startdelay = " "$SCRIPT_LOC"|awk '{print $3}')
export oldstartdelaytime
startdelaytime=$(dialog --colors --title "Adjust the Music Start Delay" \
	--inputbox "Input the Start Delay Time:" 8 40 "$oldstartdelaytime" 3>&1 1>&2 2>&3 3>&-)
export startdelaytime
if [ $startdelaytime ]; then
perl -p -i -e 's/startdelay = $ENV{oldstartdelaytime}/startdelay = $ENV{startdelaytime}/g' $SCRIPT_LOC
else
	return
fi
bgm_check
stats_check
}
enable_halloween() {
CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
NEW_PLY='"/home/pi/RetroPie/roms/music/halloween"'
CUR_THM=$(grep "<string name=\"ThemeSet\"" "$ES_SETTINGS"|awk '{print $3}')
NEW_THM="value=\"halloweenspecial\""
HAL_LOD=$(grep "videoloadingscreens=" "$RUNONSTART"|grep -o '".*"')
NEWH_LOD='"/home/pi/RetroPie/videoloadingscreens/halloween"'
CUR_SEXS=$(grep "sudo omxplayer" "$EXITSPLS"|awk '{print $8}')
CUR_REXS=$(grep "sudo omxplayer" "$EXITSPLR"|awk '{print $8}')
NEWH_EXS='"/home/pi/RetroPie/splashscreens/HalloweenExit.mp4"'
if [[ $CUR_THM == $NEW_THM ]]; then echo "Halloween Theme already set!"; else sed -i -E "s|${CUR_THM}|${NEW_THM}|g" $ES_SETTINGS; fi
if [[ $CUR_PLY == $NEW_PLY ]]; then echo "Halloween Music already set!"; else sed -i -E "s|musicdir = ${CUR_PLY}|musicdir = ${NEW_PLY}|g" $SCRIPT_LOC; fi 
if [[ $HAL_LOD == $NEWH_LOD ]]; then echo "Halloween Videoloadingscreens already set!"; else sed -i -E "s|videoloadingscreens=${HAL_LOD}|videoloadingscreens=${NEWH_LOD}|g" $RUNONSTART; fi
sudo sed -i -E "s/.*/\/home\/pi\/RetroPie\/splashscreens\/Halloween.mp4/" $SPLSCREEN
echo "Restarting EmulationStaion..."
pgrep -f "python "$SCRIPT_LOC|xargs sudo kill -9 > /dev/null 2>&1 &
pgrep -f pngview|xargs sudo kill -9 > /dev/null 2>&1 &
sleep 1
killall emulationstation
sleep 1
if [[ $CUR_SEXS == $NEWH_EXS ]] && [[ $CUR_REXS == $NEWH_EXS ]]; then echo "Halloween Exit Splash already set!"
else sed -i -E "s|${CUR_SEXS}|${NEWH_EXS}|g" $EXITSPLS; sed -i -E "s|${CUR_REXS}|${NEWH_EXS}|g" $EXITSPLR; fi
sudo openvt -c 1 -s -f emulationstation 2>&1
exit
}
enable_stranger() {
CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
NEW_PLY='"/home/pi/RetroPie/roms/music/strangerthings"'
CUR_THM=$(grep "<string name=\"ThemeSet\"" "$ES_SETTINGS"|awk '{print $3}')
NEW_THM="value=\"strangerstuff\""
STR_LOD=$(grep "videoloadingscreens=" "$RUNONSTART"|grep -o '".*"')
NEWS_LOD='"/home/pi/RetroPie/videoloadingscreens/strangerpi"'
CUR_SEXS=$(grep "sudo omxplayer" "$EXITSPLS"|awk '{print $8}')
CUR_REXS=$(grep "sudo omxplayer" "$EXITSPLR"|awk '{print $8}')
NEWS_EXS='"/home/pi/RetroPie/splashscreens/StrangerExit.mp4"'
if [[ $CUR_THM == $NEW_THM ]]; then echo "Stranger Pi Theme already set!"; else sed -i -E "s|${CUR_THM}|${NEW_THM}|g" $ES_SETTINGS; fi
if [[ $CUR_PLY == $NEW_PLY ]]; then echo "Stranger Pi Music already set!"; else sed -i -E "s|musicdir = ${CUR_PLY}|musicdir = ${NEW_PLY}|g" $SCRIPT_LOC; fi 
if [[ $STR_LOD == $NEWS_LOD ]]; then echo "Stranger Pi Videoloadingscreens already set!"; else sed -i -E "s|videoloadingscreens=${STR_LOD}|videoloadingscreens=${NEWS_LOD}|g" $RUNONSTART; fi
sudo sed -i -E "s/.*/\/home\/pi\/RetroPie\/splashscreens\/StrangerPi.mp4/" $SPLSCREEN
echo "Restarting EmulationStaion..."
pgrep -f "python "$SCRIPT_LOC|xargs sudo kill -9 > /dev/null 2>&1 &
pgrep -f pngview|xargs sudo kill -9 > /dev/null 2>&1 &
sleep 1
killall emulationstation
sleep 1
if [[ $CUR_SEXS == $NEWS_EXS ]] && [[ $CUR_REXS == $NEWS_EXS ]]; then echo "Stranger Things Exit Splash already set!"
else sed -i -E "s|${CUR_SEXS}|${NEWS_EXS}|g" $EXITSPLS; sed -i -E "s|${CUR_REXS}|${NEWS_EXS}|g" $EXITSPLR; fi
sudo openvt -c 1 -s -f emulationstation 2>&1
exit
}
enable_xmas() {
CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
NEW_PLY='"/home/pi/RetroPie/roms/music/xmas"'
CUR_THM=$(grep "<string name=\"ThemeSet\"" "$ES_SETTINGS"|awk '{print $3}')
NEW_THM="value=\"merryxmas\""
XMA_LOD=$(grep "videoloadingscreens=" "$RUNONSTART"|grep -o '".*"')
NEWX_LOD='"/home/pi/RetroPie/videoloadingscreens/xmas"'
CUR_SEXS=$(grep "sudo omxplayer" "$EXITSPLS"|awk '{print $8}')
CUR_REXS=$(grep "sudo omxplayer" "$EXITSPLR"|awk '{print $8}')
NEWX_EXS='"/home/pi/RetroPie/splashscreens/XmasExit.mp4"'
if [[ $CUR_THM == $NEW_THM ]]; then echo "Christmas Theme already set!"; else sed -i -E "s|${CUR_THM}|${NEW_THM}|g" $ES_SETTINGS; fi
if [[ $CUR_PLY == $NEW_PLY ]]; then echo "Christmas Music already set!"; else sed -i -E "s|musicdir = ${CUR_PLY}|musicdir = ${NEW_PLY}|g" $SCRIPT_LOC; fi 
if [[ $XMA_LOD == $NEWX_LOD ]]; then echo "Christmas Videoloadingscreens already set!"; else sed -i -E "s|videoloadingscreens=${XMA_LOD}|videoloadingscreens=${NEWX_LOD}|g" $RUNONSTART; fi
sudo sed -i -E "s/.*/\/home\/pi\/RetroPie\/splashscreens\/CharlieBrown.mp4/" $SPLSCREEN
echo "Restarting EmulationStaion..."
pgrep -f "python "$SCRIPT_LOC|xargs sudo kill -9 > /dev/null 2>&1 &
pgrep -f pngview|xargs sudo kill -9 > /dev/null 2>&1 &
sleep 1
killall emulationstation
sleep 1
if [[ $CUR_SEXS == $NEWX_EXS ]] && [[ $CUR_REXS == $NEWX_EXS ]]; then echo "Christmas Exit Splash already set!"
else sed -i -E "s|${CUR_SEXS}|${NEWX_EXS}|g" $EXITSPLS; sed -i -E "s|${CUR_REXS}|${NEWX_EXS}|g" $EXITSPLR; fi
sudo openvt -c 1 -s -f emulationstation 2>&1
exit
}
reset_theme() {
CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
NEW_PLY='"/home/pi/.tampo"'
CUR_THM=$(grep "<string name=\"ThemeSet\"" "$ES_SETTINGS"|awk '{print $3}')
NEW_THM="value=\"carbonite\""
NOR_LOD=$(grep "videoloadingscreens=" "$RUNONSTART"|grep -o '".*"')
NEWN_LOD='"/home/pi/RetroPie/videoloadingscreens/jarvis"'
CUR_SEXS=$(grep "sudo omxplayer" "$EXITSPLS"|awk '{print $8}')
CUR_REXS=$(grep "sudo omxplayer" "$EXITSPLR"|awk '{print $8}')
NEWD_EXS="/home/pi/RetroPie/splashscreens/JarvisExit.mp4"
if [ $CUR_THM == $NEW_THM ]; then echo "Theme already set!"; else sed -i -E "s|${CUR_THM}|${NEW_THM}|g" $ES_SETTINGS; fi
if [ $CUR_PLY == $NEW_PLY ]; then echo "Music already set!"; else sed -i -E "s|musicdir = ${CUR_PLY}|musicdir = ${NEW_PLY}|g" $SCRIPT_LOC; fi 
if [[ $NOR_LOD == $NEWN_LOD ]]; then echo "Videoloadingscreens already set!"; else sed -i -E "s|videoloadingscreens=${NOR_LOD}|videoloadingscreens=${NEWN_LOD}|g" $RUNONSTART; fi
if [ -f /home/pi/RetroPie/splashscreens/JarvisSplash.mp4 ]; then sudo sed -i -E "s/.*/\/home\/pi\/RetroPie\/splashscreens\/JarvisSplash.mp4/" $SPLSCREEN
else sudo sed -i -E "s/.*/\/opt\/retropie\/supplementary\/splashscreen\/retropie-default.png/" $SPLSCREEN; fi
echo "Restarting EmulationStaion..."
pgrep -f "python "$SCRIPT_LOC|xargs sudo kill -9 > /dev/null 2>&1 &
pgrep -f pngview|xargs sudo kill -9 > /dev/null 2>&1 &
sleep 1
killall emulationstation
sleep 1
if [[ $CUR_SEXS == $NEWD_EXS ]] && [[ $CUR_REXS == $NEWD_EXS ]]; then echo "Christmas Exit Splash already set!"
else sed -i -E "s|${CUR_SEXS}|${NEWD_EXS}|g" $EXITSPLS; sed -i -E "s|${CUR_REXS}|${NEWD_EXS}|g" $EXITSPLR; fi
sudo openvt -c 1 -s -f emulationstation 2>&1
exit
}
enable_music() {
if [ -f "$INSTALL_DIR"/DisableMusic ]; then
	sudo rm -f "$INSTALL_DIR"/DisableMusic
	(nohup python $SCRIPT_LOC > /dev/null 2>&1) &
else
	touch "$INSTALL_DIR"/DisableMusic
	pgrep -f "python "$SCRIPT_LOC|xargs sudo kill -9 > /dev/null 2>&1 &
	pgrep -f pngview|xargs sudo kill -9 > /dev/null 2>&1 &
fi
sleep 1
stats_check
}
enable_musicos() {
if grep -q "#(nohup python $SCRIPT_LOC > /dev/null 2>&1) &" "$AUTOSTART"; then
	sudo sed -i 's/\#(nohup python/(nohup python/g' $AUTOSTART
elif grep -q "(nohup python $SCRIPT_LOC > /dev/null 2>&1) &" "$AUTOSTART"; then
	sudo sed -i 's/(nohup python/\#(nohup python/g' $AUTOSTART
fi
stats_check
}
disable_music_dir() {
CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
export CUR_PLY
DEF_DIR='"/home/pi/.tampo"'
export DEF_DIR
sed -i -E "s|musicdir = ${CUR_PLY}|musicdir = ${DEF_DIR}|g" $SCRIPT_LOC
bgm_check
stats_check
}
exit_splash() {
if [ -f "$SPL_DIR/HalloweenExitOff.mp4" ] && [ -f "$SPL_DIR/JarvisExitOff.mp4" ] && [ -f "$SPL_DIR/XmasExitOff.mp4" ] && [ -f "$SPL_DIR/StrangerExitOff.mp4" ]
then
	sudo mv -f $SPL_DIR/HalloweenExitOff.mp4 $SPL_DIR/HalloweenExit.mp4
	sudo mv -f $SPL_DIR/JarvisExitOff.mp4 $SPL_DIR/JarvisExit.mp4
	sudo mv -f $SPL_DIR/StrangerExitOff.mp4 $SPL_DIR/StrangerExit.mp4
	sudo mv -f $SPL_DIR/XmasExitOff.mp4 $SPL_DIR/XmasExit.mp4
else
	sudo mv -f $SPL_DIR/HalloweenExit.mp4 $SPL_DIR/HalloweenExitOff.mp4
	sudo mv -f $SPL_DIR/JarvisExit.mp4 $SPL_DIR/JarvisExitOff.mp4
	sudo mv -f $SPL_DIR/StrangerExit.mp4 $SPL_DIR/StrangerExitOff.mp4
	sudo mv -f $SPL_DIR/XmasExit.mp4 $SPL_DIR/XmasExitOff.mp4
fi
stats_check
}
video_screens() {
if grep -q 'enablevideolaunch="true"' "$RUNONSTART"; then sed -i -E 's|enablevideolaunch="true"|enablevideolaunch="false"|g' $RUNONSTART
else sed -i -E 's|enablevideolaunch="false"|enablevideolaunch="true"|g' $RUNONSTART; fi
stats_check
}
set_video_screens() {
stats_check
  CUR_LOD=""
  NEW_LOD=""
  SELECTION=""
  SELECT=""
  IFS=$'\n'
  local SELECTION
  CUR_LOD=$(grep "videoloadingscreens=" "$RUNONSTART"|grep -o '".*"' | tr -d '"')
  export CUR_LOD
  while [ -z $SELECTION ]; do
    [[ "${CUR_LOD}" ]] && CUR_LOD="${CUR_LOD}"/
    local cmd=(dialog --colors \
      --backtitle "$BACKTITLE | Current Folder: $CUR_LOD  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay POS: $vpos$hpos  Resolution: $resolution" \
      --title "$TITLE" \
      --menu "Choose a Videoloadingscreens directory" 20 70 20 )
    local iterator=1
    local offset=-1
    local options=()
    if [ "$(dirname $CUR_LOD)" != "$CUR_LOD" ]; then
      options+=(0)
      options+=("Parent Directory")
      offset=$(($offset+2))
    fi
    options+=($iterator)
    options+=("<Use This Directory>")
    iterator=$(($iterator+1))
    for DIR in $(find "$CUR_LOD" -maxdepth 1 -mindepth 1 -type d | sort); do
      options+=($iterator)
      options+=("$(basename $DIR)")
      iterator=$(($iterator+1))
    done
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case $choice in
      0) CUR_LOD="$(dirname $CUR_LOD)" ;;
      1) SELECTION="$CUR_LOD" ;;
      '') return ;;
      *) CUR_LOD="$CUR_LOD${options[ $((2*choice + $offset )) ]}" ;;
    esac
  done
  [[ "${VID_LOD_SCR}" ]] && VID_LOD_SCR="${VID_LOD_SCR}"
  if [ "$SELECTION" != "$VID_LOD_SCR" ]; then
    echo "Videoloadingscreens directory changed to '$SELECTION'"
    NEW_LOD=$(grep "videoloadingscreens=" "$RUNONSTART"|grep -o '".*"')
    export NEW_LOD
    SELECT=$(echo $SELECTION | sed 's:/*$::')
	sed -i -E "s|videoloadingscreens=${NEW_LOD}|videoloadingscreens=\"${SELECT}\"|g" $RUNONSTART
    bgm_check
  elif [ "$SELECTION" == "$VID_LOD_SCR" ]; then
    echo "Videoloadingscreens directory is already '$SELECTION'"
  else
    return
  fi
  IFS=$OLDIFS
bgm_check
stats_check
}
overlay_enable() {
if grep -q 'overlay_enable = True' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_enable = True/overlay_enable = False/g' $SCRIPT_LOC
elif grep -q 'overlay_enable = False' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_enable = False/overlay_enable = True/g' $SCRIPT_LOC
fi
bgm_check
stats_check
}
overlay_fade_out() {
if grep -q 'overlay_fade_out = True' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_fade_out = True/overlay_fade_out = False/g' $SCRIPT_LOC
elif grep -q 'overlay_fade_out = False' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_fade_out = False/overlay_fade_out = True/g' $SCRIPT_LOC
fi
bgm_check
stats_check
}
overlay_fade_out_time() {
oldfadeouttime=$(grep "overlay_fade_out_time = " "$SCRIPT_LOC"|awk '{print $3}')
export oldfadeouttime
fadeouttime=$(dialog \
	--colors \
	--title "Adjust the Fadeout time of the Relay" \
	--inputbox "Input the Relay Fadeout Time:" 8 40 "$oldfadeouttime" 3>&1 1>&2 2>&3 3>&-)
export fadeouttime
if [ $fadeouttime ]; then
perl -p -i -e 's/overlay_fade_out_time = $ENV{oldfadeouttime}/overlay_fade_out_time = $ENV{fadeouttime}/g' $SCRIPT_LOC
else
	return
fi
bgm_check
stats_check
}
overlay_rounded_corners() {
if grep -q 'overlay_rounded_corners = True' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_rounded_corners = True/overlay_rounded_corners = False/g' $SCRIPT_LOC
elif grep -q 'overlay_rounded_corners = False' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_rounded_corners = False/overlay_rounded_corners = True/g' $SCRIPT_LOC
fi
bgm_check
stats_check
}
overlay_replace_newline() {
if grep -q 'overlay_replace_newline = True' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_replace_newline = True/overlay_replace_newline = False/g' $SCRIPT_LOC
elif grep -q 'overlay_replace_newline = False' "$SCRIPT_LOC"; then
	sed -i -E 's/overlay_replace_newline = False/overlay_replace_newline = True/g' $SCRIPT_LOC
fi
bgm_check
stats_check
}
overlay_v_pos() {
CUR_VPOS=$(grep "overlay_y_offset =" "$SCRIPT_LOC"|awk '{print $3}')
export CUR_VPOS
NEW_VPOST='"0"'
export NEW_VPOST
NEW_VPOSB=\"$((height-overlay_h_size))\"
export NEW_VPOSB
if [ $CUR_VPOS = \"0\" ]; then
	sed -i -E "s/overlay_y_offset = ${CUR_VPOS}/overlay_y_offset = ${NEW_VPOSB}/g" $SCRIPT_LOC
else
	sed -i -E "s/overlay_y_offset = ${CUR_VPOS}/overlay_y_offset = ${NEW_VPOST}/g" $SCRIPT_LOC
fi
bgm_check
stats_check
}
overlay_h_pos() {
CUR_HPOS=$(grep "overlay_x_offset =" "${SCRIPT_LOC}"|awk '{print $3}')
export CUR_HPOS
NEW_HPOSL='"0"'
export NEW_HPOSL
NEW_HPOSR=\"$((width-overlay_w_size))\"
export NEW_HPOSR
if [ $CUR_HPOS = \"0\" ]; then
	sed -i -E "s/overlay_x_offset = ${CUR_HPOS}/overlay_x_offset = ${NEW_HPOSR}/g" $SCRIPT_LOC
else
	sed -i -E "s/overlay_x_offset = ${CUR_HPOS}/overlay_x_offset = ${NEW_HPOSL}/g" $SCRIPT_LOC
fi
bgm_check
stats_check
}
stats_check() {
enable="(\Z2Enabled\Zn)"
disable="(\Z1Disabled\Zn)"
if [ -f /home/pi/.tampo/DisableMusic ]; then
	bgms=$disable
else
	bgms=$enable
fi
if grep -q "#(nohup python $SCRIPT_LOC > /dev/null 2>&1) &" "$AUTOSTART"; then
	bgmos=$disable
elif grep -q "(nohup python $SCRIPT_LOC > /dev/null 2>&1) &" "$AUTOSTART"; then
	bgmos=$enable
fi
if grep -q "overlay_enable = True" "$SCRIPT_LOC"; then
	ovs=$enable
else
	ovs=$disable
fi
if grep -q "overlay_fade_out = True" "$SCRIPT_LOC"; then
	ovf=$enable
else
	ovf=$disable
fi
overlay_fadeout_time=$(grep "overlay_fade_out_time = " "$SCRIPT_LOC"|awk '{print $3}')
oft="(\Z3$overlay_fadeout_time Sec\Zn)"
msd=$(grep "startdelay = " "$SCRIPT_LOC"|awk '{print $3}')
msd="(\Z3$msd Sec.\Zn)"
if grep -q "overlay_rounded_corners = True" "$SCRIPT_LOC"; then
	ocr=$enable
else
	ocr=$disable
fi
if grep -q "overlay_replace_newline = True" "$SCRIPT_LOC"; then
	ons=$enable
else
	ons=$disable
fi
CUR_HPOS=$(grep "overlay_x_offset =" "$SCRIPT_LOC"|awk '{print $3}' | tr -d '"')
if [ $CUR_HPOS = "0" ]; then
	hpos="(\Z3Left\Zn)"
else
	hpos="(\Z3Right\Zn)"
fi
CUR_VPOS=$(grep "overlay_y_offset =" "$SCRIPT_LOC"|awk '{print $3}' | tr -d '"')
export CUR_VPOS
if [ $CUR_VPOS = "0" ]; then
	vpos="(\Z3Top\Zn)"
else
	vpos="(\Z3Bottom\Zn)"
fi
if grep -q 'musicdir = "/home/pi/.tampo"' "$SCRIPT_LOC"; then
	ms=$disable
elif grep -q 'musicdir = "/home/pi/RetroPie/roms/music/halloween"' "$SCRIPT_LOC"; then
	ms="(\Z3Halloween\Zn)"
elif grep -q 'musicdir = "/home/pi/RetroPie/roms/music/xmas"' "$SCRIPT_LOC"; then
	ms="(\Z3Christmas\Zn)"
elif grep -q 'musicdir = "/home/pi/RetroPie/roms/music/strangerthings"' "$SCRIPT_LOC"; then
	ms="(\Z3StrangerThings\Zn)"
else
	CUR_PLY=$(grep "musicdir =" "$SCRIPT_LOC"|awk '{print $3}')
	export CUR_PLY
	ms="(\Z3$(basename $CUR_PLY | tr -d '"')\Zn)"
fi
THEME=$(grep "<string name=\"ThemeSet\"" "$ES_SETTINGS"|awk '{print $3}')
if [[ $THEME == value=\"strangerstuff\" ]]; then
	ts="(\Z3Stranger Things\Zn)"
elif [[ $THEME == value=\"halloweenspecial\" ]]; then
	ts="(\Z3Halloween\Zn)"
elif [[ $THEME == value=\"merryxmas\" ]]; then
	ts="(\Z3Christmas\Zn)"
else ts="(\Z3Default\Zn)"; fi
vol=$(grep "maxvolume =" "$SCRIPT_LOC"|awk '{print $3}' | awk '{print $1 * 100}')
vol="(\Z3$vol%\Zn)"
if [ -f $SPL_DIR/JarvisExitOff.mp4 ]; then exs=$disable; else exs=$enable; fi
if grep -q 'enablevideolaunch="true"' "$RUNONSTART"; then vls=$enable; else vls=$disable; fi
width=$(fbset -fb /dev/fb0 | grep '\".*\"' | grep -m 1 -o '[0-9][0-9][0-9]\+x' | tr -d 'x')
height=$(fbset -fb /dev/fb0 | grep '\".*\"' | grep -m 1 -o 'x[0-9][0-9][0-9]\+' | tr -d 'x')
if [ "${width}" -ge 3800 ] && [ "${height}" -ge 2100 ]; then
	res="2160p"
elif [ "${width}" -ge 1900 ] && [ "${height}" -ge 1000 ] && [ "${width}" -le 2100 ] && [ "${height}" -le 3800 ]; then
	res="1080p"
elif [ "${width}" -ge 1000 ] && [ "${height}" -ge 600 ] && [ "${width}" -le 1900 ] && [ "${height}" -le 1000 ]; then
	res="720p"
elif [ "${height}" -le 599 ]; then
	res="SD"
fi
resolution="(\Z3$res\Zn)"
if [ "${width}" -ge 1900 ] && [ "${height}" -ge 1000 ]; then
	overlay_w_size=600
	overlay_h_size=32
elif [ "${width}" -ge 1000 ] && [ "${height}" -ge 600 ] && [ "${width}" -le 1900 ] && [ "${height}" -le 1000 ]; then
	overlay_w_size=300
	overlay_h_size=21
elif [ "${height}" -le 599 ]; then
	overlay_w_size=150
	overlay_h_size=15
fi
}
bgm_check() {
if [ -f "$INSTALL_DIR"/DisableMusic ]; then
	echo "Background Music Disabled!"
else
	pgrep -f "python "$SCRIPT_LOC |xargs sudo kill -9 > /dev/null 2>&1 &
	pgrep -f pngview|xargs sudo kill -9 > /dev/null 2>&1 &
	sleep 1
	(nohup python $SCRIPT_LOC > /dev/null 2>&1) &
fi
sleep 1
}
disclaim() {
DISCLAIMER=""
DISCLAIMER="${DISCLAIMER}_______________________________________________________\n\n"
DISCLAIMER="${DISCLAIMER}\n"
DISCLAIMER="${DISCLAIMER}TAMPO: Theme and Music Plus Overlay Script\n\n"
DISCLAIMER="${DISCLAIMER}The background music python and control scripts have been installed on this system.\n"
DISCLAIMER="${DISCLAIMER}This script will play MP3 & OGG files during menu navigation in either Emulation Station or Attract mode.\n"
DISCLAIMER="${DISCLAIMER}A Few subfolders have been created in the /home/pi/RetroPie/roms/music directory with a selection of\n"
DISCLAIMER="${DISCLAIMER}different music from various builds by many good build makers.\n"
DISCLAIMER="${DISCLAIMER}The themes you can seltect bewteen are \"halloween\" (Halloween), \"xmas\" (Christmas),\n"
DISCLAIMER="${DISCLAIMER}\"strangerthings\" (Stranger Things) and \"carbonite\" (Default).\n"
DISCLAIMER="${DISCLAIMER}This includes the themes, music, plus game splash, launching/loading, and exit screens.\n"
DISCLAIMER="${DISCLAIMER}Launch a game, the music will stop. Upon exiting out of the game the music will begin playing again.\n"
DISCLAIMER="${DISCLAIMER}This also lets you turn off certain options for BGM.py such as, Enable/Disable the Overlay, Fadeout effect,\n"
DISCLAIMER="${DISCLAIMER}Rounded Corners on Overlays, an option to turn the dashes, or hyphens, with a space on both sides\n"
DISCLAIMER="${DISCLAIMER}\" - \"\n"
DISCLAIMER="${DISCLAIMER}and separate the song title to a separate new lines.\n"
DISCLAIMER="${DISCLAIMER}\n"
DISCLAIMER="${DISCLAIMER}Overlay disappeared when you change resolutions? Set postion to Top-Left so you can see it,\n"
DISCLAIMER="${DISCLAIMER}then set it to desired postition, the overlay is compatible with all resolutions.\n"
DISCLAIMER="${DISCLAIMER}\n"
DISCLAIMER="${DISCLAIMER}https://github.com/ALLRiPPED/tampo\n"
dialog --colors --backtitle "TAMPO Control Script $ver  BGM Status $bgms  Volume: $vol  Theme: $ts  Music: $ms  Overlay: $vpos$hpos  Resolution: $resolution" \
--title "DISCLAIMER" \
--msgbox "${DISCLAIMER}" 35 110
}
main_menu
