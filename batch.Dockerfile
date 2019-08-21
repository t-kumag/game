FROM ruby:2.5.1-alpine

ENV LANG C.UTF-8
ENV ROOT_PATH /app

RUN mkdir $ROOT_PATH
WORKDIR $ROOT_PATH
ADD Gemfile $ROOT_PATH/Gemfile
ADD Gemfile.lock $ROOT_PATH/Gemfile.lock

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache --virtual=.build-dependencies \
      build-base \
      curl-dev \
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      mysql-client \
      mysql-dev \
      mysql \
      ruby-dev \
      yaml-dev \
      zlib-dev && \
    apk add --update --no-cache \
      bash \
      git \
      openssh \
      mysql-client \
      mysql-dev \
      mysql \
      ruby-json \
      tzdata \
      curl \
      yaml && \
    apk add less && \
    bundle install -j4 && \
    apk del .build-dependencies

ADD . $ROOT_PATH

EXPOSE 3000

CMD ["rake", "accumulation:move_money"]