# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# TODO
Entities::User.create(email: 'test01@example.com', crypted_password: 'test01', token: 'xxxxxxxxxxx01')
Entities::User.create(email: 'test02@example.com', crypted_password: 'test02', token: 'xxxxxxxxxxx02')
Entities::User.create(email: 'test03@example.com', crypted_password: 'test03', token: 'xxxxxxxxxxx03')
Entities::User.create(email: 'test04@example.com', crypted_password: 'test04', token: 'xxxxxxxxxxx04')
Entities::User.create(email: 'test88@example.com', crypted_password: 'test88', token: 'qxxxxxxxxxx88')

# groups
2.times do
  Entities::Group.create
end

# at_transaction_categories
Entities::AtTransactionCategory.create(at_category_id: 1, category_name1: '食費', category_name2: 'サンプル')

# payment_method
Entities::PaymentMethod.create(name: '口座')
Entities::PaymentMethod.create(name: 'クレジットカード')
