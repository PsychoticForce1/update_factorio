#!/bin/bash

#This is a simple script that would download and install the most recent 
#and stable release of Factorio for your headless Linux server.
#The script makes a backup of your save before it makes any changes and
#it can be found at /path/to/your/directory/backups/

#Please make your own backups before running this script, I do not want to
#be responsible if your save gets messed up.

#EDIT SCRIPT AS YOU DESIRE
#MADE BY PSYCHOTIC_FORCE

#Path to directory you want your Factorio server hosted (include the last "/")
ROOT_FOLDER="/path/to/where/you/want/factorio/to/run/"

#Timer (in seconds) to wait so the world can be saved; 
#default 10 seconds. If you have a larger save file, consider a longer timer.
TIMER=10

#Name of save file (no spaces in file name)
SAVE_FILE="YourSaveFile.zip"

##############################################################################
#DO NOT EDIT ANYTHING BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING
##############################################################################

#Create subfolders
mkdir -p $ROOT_FOLDER"downloads/"
mkdir -p $ROOT_FOLDER"saves/"
mkdir -p $ROOT_FOLDER"backups/"
mkdir -p $ROOT_FOLDER"temp/"
mkdir -p $ROOT_FOLDER"server/"

DOWNLOADS_FOLDER=$ROOT_FOLDER"downloads/"
SAVE_FOLDER=$ROOT_FOLDER"saves/"
BACKUPS_FOLDER=$ROOT_FOLDER"backups/"
TEMP_FOLDER=$ROOT_FOLDER"temp/"
SERVER_FOLDER=$ROOT_FOLDER"server/"

#Check if python3 is installed
if [[ "$(python3 -V)" =~ "Python 3" ]]; then
    echo "Python is installed"
else
    echo "Python3 is not installed, please install Python3 (sudo apt-get install python3 should work)"
    exit 1
fi
#Get Latest Stable Version
VERSION=`export PYTHONIOENCODING=utf8
curl -s 'https://factorio.com/api/latest-releases' | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['stable']['headless'])"`
if [ ! -f $DOWNLOADS_FOLDER"factorio-headless_linux_$VERSION.tar.xz" ]; then
    echo "Downloading version $VERSION."
    curl https://www.factorio.com/get-download/$VERSION/headless/linux64 -L --output $DOWNLOADS_FOLDER"factorio-headless_linux_"$VERSION".tar.xz"
    echo "Downloaded factorio-headless_linux_$VERSION.tar.xz"
else
    echo "The latest version v$VERSION is already downloaded."
    read -p 'Do you want to cancel the script? (Y/N): ' cancel
    if [[ $cancel == "Y" || $cancel == "y" ]]; then
    echo Script cancelled.
        exit 1
    else
        echo "Continuing with script."
    fi
fi
#Check if screen is running
if screen -list | grep -q "factorio"; then
    #Stop running server, wait to save files then terminate screen session.
    echo "Stopping running Factorio server."
    screen -S factorio -X stuff $'\003'
    echo "Waiting for $TIMER seconds to save files"
    sleep $TIMER && screen -S factorio -X quit
    #Make backup of world file
    echo "Making backups."
    time_now=`date "+%Y-%m-%d@%H_%M_%S"`
    mkdir -p $BACKUPS_FOLDER"backup_before_updating_to_v$VERSION on $time_now"
    cp $SAVE_FOLDER$SAVE_FILE $BACKUPS_FOLDER"backup_before_updating_to_v$VERSION on $time_now"
    sleep $TIMER && echo Backup saved at "$BACKUPS_FOLDER"backup_before_updating_to_v$VERSION on $time_now"/$SAVE_FILE".
    #Copy achievements.dat and mod-list.json to temp folder
    if [ "$(ls -A "$TEMP_FOLDER")" ]; then
    rm -r "$TEMP_FOLDER"*
    echo "Files removed from $TEMP_FOLDER"
    else
    echo "$TEMP_FOLDER is empty"
    fi
    cp $SERVER_FOLDER"factorio/mods/mod-list.json" $TEMP_FOLDER
    cp $SERVER_FOLDER"factorio/achievements.dat" $TEMP_FOLDER
