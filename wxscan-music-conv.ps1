###
# Convert music to work on weatherscan
# Requires ffmpeg and ffprobe in your path
###

if ($args.Count -eq 0) {
    Write-Warning "Usage: wxscan-music-conv.ps1 [input_file.mp3]"
    exit
}
$InputFile = $args[0]

# Find the song length in seconds
$SongLength = (ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$InputFile")

# Multiply song length by the target sample rate (48k) to get TSIZ
$TSIZ = ([float]$SongLength) * 48000
$TSIZ = [Math]::Ceiling($TSIZ)

# Build output file name
$OutputFile = (Get-Item $InputFile ).Basename + "_output.mp3"

# Convert file
ffmpeg -hide_banner -i "$InputFile" -map 0:a -c:a libmp3lame -b:a 128k -ac 2 -ar 48000 -map_metadata -1 -metadata TSIZ="$TSIZ" -id3v2_version 3 "$OutputFile"