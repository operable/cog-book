FROM alpine:3.4

RUN apk --no-cache -U add asciidoc asciidoc-doc mdocml-apropos \
          man-pages build-base ca-certificates bash util-linux

RUN adduser -s /bin/bash -D asciidoc
USER asciidoc
WORKDIR /home/asciidoc

# Need this so 'man foo' works
RUN echo "export PAGER=less" >> /home/asciidoc/.bashrc
