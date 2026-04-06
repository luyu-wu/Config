#!/bin/bash

## Get data
COVER="/tmp/music_cover.png"
MUSIC_DIR="$HOME/Music"

## Get status
get_status() {
	if [[ "$(playerctl status 2>/dev/null)" == "Playing" ]]; then
		echo " "
	else
		echo " "
	fi
}

## Get song
get_song() {
	song=$(playerctl metadata title 2>/dev/null)
	if [[ -z "$song" ]]; then
		echo "-"
	else
		echo "$song"
	fi
}

## Get artist
get_artist() {
	artist=$(playerctl metadata artist 2>/dev/null)
	if [[ -z "$artist" ]]; then
		echo "-"
	else
		echo "$artist"
	fi
}

## Get time
get_time() {
	position=$(playerctl position 2>/dev/null | awk '{print int($1/60) ":" int($1%60)}')
	duration=$(playerctl metadata mpris:length 2>/dev/null | awk '{print int($1/60000000) ":" int(($1/1000000)%60)}')
	if [[ -z "$position" || -z "$duration" ]]; then
		echo "0:00"
	else
		echo "$position/$duration"
	fi
}

get_ctime() {
	position=$(playerctl position 2>/dev/null)
	if [[ -z "$position" ]]; then
		echo "0:00"
	else
		echo "$(date -d@$position -u +%M:%S)"
	fi
}

get_ttime() {
	duration=$(playerctl metadata mpris:length 2>/dev/null)
	if [[ -z "$duration" ]]; then
		echo "0:00"
	else
		echo "$(date -d@$(($duration / 1000000)) -u +%M:%S)"
	fi
}

## Get cover
get_cover() {
	album_art=$(playerctl metadata mpris:artUrl 2>/dev/null | sed 's/^file:\/\///')
	if [[ -n "$album_art" && -f "$album_art" ]]; then
		magick "$album_art" -resize 120x120 "$COVER"
		echo "$COVER"
	else
		echo "images/music.png"
	fi
}

## Get progress
get_progress() {
	position=$(playerctl position 2>/dev/null)
	duration=$(playerctl metadata mpris:length 2>/dev/null)

	if [[ -z "$position" || -z "$duration" ]]; then
		echo "0"
		return
	fi

	position_int=$(printf "%.0f" "$position")
	duration_int=$(printf "%.0f" "$(echo "$duration / 1000000" | bc -l)")

	if [[ -z "$position_int" || -z "$duration_int" || "$duration_int" -eq 0 ]]; then
		echo "0"
	else
		progress=$((100 * position_int / duration_int))
		echo "$progress"
	fi
}

## Execute accordingly
if [[ "$1" == "--song" ]]; then
	get_song
elif [[ "$1" == "--artist" ]]; then
	get_artist
elif [[ "$1" == "--status" ]]; then
	get_status
elif [[ "$1" == "--time" ]]; then
	get_time
elif [[ "$1" == "--ctime" ]]; then
	get_ctime
elif [[ "$1" == "--ttime" ]]; then
	get_ttime
elif [[ "$1" == "--progress" ]]; then
  get_progress
elif [[ "$1" == "--cover" ]]; then
	get_cover
elif [[ "$1" == "--toggle" ]]; then
	playerctl play-pause
	get_cover
elif [[ "$1" == "--next" ]]; then
	playerctl next
	get_cover
elif [[ "$1" == "--prev" ]]; then
	playerctl previous
	get_cover
fi
