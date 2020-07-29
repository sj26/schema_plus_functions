# frozen_string_literal: true

require 'schema_plus/core'

require_relative 'functions/version'
require_relative 'functions/active_record/connection_adapters/abstract_adapter'
require_relative 'functions/active_record/migration/command_recorder'
require_relative 'functions/middleware'

module SchemaPlus::Functions
  module ActiveRecord
    module ConnectionAdapters
      autoload :PostgresqlAdapter, 'schema_plus/functions/active_record/connection_adapters/postgresql_adapter'
    end
  end
end

SchemaMonkey.register SchemaPlus::Functions