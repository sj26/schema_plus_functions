# frozen_string_literal: true

require 'simplecov'
require 'simplecov-gem-profile'
SimpleCov.start "gem"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'active_record'
require 'schema_plus_functions'
require 'schema_dev/rspec'

SchemaDev::Rspec.setup

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.warnings = true
  config.around(:each) do |example|
    ActiveRecord::Migration.suppress_messages do
      begin
        example.run
      ensure
        ActiveRecord::Base.connection.functions.each do |(func_name, params, options)|
          ActiveRecord::Migration.drop_function func_name, params, options
        end
      end
    end
  end
end

def define_schema(config = {}, &block)
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      ActiveRecord::Base.connection.functions.each do |(func_name, params, options)|
        ActiveRecord::Migration.drop_function func_name, params, options
      end
      instance_eval &block
    end
  end
end

def apply_migration(config = {}, &block)
  ActiveRecord::Schema.define do
    instance_eval &block
  end
end

SimpleCov.command_name "[ruby#{RUBY_VERSION}-activerecord#{::ActiveRecord.version}-#{ActiveRecord::Base.connection.adapter_name}]"
