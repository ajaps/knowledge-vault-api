# spec/rails_helper.rb
ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

# Load additional helpers if you add any under spec/support
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Keep schema up-to-date
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # FactoryBot shorthand: create(:user)
  config.include FactoryBot::Syntax::Methods

  # Transactions per example (good for API apps)
  config.use_transactional_fixtures = true

  # Infer spec type from folder so request specs get `get`, `post`, etc.
  config.infer_spec_type_from_file_location!

  # Silence Rails noise in backtraces
  config.filter_rails_from_backtrace!
end
