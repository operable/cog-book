FROM alpine:3.4

RUN apk --no-cache add ruby ruby-bundler ruby-io-console ruby-dev build-base bash ca-certificates

RUN adduser -h /home/bundle -D bundle && \
    mkdir -p /home/bundle && \
    chown -R bundle /home/bundle
WORKDIR /home/bundle
COPY . /home/bundle

RUN su bundle -c 'bundle install --path .bundle'

USER bundle
