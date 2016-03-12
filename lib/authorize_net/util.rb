class AuthorizeNet::Util

  class << self
    # ==============================================
    # A wrapper for safely getting the inner value
    # of an XML attribute only if it exists
    #
    # If multiple instances exist, return the first one
    # ==============================================
    def getXmlValue(xml, attr_string)
      if !xml.respond_to? :at_css || attr_string.nil?
        return nil
      end

      attr = xml.at_css(attr_string)
      if !attr.nil?
        return attr.inner_text
      end
    end

    # ==============================================
    # Builds XML from Ruby Hashes/Arrays/Primitives
    # ==============================================
    def buildXmlFromObject(obj, parent_tag=nil)
      xml = ""
      has_parent = !parent_tag.nil?

      # Arrays are formatted with the parent tag
      # wrapping each of the array elements for some
      # reason
      if obj.is_a? Array
        obj.each do |e|
          xml += has_parent ? "<#{parent_tag}>" : ""
          xml += buildXmlFromObject(e)
          xml += has_parent ? "</#{parent_tag}>" : ""
        end

      elsif obj.is_a? Hash
        xml += has_parent ? "<#{parent_tag}>" : ""
        obj.keys.each do |key|
          xml += buildXmlFromObject(obj[key], key.to_s)
        end
        xml += has_parent ? "</#{parent_tag}>" : ""

      elsif !obj.nil?
        xml += has_parent ? "<#{parent_tag}>" : ""
        xml += obj.to_s
        xml += has_parent ? "</#{parent_tag}>" : ""
      end

      return xml
    end
  end

end
