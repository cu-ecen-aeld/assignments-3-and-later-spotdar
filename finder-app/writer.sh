#!/bin/sh
# Assignment 1 : writer.sh
# Author: Sushant Potdar

#first argument is path to file including file name
writefile=$1
#second argument is text string to be written to file 
writestr=$2

#using dirname to extract path of directory from complete path+file name string
dir_path=$(dirname "${writefile}")

#if number of arguments passed less than 2 
if [ $# -lt 2 ]
then 
#nested if to identify which parameter is not provided
	if [ -z $1 ] #-z checks if string length is zero
	then
	echo "File directory Path not provided"
	exit 1
	elif [ -z $2 ]
	then
	echo "String to be written is not provided"
	exit 1
	fi

#nested if end ; check if file and folder exists 
else 


	if [ ! -d "${dir_path}" ] 	#check if folder exists
	then
		#echo "directory doesnt exists"
		#make the path
		mkdir -p $dir_path
	fi

	#check if file exists
	if [ -e ${writefile} ]
	then 
		# file exists
		#echo "file exists"
		echo "${writestr}">${writefile}
		exit 0
	else		
	
		#create the file
		touch ${writefile}
			if [ $? -eq 0 ]
			then
			#file created successfully ; write to file
			echo "${writestr}">${writefile}
			else
			echo " File could not be created"
			fi

	fi

	



fi




