# Spotify Migrate

## About
Spotify has a playlist API but unfortunately it's broken and doesn't
support pagination. This is a workaround for exporting all playlists.

## Usage
1. Create an empty RTF file in TextEdit.
2. Enter the name of each playlist on its own line.
3. Copy and paste the tracks for each playlist from the Spotify desktop app into the RTF file under the correct playlist title.
4. Make sure there is a blank line between each playlist.
5. Convert the RTF file to plain text.
6. Pipe that text file into standard in for this script `swift main.swift < playlists.txt > playlists.md`
7. Enjoy your MarkDown playlists and wait for Apple to add a search API to Apple Music.
