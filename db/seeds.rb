# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env == 'development'
  seed_file = Rails.root.join('config', 'role_map.yml')
  config = YAML.load_file(seed_file)[Rails.env]

  config.each_value do |emails|
    email = emails.first
    password = 'valkyrie'
    User.create!(email: email, password: password, password_confirmation: password) unless User.exists?(email: email)
  end
end
