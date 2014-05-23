require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    default_fk = (name + "_id").to_sym
    default_cn = name.to_s.camelcase
    defaults = {foreign_key: default_fk,
                primary_key: :id,
                class_name: default_cn}

    defaults.merge(options).each do |key, value|
      self.send("#{key}=", value)
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default_fk = (self_class_name.downcase.underscore + "_id").to_sym
    default_cn = name.singularize.camelcase
    defaults = {foreign_key: default_fk,
                primary_key: :id,
                class_name: default_cn}

    defaults.merge(options).each do |key, value|
      self.send("#{key}=", value)
    end
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
