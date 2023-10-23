#!/data/data/com.termux/files/usr/bin/bash
# Usage : bash playx FILE 
#               bash -xv playx FILE 
# dependencies :
#                    - mpv
#                    - bc package 
#    

#
## Fitur :
# Program akan berhenti secara bersih ketika pengguna selesai menonton/mendengarkan musik
# program tidak membutuhkan root murni hanya dengan API termux 
#
# Copyright (c) 2023 @luisadha
# MIT License 
# bug fixed
# version 1.0.2

function convertime() {
    local T=$1;
    local D=$((T/60/60/24));
    local H=$((T/60/60%24));
    local M=$((T/60%60));
    local S=$((T%60));
    (( $D > 0 )) && printf '%d days ' $D;
    (( $H > 0 )) && printf '%d hours ' $H;
    (( $M > 0 )) && printf '%d minutes ' $M;
    (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and ';
    printf '%d seconds\n' $S
}
function set_window() {

    title="$*"
    echo -ne "\033]0;$title \007"
}

set_window "Track currently is playing, don't suspend it!"

if [ $# -ne 1 ]; then
echo "$(basename $0): no file given! "
echo ''
exit 1
fi
nohup mpv "${1}" & 2>/dev/null;
sleep 1
 kill -TERM $!
clear
# set -xv
termux-toast "Please tick remember my choice, once you see the popup!"

DURASIFIX=$(cat nohup.out | grep '(' | awk '{print $4}' | tail -n 2 | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')

function bagianinisudahtidakdipakai {
DURASI=$(cat nohup.out | grep '(' | awk '{print $4}' | tail -n 2 | sed 's/[:]//g' | sed 's/d/*24*3600 +/g; s/h/*3600 +/g; s/m/*60 +/g; s/s/\+/g; s/+[ ]*$//g' )
echo $DURASI
DURASI="$(echo "${DURASI}" | bc | sed 's/\(\b[0-9]\)/\(\1\)/g' )"
echo $DURASI
DURASI="${DURASI#*\(}";
echo $DURASI
DURASI="${DURASI%% *}"
echo $DURASI
SISA="${DURASI##*5}"
echo $SISA
SISA="${SISA#*\)}"
echo $SISA
DURASI="${DURASI%\)*}"
echo $DURASI
# 60s setara dengan 1m
DURASI="$(echo "$DURASI * 60" | bc )"
echo $DURASI
echo $SISA
TIDUR=$(echo "$DURASI" + "$SISA" | bc )
echo $TIDUR
}

FILE="$1"
EXT="$(echo "${FILE}" |awk -F. '{print (NF>1?$NF:"no extension")}' )"

VAR=""
if [ "$EXT" == "mp3" ]; then
 VAR="audio/${EXT}";
elif [ "$EXT" == "mp4" ]; then
VAR="video/${EXT}";
else
   echo "No file given or Unsupport format!"
    exit 1
fi


TMPFILE="/sdcard/download/$1.tmp" 

cp -f "$FILE" "$TMPFILE"

cd /sdcard/download/

  am start -a android.intent.action.VIEW -d file://"$TMPFILE" -t "$VAR" > /dev/null 2>&1 

echo "Sedang memutar : $(basename "${TMPFILE%%.*}")"
sleep $DURASIFIX &
process_id=$!
wait -f $process_id
echo -e "Format berkas : $EXT "
echo -e "Waktu dihabiskan : Sekitar `convertime $DURASIFIX`";

rm -f "$TMPFILE"
echo "Track dibersihkan..."
cd - >/dev/null 2>&1;
rm -f nohup.out


