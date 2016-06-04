module AuthorizeNet
  URI = "https://api2.authorize.net/xml/v1/request.api"
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
current_dir = __FILE__.match(/(.*)\/authorize_net.rb/)
if !current_dir.nil?
  authorize_dir = current_dir[1] + "/authorize_net/**/*.rb"

  Dir[authorize_dir].each do |filename|
    require filename
  end

else
  raise "Error loading authorize_net files"
end

