#!/bin/sh

SCRIPT="$0"
DIR=`dirname "${SCRIPT}"`
PARENT=`readlink -f ${DIR}`

URL=http://triptohell.info

LINUX32_DIR=moodles/linux_x86
LINUX32_QCC=fteqcc32
LINUX32_FTE=fteqw-sv32

LINUX64_DIR=moodles/linux_amd64
LINUX64_QCC=fteqcc64
LINUX64_FTE=fteqw-sv64

PAK_DIR=cspree
PAK_BIN=cspree.pk3

QCC=$PARENT/fteqcc
FTE=$PARENT/../fteqw.sv

download() {
	printf "Downloading $1..."

	# To compare the current version with the new
	if [ -f $3 ]; then
		MD5="$(md5sum $3 | awk '{print $1}')"
	fi

	if wget --output-file wgetlog --continue --tries=3 --timeout=10 --server-response --timestamping ${URL}/$2/$3; then
		printf " Done."
		if [ "$MD5" = "$(md5sum $3 | awk '{print $1}')" ]; then
			printf " File is already the latest version.\n"
			DOWNLOAD_OK=0
		else
			printf "\n"
			DOWNLOAD_OK=1
		fi
	else
		printf " Failed! From wgetlog:\n"
		cat wgetlog
		DOWNLOAD_OK=0
	fi
}

permissions() {
	printf "Setting executable permissions for $1.\n"
	chmod +x $2
	if [ $? -eq 0 ]; then
		PERMISSIONS_OK=1
	else
		PERMISSIONS_OK=0
	fi
}

symlink() {
	if [ -f $2 ]; then
		readlink $2
		if [ $? -ne 0 ]; then
			printf "$2 is a regular file, answer yes to change it to a symlink.\n"
			ln --interactive -s ${PWD}/$3 $2
		fi
	else
		printf "Creating symlink for $1.\n"
		ln -s ${PWD}/$3 $2
	fi
}

runonce() {
	download $1 $2 $3
	if [ $DOWNLOAD_OK -ne 0 ]; then
		permissions $1 $3
		if [ $PERMISSIONS_OK -ne 0 ]; then
			symlink $1 $4 $3
		fi
	fi
}

if [ `getconf LONG_BIT` = "64" ]; then
	runonce QCC ${LINUX64_DIR} ${LINUX64_QCC} ${QCC}
	runonce FTE ${LINUX64_DIR} ${LINUX64_FTE} ${FTE}
else
	runonce QCC ${LINUX32_DIR} ${LINUX32_QCC} ${QCC}
	runonce FTE ${LINUX32_DIR} ${LINUX32_FTE} ${FTE}
fi

download PK3 ${PAK_DIR} ${PAK_BIN}
