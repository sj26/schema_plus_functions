# frozen_string_literal: true

require 'spec_helper'

describe ActiveRecord::Migration do
  it "creates the function definition for an aggregate function" do
    apply_migration do
      create_function :array_cat_agg, "anyarray", <<-END, function_type: :aggregate
(SFUNC=array_cat,STYPE=anyarray)
      END
    end

    expect(functions).to include(['array_cat_agg', 'anyarray', {function_type: :aggregate}])
  end

  it "creates the function definition for a regular function" do
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

    expect(functions).to include(['test', 'start date, stop date', {}])
  end

  protected

  def functions
    ActiveRecord::Base.connection.functions
  end
end
