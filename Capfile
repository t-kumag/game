# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'
# require 'capistrano/copy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# # require 'capistrano/rvm'
# require 'capistrano/rbenv' #コメントアウトをはずす
# # require 'capistrano/chruby'
# require 'capistrano/bundler' #コメントアウトをはずす
# # require 'capistrano/rails/assets' #コメントアウトをはずす
# require 'capistrano/rails/migrations' #コメントアウトをはずす
# # require 'capistrano/passenger'
# require 'capistrano3/unicorn' #追記

# # Load custom tasks from `lib/capistrano/tasks` if you have any defined
# Dir.glob('lib/capistrano/tasks/*.task').each { |r| import r }




require 'capistrano/bundler'
# require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/puma'
 
# プラグインのインストール
install_plugin Capistrano::Puma
 
# Capistranoへ独自タスクを追加するときの拡張子を「.rake」から「.rb」に変更
Dir.glob('lib/capistrano/tasks/*.rb').each { |r| import r }