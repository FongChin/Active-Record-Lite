require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class::table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.capitalize
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.capitalize
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      sql = <<-SQL
      SELECT
        *
      FROM
        #{self.class.assoc_options[name].table_name}
      WHERE
        id = ?
      SQL
      result = DBConnection.execute(sql, self.send(self.class.assoc_options[name].foreign_key)).first
      self.class.assoc_options[name].model_class.new(result)
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      sql = <<-SQL
      SELECT
        *
      FROM
        #{self.class.assoc_options[name].table_name}
      WHERE
        #{self.class.assoc_options[name].foreign_key} = ?
      SQL
      results = DBConnection.execute(sql, self.send(self.class.assoc_options[name].primary_key))
      self.class.assoc_options[name].model_class.parse_all(results)
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_params ||= {}
    @assoc_params
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
