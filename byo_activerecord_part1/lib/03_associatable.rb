require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name

    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options[:foreign_key] = (name.to_s + "_id").to_sym if options[:foreign_key].nil?
    options[:class_name] = name.to_s.camelcase if options[:class_name].nil?
    options[:primary_key] = :id if options[:primary_key].nil?
   
    options.each do |k,v|
      self.send("#{k}=", v)
    end
  end
end

      
class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options[:foreign_key] = (self_class_name.to_s.downcase + "_id").to_sym if options[:foreign_key].nil?
    options[:class_name] = name.to_s.singularize.camelcase if options[:class_name].nil?
    options[:primary_key] = :id if options[:primary_key].nil?
      
    options.each do |k,v|
      self.send("#{k}=", v)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
  

    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options

    define_method(name) do
      target = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => target).first
    end
 
  end

  def has_many(name, options = {})
   
    options = HasManyOptions.new(name, self, options)
    self.assoc_options[name] = options
    define_method(name) do
      target = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => target)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
