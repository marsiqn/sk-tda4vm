#!/bin/bash
#Device infos
RPS_PORT=$1
TIMEOUT=2

#USAGE
HELP="rps.sh <rps port> <cont port> <0-off/1-on/2-toggle> <toggle timeout>"

#Set port serial comm parameters to 9600 8N1
#echo "stty -F $RPS_PORT 9600 cread clocal"
stty -F $RPS_PORT 9600 cread clocal

if [ $# -lt 3 ]
then
	echo $LINENO $HELP
	exit
fi

if [[ $2 -lt 1 || $2 -gt 4 ]]
then
	echo $LINENO $HELP
	exit
fi

if [ $# -eq 4 ]
then
	TIMEOUT=$4
fi

case $3 in
	0 )
		echo $2.0 > $RPS_PORT
	;;
	1 )
		echo $2.1 > $RPS_PORT
	;;
	2 )
		echo $2.0 > $RPS_PORT
		sleep $TIMEOUT
		echo $2.1 > $RPS_PORT
	;;
	* )
	echo $LINENO $HELP
	;;
esac
