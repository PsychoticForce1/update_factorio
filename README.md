# update_factorio
A simple script that updates your Factorio server to the latest stable version. 
The script transfers your existing achievements.dat and mod-list.json. Please note the script does not support mods and only transfers the mod-list.json file to maintain if you have disabled SA and elevated rails. 
This script creates it's own folders in which the Factorio server would run. 

If this is the first time your are running this script, do the following:
1. Using the text editor of your choice, edit the ROOT_FOLDER variable in the script to reflect the path where your want the script to execute. Then edit the SAVE_FILE variable to the name of the save file you have, save the changes then run the script.
2. After running the script, in about 25 seconds you should see the message "Server started!". Now you can run the command "screen -r factorio" which would take you into the screen session where the Factorio server is running. press "Ctrl + c" to stop the server then "exit" to end the screen session.
3. Now you can copy your existing save file into the saves folder at "/path/to/where/you/want/factorio/to/run/saves/"
4. If you want to transfer your achievements too, you can copy your existing achievements.dat file into "/path/to/where/you/want/factorio/to/run/factorio/achievements.dat" . In both cases you would have to replace the file as the script would generate files with the names.
5. This script was made for the use without Space Age or mods, modify mod-list.json with the text editor of your choice at "/path/to/where/you/want/factorio/to/run/factorio/mods/mod-list.json" to disable Space Age and Elevated rails, save the changes and close the file.
6. Now run the script one last time and you should be able to join the server!

When a new update is released you would just have to run the script once and you'd be able to join the server.
A backup of your save file is taken before the script runs and can be found at `/path/to/where/you/want/factorio/to/run/backups/` but please make your own backup in case something goes wrong.

This is a very simple script and it's feature set is limited. I do not have any plans to add support for updating third-party mods but if someone wants to add that feature, you can reach me on Discord at "psychotic_force" or you can edit the script as you please.

I have a few QOL changes in mind that I'd like to implement but time is limited so I'd get to it when I can. There are two things I'd like to add: being able to update the server by typing a message in the game chat and streamlining the initial running of the script so you won't have to do the 6 steps mentioned above, or at least fewer steps than 6. 
