require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_clause = params.map do |key, _|
      "#{key} = ?"
    end.join(" AND ")
    sql = <<-SQL
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_clause}
    SQL
    results = DBConnection.execute(sql, *params.values)
    self.parse_all(results)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
