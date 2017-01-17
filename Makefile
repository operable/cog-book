MOUNT         = /home/cogdoc
IMAGE_NAME    = operable/cog-book-toolchain:sphinx
BUILD_CMD     = docker run -u $(shell id -u) -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME)

DOC           = cog-book

SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = $(DOC)
SOURCEDIR     = source
BUILDDIR      = $(CURDIR)/build/$(DOC)
BUILD_TOP     = $(shell dirname $(BUILDDIR))

# Put it first so that "make" without argument is like "make help".
help:
	@$(BUILD_CMD) $(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

cog-book: build-prep
	@$(BUILD_CMD) make build-docs DOC=$@

style-guide: build-prep
	@$(BUILD_CMD) make build-docs DOC=$@

all: cog-book style-guide

build-prep:
	@scripts/ensure_image.sh

build-docs:
	make html DOC=$(DOC)

image:
	docker build -t $(IMAGE_NAME) .

clean:
	rm -rf $(BUILD_TOP)

.PHONY: help cog-book style-guide all build-prep build-docs clean image Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@cd $(DOC) && $(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
