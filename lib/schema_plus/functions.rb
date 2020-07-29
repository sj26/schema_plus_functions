require 'schema_plus/core'

require_relative 'functions/version'

# Load any mixins to ActiveRecord modules, such as:
#
#require_relative 'functions/active_record/base'

# Load any middleware, such as:
#
# require_relative 'functions/middleware/model'

SchemaMonkey.register SchemaPlus::Functions
