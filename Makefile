IMAGE_NAME=operable/cog-book-toolchain
MOUNT=/home/asciidoc
ROOT_FILE=cog_book.adoc

build = docker run -it -v $(shell pwd):$(MOUNT) --rm $(IMAGE_NAME):666 asciidoctor --require asciidoctor-pdf --backend=$1 --doctype=book $(MOUNT)/$(ROOT_FILE)

image: Dockerfile
	docker build -t $(IMAGE_NAME) .

html5: $(ROOT_FILE)
	$(call build,$@)

pdf: $(ROOT_FILE)
	$(call build,$@)

all: html5 pdf

clean:
	rm -f *.css
	rm -f *.html
	rm -f *.pdf
