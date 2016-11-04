FROM alpine:3.4

RUN apk --no-cache add ruby asciidoctor ruby-dev build-base python ca-certificates
RUN gem install asciidoctor --no-rdoc --no-ri && \
    gem install asciidoctor-pdf --pre --no-rdoc --no-ri && \
    gem install pygments.rb --no-rdoc --no-ri

RUN adduser -D asciidoc
USER asciidoc
WORKDIR /home/asciidoc
