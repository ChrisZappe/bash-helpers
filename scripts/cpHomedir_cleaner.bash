#!/bin/bash

# This script was created to automate the task of migrating a Mac user's
# home folder to a clean directory with the same short name.
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
    echo "You will be transfering user data into a clean directory."
    
    # while loop takes care of retrieving username and handling mistypes.
    while true; do
        echo "Please specify the *short* username you would like to move."
        echo -n "> "
        read uName
        echo "Thank you. This script will create a clean homedir for '$uName'"
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

newHomeFolder()
{
# switch directories to the root home folder directory
cd $HOMEDIR_PATH$uGroup
printf "The directory path is $HOMEDIR_PATH$uGroup/\n"
printf "Creating new home folder for $uName...\n\n"
# rename old user directory and create new, blank on  in its place
sudo mv -v $uName $uName-old
mkdir -v $uName
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
sudo chown -Rv $uName $uName
sudo chmod -Rv u+r+w+x,g-r-w-x,o-r-w-x $uName
printf "\n[ Process Complete ]\n\n"
}

##### Script Main
getUserName
newHomeFolder
copyContents
fixFlagsPerms

##### Diagnostics   --------------------------------------------------

#echo "User name: $uName"
#echo "User type: $uGroup"
#echo "Home directory path: $HOMEDIR_PATH$uGroup/$uName"
