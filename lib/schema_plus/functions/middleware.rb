# frozen_string_literal: true

module SchemaPlus::Functions
  module Middleware
    module Dumper
      module Tables
        # Dump
        def after(env)
          env.connection.functions.each do |(function_name, params, _options)|
            full_params, definition, function_type = env.connection.function_definition(function_name, params)
            heredelim                              = "END_FUNCTION_#{function_name.upcase}"
            extra_options                          = ", function_type: :#{function_type}" if function_type.present?
            statement                              = <<~ENDFUNCTION
                create_function "#{function_name}", "#{full_params}", <<-'#{heredelim}', :force => true#{extra_options}
              #{definition}
                #{heredelim}
            ENDFUNCTION

            env.dump.final << statement
          end
        end
      end
    end

    module Schema
      module Functions
        ENV = [:connection, :query_name, :functions]
      end

      module FunctionDefinition
        ENV = [:connection, :function_name, :params, :query_name, :definition, :function_type]
      end
    end

    module Migration
      module CreateFunction
        ENV = [:connection, :function_name, :params, :definition, :options]
      end

      module DropFunction
        ENV = [:connection, :function_name, :params, :options]
      end
    end
  end
end