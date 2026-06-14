  #!/bin/bash

abort() {
echo " Ctrl+C caught   "
echo " Starting cleanup process  ... "
        if [ -d $cows ];then
        tar cf "${cows}_archive" "$cows"
        rm -rf "$cows"
        echo "Partial data saved and removed"
        fi
       
}
trap abort  SIGINT




echo "Starting deployment.."
echo "Verifying whether python3 exists on the system...."



if python3 --version;then
        echo "Great! Python3 is there, moving on"
else
        echo "Hmm, Python3 not found "
fi  
sleep 0.5

echo "Setting up your workspace now "
read -p "Give your folder a unique name: " folder  
cows="attendance_tracker_$folder"
if [ -d $cows ];then
        echo "That name is already taken"
else
        mkdir -p "$cows"
        mkdir "$cows/Helpers"
        mkdir "$cows/reports"
   
sleep 1

echo "Parent directory and files  are all set up"
        cp attendance_checker.py "$cows/"
        cp assets.csv             "$cows/Helpers/"
        cp config.json            "$cows/Helpers/"
        cp reports.log            "$cows/reports/"
fi

read -p "Do you want to update the attendance thresholds? (y/n): " choice
if [ "$choice" = "y" ]; then
        read -p "Enter Warning threshold in %:  " warning
        read -p "Enter Failure threshold %: " failure
        sed -i "s/75/$warning/" "$cows/Helpers/config.json"
        sed -i "s/50/$failure/" "$cows/Helpers/config.json"
        echo "Threshold modified"
fi

echo " delypoment  $cows  successfully "