else
    #Running Server not found.
    #Check if achievements.dat file exists
    if [ -f $SERVER_FOLDER"factorio/achievements.dat" ]; then
        echo "Found achievements file."
        #Copy achievements.dat and mod-list.json to temp folder
        if [ -f $TEMP_FOLDER"achievements.dat" ]; then
            rm -r $TEMP_FOLDER"achievements.dat"
        fi
        cp $SERVER_FOLDER"factorio/achievements.dat" $TEMP_FOLDER
    fi
    #Check if mod-list.json exists
    if [ -f $SERVER_FOLDER"factorio/mods/mod-list.json" ]; then
        echo "Found mod-list.json."
        #Copy mod-list.json to temp folder
        if [ -f $TEMP_FOLDER"mod-list.json" ]; then
            rm -r $TEMP_FOLDER"mod-list.json"
        fi
        cp $SERVER_FOLDER"factorio/mods/mod-list.json" $TEMP_FOLDER
    fi
fi
#Clear server folder
if [ "$(ls -A "$SERVER_FOLDER")" ]; then
    rm -r "$SERVER_FOLDER"*
    #echo "Files removed from $SERVER_FOLDER"
else
    echo "$SERVER_FOLDER is empty"
fi
if [ ! -f $DOWNLOADS_FOLDER"factorio-headless_linux_"$VERSION".tar.xz" ]; then
    echo "Error: File $FILE does not exist."
    exit 1
fi
#Unzip the new server files
echo Decompressing factorio-headless_linux_"$VERSION".tar.xz
tar -xJf $DOWNLOADS_FOLDER"factorio-headless_linux_"$VERSION".tar.xz" -C "$SERVER_FOLDER"
#Check if Save file exists
if [ -f $SAVE_FOLDER$SAVE_FILE ]; then
    echo "Found a save file."
else
    echo "Save file not found. Please copy your save file to "$SAVE_FOLDER
    exit 1
fi

#Start screen session and start server
echo "Start cycling the server"
screen -dmS factorio bash -c ""$SERVER_FOLDER"factorio/bin/x64/factorio --start-server "$SAVE_FOLDER$SAVE_FILE"; exec bash"
sleep $TIMER
screen -S factorio -X stuff $'\003'
echo "Waiting for $TIMER seconds to save files"
sleep $TIMER && screen -S factorio -X quit

#Check for achievements file
if [ -f $TEMP_FOLDER"achievements.dat" ]; then
    cp $TEMP_FOLDER"achievements.dat" $SERVER_FOLDER
else
    echo "achievements.dat not found."
    read -p 'Do you want to stop the script and add an achievements.dat now? (Y/N): ' continue
    if [[ $continue == "Y" || $continue == "y" ]]; then
        echo "Add achievements file at $SERVER_FOLDER"factorio/""
        rm "$SERVER_FOLDER"factorio/achievements.dat
        rm "$SERVER_FOLDER"factorio/mods/mod-list.json
        exit 1
    else
        echo "Resetting achievements."
    fi
fi
#Check for modlist file
if [ -f $TEMP_FOLDER"mod-list.json" ]; then
    cp $TEMP_FOLDER"mod-list.json" $SERVER_FOLDER"factorio/mods/"
else
    echo "mod-list.json not found."
    read -p 'Do you want to stop the script and edit mod-list.json now? (Y/N): ' continue
    if [[ $continue == "Y" || $continue == "y" ]]; then
        echo "Edit the modlist at $SERVER_FOLDER"factorio/mods/mod-list.json""
        exit 1
    else
        echo "Using default mod configs."
    fi
fi

#Start screen session and start server
screen -dmS factorio bash -c "script -f /tmp/factorio_server.log"; exec bash 
screen -S factorio bash -c "$SERVER_FOLDER"factorio/bin/x64/factorio --start-server "$SAVE_FOLDER$SAVE_FILE"; exec bash
echo "Server started!"
