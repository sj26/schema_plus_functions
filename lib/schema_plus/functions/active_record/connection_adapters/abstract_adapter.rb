# frozen_string_literal: true

module SchemaPlus::Functions
  module ActiveRecord
    module ConnectionAdapters
      module AbstractAdapter
        # Create a function.  Valid options are :force,
        # :allow_replace, and :function_type
        def create_function(function_name, params, definition, options = {})
          SchemaMonkey::Middleware::Migration::CreateFunction.start(connection: self, function_name: function_name, params: params, definition: definition, options: options) do |env|
            function_name = env.function_name
            function_type = (options[:function_type] || :function).to_s.upcase
            params        = env.params
            definition    = env.definition
            options       = env.options

            definition    = definition.to_sql if definition.respond_to? :to_sql
            if options[:force]
              drop_function(function_name, params, function_type: options[:function_type], if_exists: true)
            end

            command = if options[:allow_replace]
                        "CREATE OR REPLACE"
                      else
                        "CREATE"
                      end
            execute "#{command} #{function_type} #{function_name}(#{params}) #{definition}"
          end
        end

        # Remove a function.  Valid options are :function_type,
        # :if_exists, and :cascade
        #
        # If your function type is an aggregate, you must specify the type
        #
        #    drop_function 'my_func', 'int', if_exists: true, cascade: true
        #    drop_function 'my_agg', 'int', function_type: :aggregate
        def drop_function(function_name, params, options = {})
          SchemaMonkey::Middleware::Migration::CreateFunction.start(connection: self, function_name: function_name, params: params, options: options) do |env|
            function_name = env.function_name
            params        = env.params
            options       = env.options
            function_type = (options[:function_type] || :function).to_s.upcase

            sql = "DROP #{function_type}"
            sql += " IF EXISTS" if options[:if_exists]
            sql += " #{function_name}(#{params})"
            sql += " CASCADE" if options[:cascade]

            execute sql
          end
        end

        #####################################################################
        #
        # The functions below here are abstract; each subclass should
        # define them all. Defining them here only for reference.
        #

        # (abstract) Return the Function objects for functions
        def functions(name = nil)
          raise "Internal Error: Connection adapter did not override abstract function"
        end

        # (abstract) Return the Function definition for the named function and parameter set
        def function_definition(function_name, params, name = nil)
          raise "Internal Error: Connection adapter did not override abstract function"
        end
      end
    end
  end
end