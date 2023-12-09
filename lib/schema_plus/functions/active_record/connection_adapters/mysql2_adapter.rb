# frozen_string_literal: true

module SchemaPlus::Functions
  module ActiveRecord
    module ConnectionAdapters
      module Mysql2Adapter
        def functions(name = nil) #:nodoc:
          SchemaMonkey::Middleware::Schema::Functions.start(connection: self, query_name: name, functions: []) do |env|
            sql = <<-SQL
              SHOW FUNCTION STATUS WHERE db = DATABASE()
            SQL

            env.functions += env.connection.query(sql, env.query_name).sort_by { |row| row["Name"] }.map do |row|
              [row["Name"], {}, {}]
            end
          end.functions
        end

        def function_definition(function_name, params, name = nil) #:nodoc:
          data = SchemaMonkey::Middleware::Schema::FunctionDefinition.start(connection: self, function_name: function_name, params: params, query_name: name) do |env|
            result = env.connection.query(<<-SQL, env.query_name)
              SHOW CREATE FUNCTION #{function_name}}
            SQL

            row = result.first

            function_type = nil

            unless row.nil?
              env.params        = {}
              env.definition    = row["Function"]
              env.function_type = nil
            end
          end

          return data.params, data.definition, data.function_type
        end
      end
    end
  end
end
