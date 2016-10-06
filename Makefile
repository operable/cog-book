IMAGE_NAME=operable/cog-book-toolchain
MOUNT=/home/asciidoc
ROOT_FILE=cog_book.adoc

build = docker run -it -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) asciidoctor --require asciidoctor-pdf --backend=$1 --doctype=book $(MOUNT)/$(ROOT_FILE) | bin/fail_on_warnings.sh

image: Dockerfile
	docker build -t $(IMAGE_NAME) .

html5: $(ROOT_FILE)
	$(call build,$@)

pdf: $(ROOT_FILE)
	$(call build,$@)

release: html5 pdf
	mkdir -p _release
	cp -r images _release/.
	cp $(basename $(ROOT_FILE)).pdf _release/.
	cp $(basename $(ROOT_FILE)).html _release/.

upload: release
	aws s3 cp --recursive _release/ s3://cog-book-origin.operable.io/

all: html5 pdf

clean:
	rm -rf _release
	rm -f *.html
	rm -f *.pdf
