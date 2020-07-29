# frozen_string_literal: true

module SchemaPlus::Functions
  module ActiveRecord
    module Migration
      module CommandRecorder
        def create_function(*args, &block)
          record(:create_function, args, &block)
        end

        def drop_function(*args, &block)
          record(:drop_function, args, &block)
        end

        def invert_create_function(args)
          options                 = {}
          options[:function_type] = args[3][:function_type] if args[3].has_key?(:function_type)
          [:drop_function, [args.first, args.second, options]]
        end
      end
    end
  end
end