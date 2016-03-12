# *** NOTE ***
# Data objects must have a static ATTRIBUTES hash followed by these lines
#
#  self::ATTRIBUTES.keys.each do |attr|
#    attr_accessor attr
#  end
#
class AuthorizeNet::DataObject

  TYPE_ARRAY = :type_array
  TYPE_OBJECT = :type_object
  TYPE_OBJECT_ARRAY = :type_object_array

  # =======================================================
  # Parses XML from the values in the ATTRIBUTES hash in
  # to the attributes of this object.
  # =======================================================
  def parse(xml)
    if xml.nil? || !xml.respond_to?(:at_css)
      return
    end

    self.class::ATTRIBUTES.keys.each do |attr|
      spec = self.class::ATTRIBUTES[attr].to_h
      xml_key = spec[:key] || attr.to_s
      type = spec[:type]
      type_class = spec[:class]

      if (type == TYPE_OBJECT or type == TYPE_OBJECT_ARRAY) and type_class.nil?
        raise "DataObject=#{self.class} Attribute=#{attr} of type #{type} must specify a class"
      end

      if type == TYPE_OBJECT
        obj_xml = xml.at_css(xml_key)
        send("#{attr}=", type_class.parse(obj_xml))

      elsif type == TYPE_OBJECT_ARRAY
        array_xml = xml.css(xml_key)
        send("#{attr}=", array_xml.map{ |x| type_class.parse(x) })

      elsif type == TYPE_ARRAY
        array_xml = xml.css(xml_key)
        send("#{attr}=", array_xml.map{ |x| x.inner_text })

      else
        send("#{attr}=", AuthorizeNet::Util.getXmlValue(xml, xml_key))
      end
    end
  end

  # =======================================================
  # Turns this object into a hash using the keys specified
  # as the values in ATTRIBUTES
  #
  # If the value in ATTRIBUTES is nil, use the String
  # version of the attribute itself
  # =======================================================
  def to_h(include_blanks=false)
    hash = {}
    self.class::ATTRIBUTES.keys.each do |attr|
      spec = self.class::ATTRIBUTES[attr].to_h
      key = spec[:key] || attr.to_s
      type = spec[:type]
      value = send(attr)

      if value.nil?
        if include_blanks
          hash[key] = nil
        end
      elsif type == TYPE_OBJECT
        hash[key] = value.to_h
      elsif type == TYPE_OBJECT_ARRAY
        hash[key] = value.map{ |e| e.to_h }
      else
        hash[key] = value
      end
    end

    return hash
  end

  # =======================================================
  # Turns this object into a hash using the keys specified
  # as the keys in ATTRIBUTES
  # =======================================================
  def serialize
    hash = {}
    self.class::ATTRIBUTES.keys.each do |attr|
      spec = self.class::ATTRIBUTES[attr].to_h
      type = spec[:type]
      value = send(attr)

      if value.nil?
        hash[attr] = nil
      elsif type == TYPE_OBJECT
        hash[attr] = value.serialize
      elsif type == TYPE_OBJECT_ARRAY
        hash[attr] = value.map{ |e| e.serialize }
      else
        hash[attr] = value
      end
    end

    return hash
  end


  class << self
    # =============================================
    # Parses xml into a new instance of this class
    # =============================================
    def parse(xml)
      if xml.nil? || !xml.respond_to?(:at_css)
        return
      end

      object = new
      object.parse(xml)
      return object
    end
  end

end
