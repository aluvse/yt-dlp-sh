#!/usr/bin/env bash

# ==========================================================
# YT-DLP Bash Downloader (Zero-Loop Architecture)
# compatible with bash, fish, zsh
# ==========================================================

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' 

# 1. SETUP YOUR PATH: 
YTDLP_PATH="$HOME/bins/ytdlp"
FFMPEG_BIN="$HOME/bins/ffmpeg/bin"
DENO_PATH="$HOME/.deno/bin/deno" 


SAVE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
YT_DLP_EXE="$BIN_PATH/yt-dlp"

# ==========================================================
# Environment Check
# ==========================================================

if [ ! -f "$YT_DLP_EXE" ]; then
    echo -e "${RED}ERROR: yt-dlp wasn't found in $YT_DLP_EXE${NC}"
    read -r -p "Press ENTER to exit..."
    exit 1
fi

# ==========================================================
# User Input & Quality Logic
# ==========================================================

echo -e "${CYAN}1. Paste link(s) and press ENTER${NC}"
printf "> "
read -r USER_INPUT

URLS=()
for word in $USER_INPUT; do
    if [[ $word =~ ^https?:// ]]; then
        URLS+=("$word")
    fi
done

if [ ${#URLS[@]} -eq 0 ]; then
    echo -e "${RED}No valid URLs detected.${NC}"
    read -r -p "Нажмите Enter для выхода..."
    exit 1
fi

echo -e "\n${CYAN}2. Select Quality:${NC}"
echo -e "${GREEN}[ENTER] -> 1080p (Default)${NC}"
echo -e "${YELLOW}[BS]    -> 720p${NC}"
echo -e "${MAGENTA}[0]      -> Audio Only (M4A/AAC)${NC}"
echo "--------------------------"
echo "[1] 1440p  [4] 480p"
echo "[2] 1080p  [5] 360p"
echo "[3] 720p   [6] 144p"


read -r -s -n 1 KEY

AUDIO_ONLY=false
RES=""
EXTRA_ARGS=()

if [[ -z "$KEY" ]]; then 
    KEY="ENTER"
elif [[ "$KEY" == $'\x7f' || "$KEY" == $'\b' ]]; then 
    KEY="BS"
fi

case "$KEY" in
    0) AUDIO_ONLY=true ;;
    1) RES=1440 ;;
    2|ENTER) RES=1080 ;;
    3|BS) RES=720 ;;
    4) RES=480 ;;
    5) RES=360 ;;
    6) RES=144 ;;
    *) RES=1080 ; echo "Defaulting to 1080p" ;;
esac

if [ "$AUDIO_ONLY" = true ]; then
    echo -e "\n${MAGENTA}Selected: Audio Only (MP3)${NC}"
    FORMAT_STR="ba/b"
    EXTRA_ARGS=(
        "--extract-audio" 
        "--audio-format" "mp3" 
        "--audio-quality" "0"
    )
else
    echo -e "\n${CYAN}Selected: ${RES}p (Max Bitrate Mode)${NC}"
    FORMAT_STR="bestvideo[height<=${RES}]+bestaudio/best"
    EXTRA_ARGS=(
        "--merge-output-format" "mkv" 
        "--external-downloader-args" "ffmpeg:-loglevel panic"
        "--format-sort" "res:${RES},quality"
    )
fi

# ==========================================================
# Download Process
# ==========================================================

for URL in "${URLS[@]}"; do
    echo -e "\n${YELLOW}[*] Processing: $URL${NC}"
    
    IS_COLLECTION=false
    if [[ "$URL" == *"list="* || "$URL" == *"/playlists"* || "$URL" == *"/@"* ]]; then
        IS_COLLECTION=true
    fi

    if [ "$IS_COLLECTION" = true ]; then
        OUT_TEMPLATE="./%(uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s [%(id)s].%(ext)s"
    else
        OUT_TEMPLATE="./%(title)s [%(id)s].%(ext)s"
    fi

    ALL_ARGS=(
        "-f" "$FORMAT_STR"
        "--continue"
        "--no-overwrites"              
        "--embed-chapters"
        "--embed-thumbnail"
        "--cookies" "$SAVE_PATH/cookies.txt"
        "--ffmpeg-location" "$FFMPEG_BIN"
        "--hls-prefer-ffmpeg"
        "--fixup" "detect_or_warn"
        "--abort-on-unavailable-fragment"
        "--socket-timeout" "30"
        "--js-runtimes" "deno:$DENO_PATH"
        "--fragment-retries" "10"
        "--yes-playlist"
        "--output-na-placeholder" ""
        "--restrict-filenames"        
        "-o" "$OUT_TEMPLATE"
        "--sleep-interval" "5"
        "--max-sleep-interval" "15"
        "--sleep-subtitles" "2"
    )

    if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
        ALL_ARGS+=("${EXTRA_ARGS[@]}")
    fi


    "$YT_DLP_EXE" "${ALL_ARGS[@]}" "$URL"
done

echo -e "\n${GREEN}[!] All tasks completed.${NC}"
read -r -p "Press ENTER to exit..."