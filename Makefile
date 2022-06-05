.PHONY: all
all: build qp.pk3

.PHONY: build
build:
	$(MAKE) -C src

# Create package with all files required by mod.
qp.pk3: qp.pk3dir
	rm -f $@ && cd $^ && zip -1 -r ../$@ .
