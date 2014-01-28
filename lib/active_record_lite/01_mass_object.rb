require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    new_attributes.each do |attr|
      my_attr_accessor(attr)
    end
    @attributes = new_attributes
  end

  def self.attributes
    raise "must not call #attributes on MassObject directly" if self == MassObject
    @attributes ||= []
  end

  def initialize(params = {})

    params.each do |key, value|
      if self.class.attributes.include?(key.to_sym)
        MassObject.my_attr_accessible(key.to_sym)
        self.send("#{key}=", value)
      else
        raise "mass assignment to unregistered attribute '#{key}'"
      end
    end
  end

end
