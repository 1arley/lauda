source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'image_processing', '~> 1.2'
gem 'importmap-rails'
gem 'jbuilder'
gem 'json', '~> 2.9'
gem 'pg', '~> 1.1'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.1.3', '>= 8.1.3.1'
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'thruster', require: false
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

# Auth & Authorization
gem 'devise'
gem 'devise-jwt'
gem 'dotenv-rails', groups: %i[development test]
gem 'pundit'

# Multi-tenant
gem 'acts_as_tenant'

# Soft delete
gem 'discard'

# Pagination
gem 'pagy', '~> 9.0'

# Search
gem 'ransack'

# PDF generation
gem 'prawn'
gem 'prawn-table'

# Audit logging
gem 'audited'

# Monitoring
gem 'lograge'

gem 'inline_svg'

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'sorbet-runtime'
end

group :development do
  gem 'annotate'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'sorbet', require: false
  gem 'tapioca', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end
