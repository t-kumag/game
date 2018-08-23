FROM ruby:2.5.1

ENV RUBYOPT -EUTF-8
ENV APP_ROOT /usr/src/osdr

WORKDIR $APP_ROOT

RUN apt-get update && \
    apt-get install -y nodejs \ 
                       mysql-client \
                       postgresql-client \ 
                       sqlite3 \
                       --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT

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

EXPOSE 3000

CMD ["rails","server","-b","0.0.0.0"]




