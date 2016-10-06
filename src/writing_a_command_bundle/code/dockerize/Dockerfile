FROM alpine:3.4

RUN apk --no-cache add bash build-base ca-certificates \
                       ruby ruby-dev ruby-bundler ruby-io-console

RUN adduser -D bundle
USER bundle
WORKDIR /home/bundle
COPY . /home/bundle

RUN bundle install --path .bundle
