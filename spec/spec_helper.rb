$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

require 'logger'
require 'active_record'
require 'active_support'
require 'sqlite3'

require 'rego-data-grid'

#-----------------db stuff
#load models schema (create tables)
require "db/schema_loader"

#load models
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
Dir["#{File.dirname(__FILE__)}/models/**/*.rb"].each {|f| require f}
#-----------------db stuff end


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# load factories for factory girl
require "factory_girl"
FactoryGirl.find_definitions

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
