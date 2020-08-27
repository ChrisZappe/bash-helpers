#!/bin/bash

# This script was created to automate the task of clearing a user's
# corrupt keychain files quickly and efficiently.
# Scripted by Chris Zappe, with his newfound bash powers.
# January 2018

##### Variables

HOMEDIR_PATH=/Volumes/DataHD/homedirs_
ADMIN=serveradmin
uName=0
uGroup=0

##### Functions

getUserName() 
{
    # asks for a username to begin working on
    echo "" #Line Break
    echo "You will be deleting keychain records for a user on this system."
    
    # while loop takes care of retrieving username and handling mistypes.
    while true; do
        echo "Please specify the *short* username whose keychain you would like to clear."
        echo -n "> "
        read uName
        echo "Thank you. This script will remove the keychain for '$uName'"
        read -p "Is '$uName' correct? (y/n) > " yn
        case $yn in
            [Yy]* ) break;;
            * ) echo "Okay, let's try that again"; echo "";;
        esac
   done
   
   # define user type (faculty or staff)
   while true; do
        echo "Specify the user type (1) faculty or (2) staff"
        echo -n "> "
        read facStaff
        case $facStaff in
            [1]* ) uGroup="faculty"; echo "User type: $uGroup"; break;;
            [2]* ) uGroup="staff"; echo "User type: $uGroup"; break;;
            * ) echo "Please enter a 1 or a 2"; echo "";;
        esac
    done

   echo "Great! This script requires root access. Please enter root password"
   echo "if prompted. Press Enter to continue..."
   read
}   # end getUserName

permissionsSet()
{
# grant script a permissions trail to access user's Keychains directory
cd $HOMEDIR_PATH$uGroup
printf "The directory path is $HOMEDIR_PATH$uGroup/\n"
printf "Setting permissions for $ADMIN...\n\n"
sudo chown -v $ADMIN $uName/Library/Keychains/ $uName/Library/ $uName/
}

clearKeychains()
{
# good ol' rm command to wipe out the contents of the Keychains directory 
printf "\nRemoving Keychains...\n\n"
sudo rm -fvr $uName/Library/Keychains/*
printf "\nKeychains removed\n"
}

permissionsRestore()
{
# restore user ownership to their home directory folders
printf "\nRestoring file path permissions to $uName...\n\n"
sudo chown -v $uName $uName/Library/Keychains/ $uName/Library/ $uName/
printf "\n[ Process Complete ]\n\n"
}

##### Script Main
getUserName
permissionsSet
clearKeychains
permissionsRestore

##### Diagnostics   --------------------------------------------------

#echo "User name: $uName"
#echo "User type: $uGroup"
#echo "Home directory path: $HOMEDIR_PATH$uGroup/$uName"
