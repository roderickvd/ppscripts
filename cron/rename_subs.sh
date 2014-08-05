#!/bin/sh

# rename_subs.sh - Rename .en.srt and .nl.srt to .srt files
# Tested on Synology DSM 5.0 (BusyBox v1.16.1)

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

# Regular expressions are verbose on purpose so they work in BusyBox.

# Step 0: Remove all empty subtitles.
find "$DIRECTORY" -follow -iname \*.srt -size 0 -delete

# Step 1: Replace three-letter language codes with two-letter codes.
# Keep the main track only (i.e. without number suffix)
find "$DIRECTORY" -follow -regex ".*\.[eE][nN][gG]\.[sS][rR][tT]$" | while read ENG_SUB
do
    EN_SUB=`echo "$ENG_SUB" | sed 's/\.eng\.srt$/\.en\.srt/I'`
    mv "$ENG_SUB" "$EN_SUB"
done
find "$DIRECTORY" -follow -regex ".*\.[dD][uU][tT]\.[sS][rR][tT]$" | while read DUT_SUB
do
    NL_SUB=`echo "$DUT_SUB" | sed 's/\.dut\.srt$/\.nl\.srt/I'`
    mv "$DUT_SUB" "$NL_SUB"
done

# Step 1a: Remove all other subtitles with a three-letter language code.
find "$DIRECTORY" -follow -regex ".*\.[a-zA-Z][a-zA-Z][a-zA-Z][\.[0-9]*]*\.[sS][rR][tT]$" | while read REMOVE_SUB
do
    rm "$REMOVE_SUB"
done

# Step 2: Remove English subtitles if they have a Dutch counterpart,
# otherwise rename them into place and fix permissions
find "$DIRECTORY" -follow -regex ".*\.[eE][nN]\.[sS][rR][tT]$" | while read EN_SUB
do
    NL_SUB=`echo "$EN_SUB" | sed 's/\.en\.srt$/\.nl\.srt/I'`  
    STRIPPED_SUB=`echo "$EN_SUB" | sed 's/\.en\.srt$/\.srt/I'`  
    if [ -e "$NL_SUB" -o -e "$STRIPPED_SUB" ]; then
        rm "$EN_SUB"
    else
        mv "$EN_SUB" "$STRIPPED_SUB"
    fi
done

# Step 3: Rename Dutch subtitles into place unless the subtitle already exists.
# The latter may be the case if nzbToMedia extracted a single subtitle from the source.
find "$DIRECTORY" -follow -regex ".*\.[nN][lL]\.[sS][rR][tT]$" | while read NL_SUB
do
    STRIPPED_SUB=`echo "$NL_SUB" | sed 's/\.nl\.srt$/\.srt/I'` 
    if [ -e "$STRIPPED_SUB" ]; then
        rm "$NL_SUB"
    else
        mv "$NL_SUB" "$STRIPPED_SUB"
    fi
done

# Step 4: Fix permissions
find "$DIRECTORY" -follow -iname \*.srt -exec chmod $PERMS {} \;
