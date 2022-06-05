SHELL:=/bin/bash

QCC:=./fteqcc

SSFILES = \
	version.qc \
	common/defs.qc \
	progs.src \
	client.qc \
	gmapn_aliasstuffer.qc \
	gmapn_countdown.qc \
	gmapn_csqc.qc \
	gmapn_disconnected.qc \
	gmapn_game.qc \
	gmapn_help.qc \
	gmapn_hazards.qc \
	gmapn_http.qc \
	gmapn_init.qc \
	gmapn_keys.qc \
	gmapn_latency.qc \
	gmapn_lightstyle.qc \
	gmapn_mapvote.qc \
	gmapn_menu.qc \
	gmapn_misc.qc \
	gmapn_powerups.qc \
	gmapn_qsg.qc \
	gmapn_reset.qc \
	gmapn_rpickup.qc \
	gmapn_rules.qc \
	gmapn_usercmd.qc \
	gmapn_sql.qc \
	gmapn_stats.qc \
	gmapn_subs.qc \
	gmapn_vote.qc \
	gmapn_votefuncs.qc \
	spectate.qc \
	world.qc \
	defs/builtins.qc \
	defs/constants.qc \
	defs/fields.qc \
	defs/fteextensions.qc \
	defs/functions.qc \
	defs/globals.qc \
	entities/ammo.qc \
	entities/armor.qc \
	entities/buttons.qc \
	entities/doors.qc \
	entities/health.qc \
	entities/init.qc \
	entities/items.qc \
	entities/keys.qc \
	entities/monsters.qc \
	entities/plats.qc \
	entities/powerups.qc \
	entities/teleports.qc \
	entities/trains.qc \
	entities/triggers.qc \
	entities/weapons.qc \
	frikbot/bot.qc \
	frikbot/bot_ai.qc \
	frikbot/bot_ed.qc \
	frikbot/bot_fight.qc \
	frikbot/bot_misc.qc \
	frikbot/bot_move.qc \
	frikbot/bot_phys.qc \
	frikbot/bot_way.qc \
	models/player.qc \
	monsters/ai.qc \
	monsters/boss.qc \
	monsters/demon.qc \
	monsters/dog.qc \
	monsters/enforcer.qc \
	monsters/fight.qc \
	monsters/fish.qc \
	monsters/hknight.qc \
	monsters/knight.qc \
	monsters/monsters.qc \
	monsters/ogre.qc \
	monsters/oldone.qc \
	monsters/shalrath.qc \
	monsters/shambler.qc \
	monsters/soldier.qc \
	monsters/tarbaby.qc \
	monsters/wizard.qc \
	monsters/zombie.qc

CSFILES = \
	version.qc \
	common/defs.qc \
	csqc/progs.src \
	csqc/constants.qc \
	csqc/csqcsysdefs.qc \
	csqc/entrypoints.qc \
	csqc/defs/fields.qc \
	csqc/defs/functions.qc \
	csqc/defs/globals.qc \
	csqc/gmapn_prediction.qc

.PHONY: all package release source clean

default: all

../code/fteqcc:
	$(MAKE) -C "../repositories/fteqw-code/engine" qcc-rel
	cp "../repositories/fteqw-code/engine/release/fteqcc" ../code/$(QCC)

../ftesv:
	$(MAKE) -C "../repositories/fteqw-code/engine" sv-rel
	cp "../repositories/fteqw-code/engine/release/fteqw-sv" ../ftesv

../csprogs.dat: ../code/fteqcc version.qc $(CSFILES)
	cd csqc && ../../code/$(QCC)

../qwprogs.dat: ../code/fteqcc version.qc $(SSFILES)
	../code/$(QCC)

NAME:="chillingspree"

VERSION:=$(shell git describe --tags --abbrev=0)

formatdate = $(shell LC_ALL=C date -d "$1" "+%a %d %b %Y %H:%M")
DATE:=$(if $(call isgittree),$(call formatdate,$(wordlist 1,2,$(shell git log --pretty=format:'%ai' -1))),$(call formatdate,$(wordlist 1,2,$(shell find . -type f -printf '%TY-%Tm-%Td %TH:%TM %P\n' | sort -n | tail -1))))

TYPE:=$(shell git rev-parse --git-dir > /dev/null 2>&1 && echo "git" || echo "release")
isgittree = $(filter "${TYPE}","git")
TYPE:=$(if $(call isgittree),$(shell git diff-index --quiet HEAD -- && echo "${TYPE}" || echo "${TYPE}+dev"),"${TYPE}")

version.qc:
	echo "#define NAME \"$(NAME)\"" > version.qc
	echo "#define VERSION \"$(VERSION)-$(TYPE)\"" >> version.qc
	echo "#define DATE \"$(DATE)\"" >> version.qc

PAK_SRC = \
	../locs \
	../maps \
	../particles \
	../progs \
	../sound

../qp.pk3: $(PAK_SRC)
	cd .. && rm -f qp.pk3 && zip -r qp.pk3 $(patsubst ../%,%,$(PAK_SRC))

clean:
	rm -f ../qwprogs.dat ../qwprogs.lno ../csprogs.dat ../csprogs.lno ../code/fteqcc ../ftesv version.qc
	$(MAKE) -C "../repositories/fteqw-code/engine" clean

all: ../qwprogs.dat ../csprogs.dat ../ftesv

DESTDIR=~/quake
install: all
	mkdir -p $(DESTDIR)/cspree
	cp ../qwprogs.dat $(DESTDIR)/cspree
	cp ../csprogs.dat $(DESTDIR)/cspree
	cp ../ftesv $(DESTDIR)

release:
	tar Cczvf .. chillingspree-server.tar.gz cspree/qwprogs.dat cspree/maps/ cspree/run/launch.sh cspree/run/terminate.sh cspree/updatebinaries.sh cspree/run/crashcatcher.sh cspree/run/run-one-port.sh cspree/setup.sh cspree/winquicker.bat cspree/LICENSE cspree/README cspree/INSTALL cspree/run/crash.txt cspree/run/signature.txt cspree/locs/

source:
	tar Cczvf .. chillingspree-source.tar.gz cspree/version.qc cspree/ss/ cspree/cs/ cspree/INSTALL cspree/LICENSE cspree/README cspree/progs.src cspree/setup.sh cspree/run/launch.sh cspree/run/terminate.sh cspree/run/crash.txt cspree/run/signature.txt cspree/winquicker.bat cspree/run/crashcatcher.sh cspree/run/run-one-port.sh cspree/maps/ cspree/locs/
