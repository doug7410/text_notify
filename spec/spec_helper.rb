ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/email/rspec'
require 'vcr'
require 'capybara/poltergeist'
require 'shoulda/matchers'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :poltergeist
Capybara.server_port = 52662

Capybara.register_driver :poltergeist do |app|
  options = {
    :js_errors => false,
    :timeout => 120,
    :debug => false,
    :phantomjs_options => ['--load-images=no', '--disk-cache=false', '--ignore-ssl-errors=yes'],
    :inspector => true
  }
  Capybara::Poltergeist::Driver.new(app, options)
end
 
# I'm not sure if this is neccisary? 
Capybara.default_wait_time = 5

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true
end


RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.infer_spec_type_from_file_location!

  # the configs below are for database cleaner
  config.use_transactional_fixtures = false
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
   
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end
   
  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end
   
  config.before(:each) do
    DatabaseCleaner.start
  end
   
  config.after(:each) do
    DatabaseCleaner.clean
  end

   if config.files_to_run.one?
    # config.default_formatter = 'doc'
  end
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil
   
  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

