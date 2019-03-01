require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]

    fk = self.send(through_options.foreign_key)
    define_method(name) do
      #debugger
    source_options =
      through_options.model_class.assoc_options[source_name]
      pk = self.send(source_options.primary_key)


    DBConnection.execute(<<-SQL, )
      
    SQL

      
      
    end

    # source_options = self.name
    # debugger
    # source_options.each do |option|
    #   self.parse_all(options)
    # end
  end


end


# DBConnection.execute(<<-SQL)
#       SELECT *
#       FROM #{ self.table_name }
#       LIMIT 0
#     SQL