class AuthorizeNet::Exception < Exception

  GENERIC_ERROR_MESSAGE = "[AuthorizeNet] The Authorize.Net API returned an error"

  attr_accessor :message
  attr_accessor :errors

  def initialize(message=GENERIC_ERROR_MESSAGE)
    @message = message
    @errors = []
  end

end
