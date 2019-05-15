FROM ruby:2.5.1

ENV LANG ja_JP.UTF-8
ENV RUBYOPT -EUTF-8
ENV APP_ROOT /app

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


CMD ["bundle", "exec", "rails", "s", "puma", "-b", "0.0.0.0", "-p", "3000", "-e", "development"]

# CMD ["rails","server","-b","0.0.0.0"]











