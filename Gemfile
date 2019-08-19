source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'mysql2'
# gem 'mysql2', '~> 0.3.20'

# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'bullet'              # 「N+1 問題」を検出してくれる
  gem 'annotate'            # 現状のスキーマの注釈をコメントとしてファイルの上部や下部に追記してくれる。
  gem 'hirb'                # コンソールのModelの出力結果を表形式で分かりやすく表示する
  gem 'hirb-unicode'        # 日本語などマルチバイト文字の出力時の出力結果のずれに対応
  gem 'better_errors'       # エラー画面をデバッグしやすい形に整形してくれる
  gem 'binding_of_caller'   # better-errorsのエラー画面でirbができる
  gem 'letter_opener_web'   # 送信したメールを確認できる
  gem 'pry-rails'           # コンソールをirbからpryに置き換える。
  gem 'pry-byebug'          # ソースコードにブレークポイントを埋め込んで、所定のポイントでpryを起動
  gem 'rufo'
  # gem 'rubocop'
  gem 'rubocop', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# OAuth
gem "doorkeeper"

# http client
gem "faraday"

gem 'unicorn'
gem 'capistrano'

gem 'capistrano-bundler'
gem 'capistrano-rails'
gem 'capistrano-rbenv'
gem 'capistrano3-unicorn'
gem 'capistrano3-puma' # pumaを使う場合はこれも必要

gem 'activerecord-import'
gem 'kaminari'

# paranoia 論理削除
gem 'paranoia'

# settingslogic 定数を一元管理
gem 'settingslogic'


# pager
gem 'kaminari'
gem 'kaminari-activerecord'
gem 'kaminari-actionview'

# redis
gem 'redis-rails'

# sidekiq
gem 'sidekiq'
gem 'redis-namespace'
