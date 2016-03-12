module AuthorizeNet
  URI = "https://api.authorize.net/xml/v1/request.api"
  TEST_URI = "https://apitest.authorize.net/xml/v1/request.api"
  XML_SCHEMA = "AnetApi/xml/v1/schema/AnetApiSchema.xsd"
  XML_HEADER = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
  RESULT_OK = "Ok"
  RESULT_ERROR = "Error"

  # ===============================================================
  # Constants for types of authorize net credit card validation
  #
  # Live Mode - Executes a test charge on the credit card for $0.01
  #   that is immediately voided
  # Test Mode - Does basic mathematical checks on card validity
  # None - No validation, could be useful for integration tests?
  # ===============================================================
  module ValidationMode
    LIVE = "liveMode"
    TEST = "testMode"
    NONE = "None"
  end
end

# require all authorize-net files
Dir['lib/authorize_net/**/*.rb'].each do |filename|
  match = filename.match(/lib\/(authorize_net\/.*).rb/)
  if !match.nil?
    require match[1]
  end
end
