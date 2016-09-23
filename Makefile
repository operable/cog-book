IMAGE_NAME=operable/cog-book-toolchain
MOUNT=/home/asciidoc
ROOT_FILE=cog_book.adoc

image: Dockerfile
	docker build -t $(IMAGE_NAME) .

xhtml: $(ROOT_FILE)
	docker run -it -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) a2x -f $@ $(MOUNT)/$(ROOT_FILE) --verbose --doctype=book

pdf: $(ROOT_FILE)
	docker run -it -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME) a2x -f $@ $(MOUNT)/$(ROOT_FILE) --verbose --doctype=book

all: xhtml pdf

clean:
	rm -f *.css
	rm -f *.html
	rm -f *.pdf
