.PHONY: all
all:
	$(MAKE) -C src

PAK_SRC = \
	locs \
	maps \
	particles \
	progs \
	sound

qp.pk3: $(PAK_SRC)
	rm -f qp.pk3 && zip -r qp.pk3 $^
