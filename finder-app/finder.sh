#!/bin/sh
# Assignment 1 : finder.sh
# Author: Sushant Potdar

#first argument is file directory
filesdir=$1
#second argument is text string to search within the files present 
searchstr=$2
error_message="The total number of arguments ahould be 2 \nThe order of the arguments should be: \n1) Files Directory Path \n2) String to be searched in the specified directory path"

#if number of arguments passed less than 2 
if [ $# -lt 2 ]
then 
#nested if to identify which parameter is not provided
	if [ -z $1 ] #-z checks if string length is zero
	then
	echo "File directory Path not provided"
	echo "${error_message}"
	exit 1
	elif [ -z $2 ]
	then
	echo "String to be searched is not provided"
	echo "${error_message}"
	exit 1
	fi

#nested if end ; now look for the directory
else  
	if [ -d "${filesdir}" ]
	then 
	#echo "Directory '${filesdir}' exists"
	cd ${filesdir}
	x=$(ls | wc -l)  
	y=$(grep -r ${searchstr} * | wc -l)
	echo "The number of files are ${x} and the number of matching lines are ${y}"
	else
	echo "Directory '${filesdir}' does not exists"
	exit 1
	fi
fi




