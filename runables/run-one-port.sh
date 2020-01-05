#!/bin/sh

SCRIPT="$0"
DIR=`dirname "${SCRIPT}"`
CWD=`readlink -f "${DIR}"`
LOGDIR=$CWD/logs
SERVER_BINARY=$1
SERVER_PORT=$2
SERVER_DIR=$3

mkdir -p $LOGDIR

if [ -z $SERVER_BINARY ] || [ -z $SERVER_PORT ] || [ -z $SERVER_DIR ]; then
	printf "Usage: %s <engine binary> <server port> <basedir>\n" $0
	exit 1
fi

if [ -f $SERVER_BINARY ]; then
	PORT=`echo $SERVER_PORT | egrep '^[[:digit:]]+$'`
	if [ -z $PORT ]; then
		echo "Second argument must be a number."
		exit 1
	else
		if [ -d $SERVER_DIR ]; then
			if [ "`echo ${SERVER_BINARY} | egrep '/+'`" != "${SERVER_BINARY}" ]; then
				SERVER_BINARY=./$SERVER_BINARY
			fi
			CMDLINE="$SERVER_BINARY -game cspree -port $PORT -basedir $SERVER_DIR +set port $PORT"
			LOGFILE=$LOGDIR/cspree_${PORT}.log
			sh $CWD/resources/crashcatcher.sh $CMDLINE > $LOGFILE 2>&1 &
		fi
		exit 0
	fi
else
	echo "Server binary not found."
	exit 1
fi
