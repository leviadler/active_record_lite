require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      source_table = source_options.table_name

      through_foreign_key = self.send(through_options.foreign_key)

      result = DBConnection.execute(<<-SQL, through_foreign_key)
        SELECT
        #{source_table}.*
        FROM
        #{through_table}
        JOIN
        #{source_table}
        ON
        #{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
        WHERE
        #{through_table}.#{through_options.primary_key}= ?
        SQL

      source_options.model_class.new(result.first)
    end
  end
end