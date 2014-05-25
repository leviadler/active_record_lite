require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    all_objects = []
    results.each do |row|
      all_objects << self.new(row)
    end
    all_objects
  end
end

class SQLObject < MassObject
  def self.columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
      LIMIT 1
    SQL

    columns.first.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || "#{self}".tableize
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    self.parse_all(all)
  end

  def self.find(id)
    by_id = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE
      id = ?
      LIMIT 1
    SQL

    self.new(by_id.first)
  end

  def attributes
    @attributes ||= Hash.new
  end

  def insert
    columns = self.class.columns - ["id"]
    col_names = columns.join(", ")
    question_marks = (['?'] * columns.length).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
      #{self.class.table_name} (#{col_names})
      VALUES
      (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    columns = self.class.columns

    params.each do |attr_name, val|
      attr_name = attr_name.to_sym

      unless columns.include?(attr_name.to_s)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", val)
    end
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end

  def update
    columns = self.class.columns # - ["id"]
    set_vals = columns.join(' = ?, ') + " = ?"
    values = attribute_values #[1..-1] #to remove id

    DBConnection.execute(<<-SQL, *values, self.id)
      UPDATE
      #{self.class.table_name}
      SET
      #{set_vals}
      WHERE
      id = ?
    SQL
  end

  def attribute_values
    attributes.values
    # this would be better b/c never need if
    # and wont have to exclude 1st index in 'update'
    # but then it fails specs
    # attributes.select { |attr, value| attr != 'id'}.values
  end
end
