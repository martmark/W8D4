require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns

    columns = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{ self.table_name }
      LIMIT 0
    SQL
    # debugger
    @columns = columns.first.map { |col| col.to_sym }
  end

  def self.finalize!
    cols = self.columns
    cols.each do |k|
      define_method(k) do
        self.attributes[k]
      end

      define_method("#{k}=") do |v|
        self.attributes[k] = v
      end
    end
  
  end

  def self.table_name=(new_name)
    @table_name = new_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{ self.table_name }
    SQL
    
    self.parse_all(data)
  end

  def self.parse_all(results)
    # ...
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    obj_array = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM 
      #{ self.table_name }
    WHERE id = ?
    SQL

    return nil if obj_array.empty?
    self.new(obj_array.first)
    
  end

  def initialize(params = {})
    
    params.each do |k, v|
      k_sym = k.to_sym
      raise "unknown attribute '#{ k }'" unless self.class.columns.include?(k_sym) 
       
      self.send("#{k_sym}=", v)
    end
    
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert

    cols = "(" + self.class.columns[1..-1].join(",") + ")"
    question_marks = ['?'] * (self.class.columns.length - 1)
    question_string = "(" + question_marks.join(",") + ")"
    vals = self.attribute_values
    tablename = self.class.table_name.to_s

    # debugger
    DBConnection.execute(<<-SQL, *vals)
    INSERT INTO
       #{ tablename } #{ cols }
    VALUES  #{ question_string }
    SQL

    last_row = DBConnection.execute(<<-SQL)
    SELECT
      last_insert_rowid()
    FROM
      #{ tablename }
    SQL

    self.attributes[:id] = last_row.first["last_insert_rowid()"]
  end

  def update
    # cols = "(" + self.class.columns[1..-1].join(",") + ")"
    question_marks = ['?'] * (self.class.columns.length)
    
    set_line = self.class.columns.map { |col| "#{col} = ?"}.join(",")
    question_string = "(" + question_marks.join(",") + ")"
    # vals = self.attribute_values
    tablename = self.class.table_name.to_s

    array = []

    self.attributes.each do |k, v|
      array << '#{k} = #{v}'
    end

    set_string = array.join(",")

    # debugger
    DBConnection.execute(<<-SQL, *self.attribute_values, self.id)
    UPDATE #{ tablename } 
    SET #{ set_line }
    WHERE
      id = ?
    SQL
  end

  def save
    tablename = self.class.table_name.to_s

    exist =  DBConnection.execute(<<-SQL, self.id)
        SELECT 1 FROM #{ tablename } WHERE id = ?
      SQL

    if exist.length > 0
      self.update
    else
      self.insert
    end
  end
end
