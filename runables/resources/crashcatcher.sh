#!/bin/sh

$*
wait $!
if [ $? -ne 0 ]; then
	cat crash.txt crash.log signature.txt | mail -s "Quake Server crash" $USER
	rm crash.log
fi
