#!/bin/bash

#===============================================================================
#
#          FILE:  myScheduler.sh
# 
#         USAGE:  ./myScheduler.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Cathy Hsu (), chsu5299@mpc.edu
#       COMPANY:  CSIS80-FA18
#       VERSION:  1.0
#       CREATED:  11/08/2018 06:30:45 PM PST
#      REVISION:  ---
#==============================================================================

#variables 
date="" 
msg=""
fileName="$1"

#store temporary shell scripts/text files
choice=""  
temporaryFile=""
reminder=""
tempFile="" 
delete=""

#Function to add a new note and write to $fileName 
addReminder() {
	
	# store the string entered into the inputbox into 
	# $reminder 
	echo -n $date "" >> $reminder
	dialog --title "New Reminder" \
	--inputbox "Enter a new reminder" 2>>"${reminder}" 8 50

	# create a (local) variable to store the contents of reminder 
	local temp="$reminder" 

	# append the contents of $temp into $fileName
	#  have each new reminder be placed directly under
	#  the previous one *  	
	cat $temp >> $fileName
	echo -n $'\n' >> $fileName
	
	
}

#Function to retrieve and display notes from $fileName 
getSchedule() 
{		
	#pipe what's inside of $fileName into grep.
        #  grep searches for the lines that contain the given date and
        #  pipes its contents into cut, which only extracts data from the 2nd field onwards
        #  and stores it in $tempFile  
        cat $fileName | grep $date | cut -d " " -f 2- >> $tempFile
        
        #creates the textbox that displays the messages                
        dialog --title $date --textbox $tempFile 20 40
             

}


#Function to delete a reminder. 
deleteReminder()
{
	#displays the reminders of that day along with line numbers 
	grep -n $date $fileName | cut -d " " -f 1,2- >> $tempFile 
	dialog --title $date --textbox $tempFile 20 40
	
	#Asks the user to enter the line number of the line they want to delete in the inputbox. 
	#  Write the choice made into another shell script		
	dialog --inputbox "What reminder do you want to delete? Type in the line number:" 2>>"${delete}" 20 40 
	
	#local variable $lineNum stores the number in $delete 
	local lineNum=$(<"${delete}")
	
	#delete the line corresponding with the line number 
	#sed -i "$lineNum"d $fileName

	sed -i 1d $fileName

	#sed -i "$lineNum"d $fileName		
 }


	 	

#Main menu of program that loops until user enters number zero **

# The output of the menu will be directed to standard error.
# In order to store the input as a variable, you must write the 
#   output to a file and then read it. *** 

input=1

#WHILE LOOP - repeats menu choices until you hit cancel** 
until [[ $input !=  "1" &&  $input != "2" &&  $input != "3" ]]; do
         
	choice=/tmp/menu.sh            #stores the menu choice selected by the user in a file in /tmp **** 
	temporaryFile=/cathy/temp.txt
	reminder=/tmp/reminder.sh
	tempFile=/tmp/temp.txt 
	delete=/tmp/delete.sh

	# The output of the menu will be directed to standard error.
	#   In order to store the input as a variable, you must write the 
	#   output to a file and then read it. *** 
	dialog --title "Menu" \
	--menu "Please choose an option:" 10 50 5 \
	1 "Enter new note" \
	2 "Delete a note " \
	3 "View old notes" 2>"${choice}"

	#write the choice you made into a temp file. 
	input=$(<"${choice}")
	
	# Echoing Values of $input and $? for testing
	# We should delete these before submission.
	#echo $input 
	#echo $?	
	
	# Check if $input has any value other than zero
	# if so get date input and go to function selected
        # by the user. Otherwise exit.	
	if [ $input ]
	then

		date=`dialog --stdout --title "My Calendar" --calendar "Select a date:" 0 0`


		case $input in 
			1) addReminder;;
			2) deleteReminder;; 
			3) getSchedule;;
	 	 	
		esac
	else

		exit 
	fi
	
	#force remove temporary file that stored strings entered into dialog boxes 
	rm -f $choice
	rm -f $reminder
	rm -f $tempFile
	rm -f $delete	

done

#Sources: 
# *     : https://stackoverflow.com/questions/12297820/how-to-append-strings-to-the-same-line-instead-of-creating-a-new-line
# **    : http://www.unixcl.com/2009/12/linux-dialog-utility-short-tutorial.html
# ***   : https://askubuntu.com/questions/491509/how-to-get-dialog-box-input-directed-to-a-variable
# ****  : https://bash.cyberciti.biz/guide/A_menu_box
