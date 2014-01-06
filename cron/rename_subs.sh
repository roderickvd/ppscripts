#!/bin/sh

# rename_subs.sh - Rename .en.srt and .nl.srt to .srt files
# Tested on Synology DSM 4.3-3810 Update 3 (BusyBox v1.16.1)

# INSTALLATION INSTRUCTIONS:
#
#  1. Place script somewhere, e.g. /usr/local/scripts/rename_subs.sh
#  2. Configure DIRECTORY and PERMS variables below
#  3. Make script executable: chmod a+x /usr/local/scripts/rename_subs.sh
#  4. Optionally: schedule script to run using Task Scheduler or cron

# Directory to scan for SRT files (will follow symbolic links)
DIRECTORY=/volume1/video

# Permissions to set SRT files to
PERMS=666

# Step 1: Remove English subtitles if they have a Dutch counterpart,
# otherwise rename them into place and fix permissions
find "$DIRECTORY" -follow -iname \*.en.srt | while read EN_SUB
do
    NL_SUB=`echo "$EN_SUB" | sed 's/\.en\.srt$/\.nl\.srt/I'`  
    STRIPPED_SUB=`echo "$EN_SUB" | sed 's/\.en\.srt$/\.srt/I'`  
    if [ -e "$NL_SUB" -o -e "$STRIPPED_SUB" ]; then
        rm "$EN_SUB"
    else
        mv "$EN_SUB" "$STRIPPED_SUB"
    fi
done

# Step 2: Rename Dutch subtitles into place
find "$DIRECTORY" -follow -iname \*.nl.srt | while read NL_SUB
do
    STRIPPED_SUB=`echo "$NL_SUB" | sed 's/\.nl\.srt$/\.srt/I'` 
    mv "$NL_SUB" "$STRIPPED_SUB"
done

# Step 3: Fix permissions
find "$DIRECTORY" -follow -iname \*.srt -exec chmod $PERMS {} \;
