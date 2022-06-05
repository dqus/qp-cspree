QCC?=fteqcc

.PHONY: all
all: version.qc

NAME:="qp"
VERSION:=$(shell git describe --tags --abbrev=0)

formatdate = $(shell LC_ALL=C date -d "$1" "+%a %d %b %Y %H:%M")
DATE:=$(if $(call isgittree),$(call formatdate,$(wordlist 1,2,$(shell git log --pretty=format:'%ai' -1))),$(call formatdate,$(wordlist 1,2,$(shell find . -type f -printf '%TY-%Tm-%Td %TH:%TM %P\n' | sort -n | tail -1))))

TYPE:=$(shell git rev-parse --git-dir > /dev/null 2>&1 && echo "git" || echo "release")
isgittree = $(filter "${TYPE}","git")
TYPE:=$(if $(call isgittree),$(shell git diff-index --quiet HEAD -- && echo "${TYPE}" || echo "${TYPE}+dev"),"${TYPE}")

.PHONY: version.qc # Make it phony so it always executed.
version.qc:
	echo "#define NAME \"$(NAME)\"" > version.qc
	echo "#define VERSION \"$(VERSION)-$(TYPE)\"" >> version.qc
	echo "#define DATE \"$(DATE)\"" >> version.qc
