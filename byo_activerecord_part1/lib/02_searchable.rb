require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    set_line = params.keys.map { |param| "#{param} = ?"}.join(" AND ")
    table_name = self.table_name
    param_val = params.values
    data = DBConnection.execute(<<-SQL, *param_val)
      SELECT * FROM #{ table_name } WHERE #{ set_line }
    SQL
    # debugger
    self.parse_all(data)
    # data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  extend Searchable

  #  def self.where(params)
  #   set_line = params.key.map { |param| "#{param} = ?"}.join(" AND ")
  #   tablename = self.class.table_name.to_s
  #   # debugger
  #   DBConnection.execute(<<-SQL, *params.values)
  #     SELECT * FROM #{ tablename } WHERE #{ set_line }
  #   SQL
  #   # data.map { |datum| self.class.new(datum) }
  #end
end

