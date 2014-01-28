require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    p through_options
    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]
      p source_options
      p through_options
      sql = <<-SQL
      SELECT
      #{source_options.table_name}.*
      FROM
      #{through_options.table_name}
      JOIN
      #{source_options.table_name}
      ON
      #{through_options.table_name}.#{source_options.foreign_key} =
        #{source_options.table_name}.#{through_options.primary_key}
      WHERE
        #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL
      result = DBConnection.execute(sql, self.send(through_options.foreign_key)).first
      source_options.model_class.new(result)
    end
  end
end
