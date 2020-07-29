# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

describe "Schema dump" do
  it "includes the function definition for an aggregate function" do
    apply_migration do
      create_function :array_cat_agg, "anyarray", <<-END, function_type: :aggregate
(SFUNC=array_cat,STYPE=anyarray)
      END
    end

    expect(dump_schema).to match(%r{create_function.+array_cat_agg.+aggregate})
  end

  it "includes the function definition for a regular function" do
    apply_migration do
      create_function :test, "start date, stop date DEFAULT NULL::date", <<-END
RETURNS integer
  LANGUAGE plpgsql
  AS $$
DECLARE
  processed INTEGER = 0;
BEGIN
  processed = processed + 1;  
  RETURN processed;
END;
$$
      END
    end

    expect(dump_schema).to match(%r{create_function.+test.+start date, stop date DEFAULT})
  end

  protected

  def dump_schema(opts = {})
    stream = StringIO.new

    ActiveRecord::SchemaDumper.ignore_tables = Array.wrap(opts[:ignore]) || []
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)

    stream.string
  end
end
