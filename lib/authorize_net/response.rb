require 'nokogiri'

class AuthorizeNet::Response

  attr_accessor :result
  attr_accessor :errors
  attr_accessor :messages
  attr_accessor :raw_xml
  attr_accessor :parsed_xml

  class << self

    # =============================================
    # Returns a populated response object
    # @param String xml
    # @return AuthorizeNet::Response
    # =============================================
    def parseXml(xml)
      response = new
      response.raw_xml = xml
      response.parsed_xml = Nokogiri::XML.parse(xml)
      response.result = AuthorizeNet::Util.getXmlValue(response.parsed_xml, "resultCode")

      errors = response.parsed_xml.at_css("errors")
      if !errors.nil?
        response.errors = []
        errors.css("error").each do |xml_error|
          response.errors << {
            :code => AuthorizeNet::Util.getXmlValue(xml_error, "errorCode"),
            :text => AuthorizeNet::Util.getXmlValue(xml_error, "errorText"),
          }
        end
      end

      messages = response.parsed_xml.at_css("messages")
      if !messages.nil?
        response.messages = []
        messages.css("message").each do |xml_msg|
          response.messages << {
            :code => AuthorizeNet::Util.getXmlValue(xml_msg, "code"),
            :text => AuthorizeNet::Util.getXmlValue(xml_msg, "text"),
          }
        end
      end

      return response
    end
  end

end
