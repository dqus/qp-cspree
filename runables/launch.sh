#!/bin/sh

SCRIPT="$0"
DIR=`dirname "${SCRIPT}"`
CWD=`readlink -f "${DIR}"`
if [ -z $GAMEDIR ]; then
	GAMEDIR="${CWD}/.."
fi

FTEBIN=`readlink -f "$GAMEDIR/ftesv"`
BASEDIR=`readlink -f "$GAMEDIR/.."`
MODDIR=`readlink -f "$GAMEDIR"`

if [ -f $FTEBIN ]; then
	for PORT_CFG in $MODDIR/cfgs/ports/port*.cfg; do
		if [ -f $PORT_CFG ]; then # a file
			PORT_FILE=`basename ${PORT_CFG}`
			PORT=`echo $PORT_FILE | sed 's/[^0-9]*//g'`
			printf "* Starting ftesv (port %s)..." $PORT
			PROCESS=`pgrep -f "${FTEBIN} -game cspree -port ${PORT}"`
			if [ -z "$PROCESS" ]; then
				nohup sh $MODDIR/runables/run-one-port.sh $FTEBIN $PORT $BASEDIR > /dev/null 2>&1 &
				wait $!
				if [ $? -eq 0 ]; then
					echo "[OK]"
				else
					echo "[ERROR]"
				fi
			else
				echo "[ALREADY RUNNING]"
			fi
		else
			printf "Port %s seems to be missing a config.\n" $PORT
		fi
	done
else
	echo "Server binary not found."
	exit 1
fi
