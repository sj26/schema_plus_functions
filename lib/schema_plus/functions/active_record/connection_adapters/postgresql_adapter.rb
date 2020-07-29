# frozen_string_literal: true

module SchemaPlus::Functions
  module ActiveRecord
    module ConnectionAdapters
      module PostgresqlAdapter
        def drop_function(function_name, params, options = {})
          clean_params = params.gsub(/ DEFAULT[^,]+/i, '')
          super(function_name, clean_params, options)
        end

        def functions(name = nil) #:nodoc:
          SchemaMonkey::Middleware::Schema::Functions.start(connection: self, query_name: name, functions: []) do |env|
            sql = <<-SQL
            SELECT P.proname as function_name, pg_get_function_identity_arguments(P.oid), proisagg as is_agg
              FROM pg_proc P
            WHERE
                  pronamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (current_schemas(false))) 
              AND NOT EXISTS (SELECT 1 FROM pg_depend WHERE classid = 'pg_proc'::regclass 
                    AND objid = p.oid AND deptype = 'i')
              AND NOT EXISTS (SELECT 1 FROM pg_depend WHERE classid = 'pg_proc'::regclass
                    AND objid = p.oid AND refclassid = 'pg_extension'::regclass AND deptype = 'e')
            ORDER BY 1,2
            SQL

            env.functions += env.connection.query(sql, env.query_name).map do |row|
              options                 = {}
              options[:function_type] = :aggregate if row[2]
              [row[0], row[1], options]
            end
          end.functions
        end

        def function_definition(function_name, params, name = nil) #:nodoc:
          data = SchemaMonkey::Middleware::Schema::FunctionDefinition.start(connection: self, function_name: function_name, params: params, query_name: name) do |env|
            result = env.connection.query(<<-SQL, env.query_name)
            SELECT prosrc,
                pg_get_function_arguments(p.oid),
                pg_catalog.pg_get_function_result(p.oid) AS funcresult,
                (SELECT lanname FROM pg_catalog.pg_language WHERE oid = prolang) AS lanname,
                a.aggtransfn as transfn,
                format_type(a.aggtranstype, null) as transtype
              FROM pg_proc p
              LEFT JOIN pg_aggregate a ON a.aggfnoid = p.oid
            WHERE 
                pronamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (current_schemas(false)))
                AND proname = '#{quote_string(function_name)}'
                AND pg_get_function_identity_arguments(P.oid) = '#{quote_string(params)}'
            SQL

            row = result.first

            function_type = nil

            unless row.nil?
              sql               = if row[4].present? || row[0] == 'aggregate_dummy'
                                    # it's an aggregate function
                                    function_type = :aggregate
                                    "(SFUNC=#{row[4]},STYPE=#{row[5]})"
                                  else
                                    "RETURNS #{row[2]} LANGUAGE #{row[3]} AS $$#{row[0]}$$"
                                  end
              env.params        = row[1]
              env.definition    = sql
              env.function_type = function_type
            end
          end

          return data.params, data.definition, data.function_type
        end
      end
    end
  end
end

