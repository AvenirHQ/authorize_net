require 'net/http'
require 'uri'

# ===============================================================
# This class represents a request to the Authorize.Net API
#
# Add any logic that applies to ALL requests here
# ===============================================================
class AuthorizeNet::Request

  attr_accessor :response

  def initialize(type, data, uri)
    @xml_data = data
    @request_type = type
    @uri = URI(uri)
    @response = nil
  end

  # =============================================
  # Uses the given data to make a POST request
  # =============================================
  def postRequest
    assertRequestData
    assertRequestType
    req = Net::HTTP::Post.new(@uri.request_uri)
    req.add_field('Content-Type', 'text/xml')
    req.body = buildXmlRequest
    @response = sendRequest(req)
    return @response
  end

  # =============================================
  # Uses the given data to make a GET request
  # =============================================
  def getRequest
    assertRequestType
    req = Net::HTTP::Get.new(@uri.request_uri)
    req.add_field('Content-Type', 'text/xml')
    req.body = buildXmlRequest
  end

  # =============================================
  # Make a log string for this request
  # =============================================
  def toLog(log_body)
    log = "[AuthorizeNet] HTTP Request type=#{@request_type} uri=#{@uri}"

    if log_body
      log += " body=\"#{buildXmlRequest}\""
    end

    return log
  end


  private

  def assertRequestData
    if @xml_data.nil?
      raise "AuthorizeRequest has no xml data"
    end
  end

  def assertRequestType
    if @request_type.nil?
      raise "AuthorizeRequest has no request type"
    end
  end

  # =============================================
  # Builds the full XML request using request
  # type and the xml data object
  # =============================================
  def buildXmlRequest
    xml_string = AuthorizeNet::XML_HEADER
    xml_string += "<#{@request_type} xmlns=\"#{AuthorizeNet::XML_SCHEMA}\">"
    xml_string += AuthorizeNet::Util.buildXmlFromObject(@xml_data)
    xml_string += "</#{@request_type}>"
    return xml_string
  end

  # =============================================
  # Sends the input request to Authorize.Net
  # =============================================
  def sendRequest(req)
    http = Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https')
    @response = http.request(req)
    return @response
  end


end
