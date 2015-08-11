source 'https://rubygems.org'
#ruby '2.1.5' #'2.2.2' #2.1.5
gem 'rails', '4.2.1' #'4.2.0'

gem 'bootstrap-sass'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails' #, '~> 4.0.0'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'web-console', '~> 2.0.0'
  gem 'spring'
  #gem 'factory_girl_rails'
  #gem 'rspec-rails'
end

group :development, :test, :production do
  gem 'devise'
  gem 'simple_token_authentication', '~> 1.0'
  gem 'sendgrid'
  gem 'simple_form'
  gem 'mail_form'
  gem 'therubyracer'
  #gem 'unicorn'
  #gem 'unicorn-rails'
  gem 'upmin-admin'
  gem 'acts-as-taggable-on'
  gem 'will_paginate'
  gem 'bootstrap-will_paginate'

  gem 'less-rails'
  gem 'twitter-bootstrap-rails'
  gem 'geocoder'
  gem 'momentjs-rails', '>= 2.8.1'
  gem 'bootstrap3-datetimepicker-rails', '~> 3.1.3'
  gem 'json'
  gem 'faker'
  gem 'rails_warden'
  gem 'sunspot_rails'
  gem 'sunspot_solr'
  gem 'simple_calendar', "~> 1.1.0"
  #gem 'carrierwave',             '0.10.0'
  gem 'mini_magick',             '3.8.0'
  #gem 'fog',                     '1.23.0'
  gem 'carrierwave-aws', '0.5.0'
  gem 'aws-s3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

group :test do
  #gem 'capybara'
  #gem 'database_cleaner'
  #gem 'launchy'
  #gem 'selenium-webdriver'
  # Do we even need the above
  gem 'minitest-rails'
  gem 'minitest-reporters'
  #gem 'mini_backtrace'
  gem 'guard-minitest'
end

group :production do
  gem 'aws-sdk', '~> 2'
  gem 'aws-sdk-rails', '~> 1.0'
  gem 'fog-aws'
  gem 'pg', '~> 0.18.1'
  #gem 'rails_12factor'
  gem 'puma'
end
