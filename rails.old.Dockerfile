
FROM ruby:2.5.3

# ENV LANG ja_JP.UTF-8
ENV LANG C.UTF-8
ENV RUBYOPT -EUTF-8
ENV APP_ROOT ~/app
ENV DEBIAN_FRONTEND noninteractive

WORKDIR $APP_ROOT

RUN apt-get update && \
    apt-get install -y nodejs \ 
                       mysql-client \
                       --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT

EXPOSE 3000

RUN \
  echo 'install: --no-document' >> ~/.gemrc && \
  echo 'update: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  bundle config --global build.nokogiri ---use-system-libralies && \
  bundle config --global jobs 4 && \
  bundle install && \
  rm -rf ~/.gem

COPY . $APP_ROOT

CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3000", "-e", "production", "-C", "config/puma.rb"]

# CMD ["rails","server","-b","0.0.0.0"]











