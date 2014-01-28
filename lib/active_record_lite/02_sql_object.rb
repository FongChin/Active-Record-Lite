require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.pluralize.downcase
  end

  def self.all
    sql = <<-SQL
    SELECT
      *
    FROM
      "#{self.table_name}"
    SQL
    results = DBConnection.execute(sql)
    self.parse_all(results)
  end

  def self.find(id)
    sql = <<-SQL
    SELECT
      *
    FROM
      "#{self.table_name}"
    WHERE
      id = ?
    SQL
    result = DBConnection.execute(sql, id)
    self.parse_all(result).first
  end

  def insert
    col_names = self.class.attributes.drop(1).join(", ")
    question_marks = (["?"] * self.class.attributes.drop(1).length).join(", ")

    sql = <<-SQL
    INSERT INTO
      "#{self.class.table_name}" (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    result = DBConnection.execute(sql, *attribute_values.drop(1))
    self.id = DBConnection.last_insert_row_id
  end

  def save
    (self.id)? self.update : self.insert
  end

  def update
    attribute_keys = self.class.attributes
    set_clause_arr = []
    attribute_values.each_with_index do |value, index|
      set_clause_arr << "#{attribute_keys[index]} = ?"
    end
    set_clause = set_clause_arr[1...-1].join(", ")
    id = self.id

    sql = <<-SQL
    UPDATE
      "#{self.class.table_name}"
    SET
      #{set_clause}
    WHERE
      id = ?
    SQL
    DBConnection.execute(sql, *attribute_values[1...-1], id)
  end

  def attribute_values
    self.class.attributes.map do |name|
      self.send(name)
    end
  end
end
