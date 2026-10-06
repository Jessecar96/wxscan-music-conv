#!/usr/bin/env bash
###
# Convert music to work on weatherscan
# Requires ffmpeg and ffprobe in your path
###

if [ $# -eq 0 ]; then
    echo "Usage: wxscan-music-conv.sh [input_file.mp3]" >&2
    exit 1
fi
InputFile="$1"

# Find the song length in seconds
SongLength=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$InputFile")

# Multiply song length by the target sample rate (48k) to get TSIZ
# bash has no float math so use awk, and awk has no ceiling function, wtf
TSIZ=$(awk -v len="$SongLength" 'BEGIN { float = len * 48000; out = int(float); if (out < float) out++; print out }')

# Build output file name (strip directory and last extension)
BaseName=$(basename -- "$InputFile")
OutputFile="${BaseName%.*}_output.mp3"

# Convert file
ffmpeg -hide_banner -i "$InputFile" -map 0:a -c:a libmp3lame -b:a 128k -ac 2 -ar 48000 -map_metadata -1 -metadata TSIZ="$TSIZ" -id3v2_version 3 "$OutputFile"