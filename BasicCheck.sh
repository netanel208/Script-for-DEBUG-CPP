#!/bin/bash
folderName=$1
executable=$2
compilation="Fail"
memory_leaks="Fail"
thread_race="Fail"
exitValue=7

inputCount=$#
shift
shift
arguments=$@

print_outputAndExit(){
	echo "Compilation	Memory leaks	Thread race"
	echo "$1 		$2            $3"
	exit $4
}

if [ $inputCount -ge 2 ] 
then
	if [ -e $folderName ]
	then
		cd $folderName
		make
		if [ $? -gt 0 ] 
		then
			print_outputAndExit $compilation $memory_leaks $thread_race $exitValue
		else
			compilation="Pass"
		   	exitValue=$[ $exitValue-4 ]
			echo "valgrind:"
			valgrind --leak-check=full --error-exitcode=1 ./$executable $arguments 2>/dev/null
			if [ $? -eq 0 ] 
			then 
				memory_leaks="Pass"
				exitValue=$[ $exitValue-2 ]
			fi
			echo "helgrind:"
			valgrind --tool=helgrind --error-exitcode=1 ./$executable $arguments 2>/dev/null 
			if [ $? -eq 0 ] 
			then 
				thread_race="Pass"
				exitValue=$[ $exitValue-1 ]
			fi	
		fi
	else
		echo "Wrong directory path..."	
	fi
else
	echo "Input error..."
fi
print_outputAndExit $compilation $memory_leaks $thread_race $exitValue

