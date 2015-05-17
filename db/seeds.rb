# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# user = CreateAdminService.new.call
# puts 'CREATED ADMIN USER: ' << user.email

User.create!(name:                  'Pat',
             email:                 'rasmussen.56@osu.edu',
             password:              'password',
             password_confirmation: 'password',
             grades:                'Senior',
             job_title:             'Bossman',
             business:              'School Business',
             role:                  :Admin)

User.create!(name:                  'Derek',
             email:                 'dludwig999@gmail.com',
             password:              'password',
             password_confirmation: 'password',
             grades:                'Senior',
             job_title:             'Bossman',
             business:              'School Business',
             role:                  :Admin)

User.create!(name:                  'Kevin',
             email:                 'gannon.85@osu.edu',
             password:              'password',
             password_confirmation: 'password',
             grades:                'Senior',
             job_title:             'Bossman',
             business:              'School Business',
             role:                  :Admin)

# SCHOOLS

10.times do
  School.create!(name:              Faker::Company.name)
end

School.all.each do |school|
  school.create_location!(address:    Faker::Address.street_address)
end

# SPEAKERS

10.times do
  password = 'password'
  User.create!(name:                  Faker::Name.name,
               email:                 Faker::Internet.email,
               password:              password,
               password_confirmation: password,
               job_title:             Faker::Name.title,
               business:              Faker::Company.name,
               tag_list:              Faker::Lorem.words(rand(1..5)),
               biography:             Faker::Lorem.sentence(20),
               role:                  :Speaker)
end

# BOTH

10.times do
  password = 'password'
  User.create!(name:                    Faker::Name.name,
               email:                   Faker::Internet.email,
               password:                password,
               password_confirmation:   password,
               school_id:               rand(1..10),
               grades:                  'Grade ' + Faker::Number.digit,
               job_title:               Faker::Name.title,
               business:                Faker::Company.name,
               tag_list:                Faker::Lorem.words(rand(1..5)),
               biography:               Faker::Lorem.sentence(20),
               role:                    :Both)
end
# TEACHERS

10.times do
  password = 'password'
  User.create!(name:                    Faker::Name.name,
               email:                   Faker::Internet.email,
               password:                password,
               password_confirmation:   password,
               school_id:               rand(1..10),
               grades:                  'Grade ' + Faker::Number.digit,
               tag_list:                Faker::Lorem.words(rand(1..5)),
               biography:               Faker::Lorem.sentence(20),
               role:                    :Teacher)
end

# EVENTS

users = User.where('role = ? OR role = ?', 1, 3)
10.times do
  users.each do |user|
    user.events.create!(content:  Faker::Lorem.sentence(10),
                        tag_list: ['Technology', 'Engineering', 'Nutrition', 'Business', 'Finance', 'Volunteer'].sample,
                        title:    Faker::Lorem.sentence(rand(1..5)),
                        start:    Time.zone.now,
                        end:      Time.zone.now)
  end
end

# CLAIMS

events = Event.order(:created_at).take(20)
events.each do |event|
  event.claims.create!(user_id:       rand(4..20))
end

# SPEAKER, ADMIN LOCATIONS

User.where('role = ? OR role = ?', 2, 0).each do |user|
   user.create_location!(address:     Faker::Address.street_address,
                         user_id:     user.id)
end

# SCHOOL LOCATIONS

School.all do |school|
  school.create_location!(address:    Faker::Address.street_address,
                          school_id:  school.id)
end