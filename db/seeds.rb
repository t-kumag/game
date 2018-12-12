# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# TODO
Entities::User.create(:email => "test01@example.com", :crypted_password => "test01", :token => "xxxxxxxxxxx01" )
Entities::User.create(:email => "test02@example.com", :crypted_password => "test02", :token => "xxxxxxxxxxx02" )
