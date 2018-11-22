# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


## Getting Started

### Docker

1. `docker-compose build`
1. `docker-compose run bundle exec rake db:migrate`
1. `docker-compose up -d`
1. You can see the response on `http://0.0.0.0:3000`.

