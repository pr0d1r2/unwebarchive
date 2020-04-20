# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 2.7.1'

gem 'activesupport'
gem 'plist'

group :development do
  gem 'overcommit', require: false
  gem 'rspec'
  gem 'rubocop', require: false
end
