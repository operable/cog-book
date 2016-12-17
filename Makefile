IMAGE_NAME = operable/cog-book-toolchain:latest
MOUNT = /home/asciidoc
ROOT_FILE = cog_book.adoc
STYLESHEET_PREFIX ?= ./stylesheets

ASCIIDOC_OPTS := -r ./lib/google-analytics-postprocessor.rb --require asciidoctor-pdf --doctype=book --attribute "stylesdir=${STYLESHEET_PREFIX}" --attribute stylesheet=cog.css
build = docker run -it -u $(shell id -u) -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) asciidoctor $(ASCIIDOC_OPTS) --backend=$1 $(MOUNT)/$(ROOT_FILE) | bin/fail_on_warnings.sh

image: Dockerfile
	docker build -t $(IMAGE_NAME) .

html5: $(ROOT_FILE)
	$(call build,$@)

pdf: $(ROOT_FILE)
	$(call build,$@)

shell:
	docker run -it -u root -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) sh

release: html5 pdf
	mkdir -p _release
	cp -r images _release/.
	cp -r stylesheets _release/.
	cp -r sass _release/.
	cp favicon.ico _release/.
	cp $(basename $(ROOT_FILE)).pdf _release/.
	cp $(basename $(ROOT_FILE)).html _release/.

upload: release
	aws s3 cp --recursive _release/ s3://cog-book-origin.operable.io/

all: html5 pdf

clean:
	rm -rf _release
	rm -f *.html
	rm -f *.pdf
