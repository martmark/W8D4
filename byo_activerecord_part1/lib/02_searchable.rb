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
end

