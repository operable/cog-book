FROM ubuntu:16.04

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y \
    asciidoc \
    texlive
# TODO: filter out various tex doc packages... they're huge
# texlive-latex-base-doc
# texlive-latex-extra-doc
# texlive-latex-recommended-doc
# texlive-pictures-doc
# texlive-pstricks-doc

RUN adduser --disabled-login --gecos '' asciidoc
USER asciidoc
WORKDIR /home/asciidoc
