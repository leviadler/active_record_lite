class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      var = "@#{name}"
      define_method(name) do
        self.instance_variable_get(var)
      end

      define_method("#{name}=") do |argument|
        self.instance_variable_set(var, argument)
      end

    end
  end
end
