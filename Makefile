IMAGE_NAME=operable/cog-book-toolchain:asciidoc
MOUNT=/home/asciidoc
ROOT_FILE=cog_book.adoc

ASCIIDOC_OPTS     := -r ./lib/google-analytics-postprocessor.rb --require asciidoctor-pdf --doctype=book --attribute stylesheet=stylesheets/cog.css
build = docker run -it -u $(shell id -u) -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) asciidoctor $(ASCIIDOC_OPTS) --backend=$1 $(MOUNT)/$(ROOT_FILE) | bin/fail_on_warnings.sh

image: Dockerfile
	docker build -t $(IMAGE_NAME) .

html5: $(ROOT_FILE)
	$(call build,$@)

pdf: $(ROOT_FILE)
	$(call build,$@)

shell:
	docker run -it -u root -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) sh

ad-shell:
	docker run -it -u asciidoc -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) /bin/bash

# release: html5 pdf
#	mkdir -p _release
#   cp -r images _release/.
#	cp -r stylesheets _release/.
#	cp -r sass _release/.
#	cp *.css _release/.
#	cp favicon.ico _release/.
#	cp $(basename $(ROOT_FILE)).pdf _release/.
#	cp $(basename $(ROOT_FILE)).html _release/.

# upload: release
#	aws s3 cp --recursive _release/ s3://cog-book-origin.operable.io/

all: html5 pdf

clean:
	rm -rf _release
	rm -f *.html
	rm -f *.pdf
