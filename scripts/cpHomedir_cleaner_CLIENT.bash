#!/bin/bash

# This script was created to automate the task of migrating a Mac user's
# home folder to a clean directory with the same short name.
# It is designed to run on a Mac client machine and to prompt for 
# common information that categorizes local user accounts.
# Scripted by Chris Zappe, with his newfound bash powers.
# Revised May 2019

#=== VARIABLES ===================================================

HOMEDIR_PATH=/Users/
ADMIN=0
uName=0
uGroup=0
uID=0

#==== FUNCTIONS ==================================================

getUserName() 
{
    # asks for a username to begin working on
    printf "\nYou will be transfering user data into a clean directory.\n"
    
    # while loop takes care of retrieving username and handling mistypes.
    while true; do
        printf "Please specify the *short* username you would like to move.\n> "
        read uName
        printf "Thank you. This script will create a clean homedir for '$uName'\n"
        read -p "Is '$uName' correct? (y/n) > " yn
        case $yn in
            [Yy]* ) break;;
            * ) echo "Okay, let's try that again"; echo "";;
        esac
   done

   # retrieve user ID
   uID=$(( $(id -u dummy) ))
   printf "Okay. This script will create a new user folder for '$uName' with the user ID '$uID'\n"

    # THIS while loop takes care of retrieving ADMIN name and handling mistypes.
    while true; do
        printf "Please specify an admin/root user that has permission to make \n"
	printf "the needed changes > "
        read ADMIN
        read -p "Is '$ADMIN' correct? (y/n) > " yn
        case $yn in
            [Yy]* ) break;;
            * ) echo "Okay, let's try that again"; echo "";;
        esac
   done
    printf "Great! This script requires root access. Please enter root password\n"
    printf "if prompted. Press Enter to continue...\n"
    read	# Accepts 'Enter' to continue script 

}   # end getUserName

newHomeFolder()
{
# switch directories to the root home folder directory
cd $HOMEDIR_PATH
printf "The directory path is $HOMEDIR_PATH\n"
printf "Creating new home folder for $uName...\n\n"
# rename old user directory and create new, blank on  in its place
sudo mv -v $uName $uName-old
sudo mkdir -v $uName
}

copyContents()
{
# clone old home directory contents, excluding Library, to new home directory 
printf "\n Cloning user files to new home directory...\n\n"
sudo chown $ADMIN $uName-old
cd $uName-old
sudo tar cvf mover.tar --exclude=Library *
sudo mv mover.tar ../$uName
cd ../$uName
sudo tar xvf mover.tar 
sudo rm mover.tar
}

fixFlagsPerms()
{
# fix hidden flags and POSIX permissions

printf "\nRestoring directory permissions and flags to $uName...\n\n"
cd ..
sudo chflags nohidden $uName/*
sudo chown -Rv $uName:$uID $uName
sudo chmod -Rv u+r+w+x,g-r-w-x,o-r-w-x $uName
printf "\n====== PROCESS COMPLETE ======\n\n"
}

# === SCRIPT MAIN ===================================================
getUserName
newHomeFolder
copyContents
fixFlagsPerms

##### Diagnostics   --------------------------------------------------

#echo "User name: $uName"
#echo "User type: $uGroup"
#echo "Home directory path: $HOMEDIR_PATH$uGroup/$uName"
