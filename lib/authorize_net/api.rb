require 'nokogiri'
require 'openssl'

# ===============================================================
# This class uses the AuthroizeRequest object to interact with
# the Authorize.Net API
#
# Add any new Authroize.Net API endpoints here
# ===============================================================
class AuthorizeNet::Api

  def initialize(api_login_id, api_transaction_key, **options)
    @api_login_id = api_login_id
    @api_transaction_key = api_transaction_key
    @is_sandbox = options[:sandbox]
    @signature_key = options[:signature_key]
    @logger = nil
    @log_full_request = false
  end

  def setLogger(logger)
    @logger = logger
  end

  def setLogFullRequest(log_full_request)
    @log_full_request = log_full_request
  end

  # ===============================================================
  # Charges the given credit card
  # @param Number amount
  # @param AuthorizeNet::CreditCard credit_card
  # @param AuthorizeNet::Address billing_address
  # @return {transaction_id}
  # ===============================================================
  def chargeCard(amount, credit_card, billing_address=nil)
    xml_obj = getXmlAuth
    xml_obj["transactionRequest"] = {
      "transactionType" => "authCaptureTransaction",
      "amount" => amount,
      "payment" => {
        "creditCard" => credit_card.to_h,
      },
    }
    if !billing_address.nil?
      xml_obj["transactionRequest"]["billTo"] = billing_address.to_h
    end

    response = sendRequest("createTransactionRequest", xml_obj)
    validate_hash(response, amount)
    if !response.nil?
      return AuthorizeNet::Transaction.parse(response)
    end
  end

  # ===============================================================
  # Creates the CustomerProfile and charges the first listed
  # PaymentProfile on AuthorizeNet
  # @param Number amount
  # @param AuthorizeNet::CustomerProfile customer_profile
  # @return {customer_profile_id, payment_profile_id}
  # ===============================================================
  def chargeAndCreateProfile(amount, customer_profile)
    if customer_profile.payment_profiles.empty?
      raise "[AuthorizeNet] CustomerProfile in Api.chargeAndCreateProfile requires a PaymentProfile"
    end

    payment_profile = customer_profile.payment_profiles.first
    xml_obj = getXmlAuth
    xml_obj["transactionRequest"] = {
      "transactionType" => "authCaptureTransaction",
      "amount" => amount,
      "payment" => {
        "creditCard" => payment_profile.credit_card.to_h,
      },
      "profile" => {
        "createProfile" => true,
      },
      "customer" => {
        "id" => customer_profile.merchant_id,
        "email" => customer_profile.email,
        "description" => customer_profile.description,
      },
      "billTo" => payment_profile.billing_address.to_h,
    }

    response = sendRequest("createTransactionRequest", xml_obj)
    validate_hash(response, amount)
    if !response.nil?
      return {
        :transaction => AuthorizeNet::Transaction.parse(response),
        :customer_profile_id => AuthorizeNet::Util.getXmlValue(
          response, "customerProfileId"),
        :payment_profile_id => AuthorizeNet::Util.getXmlValue(
          response, "customerPaymentProfileIdList numericString"),
      }
    end
  end

  # ===============================================================
  # Charges the given profile and payment profile on Authorize.net
  # @param Number amount
  # @param String/Number customer_profile_id
  # @param String/Number payment_profile_id
  # @return transaction_id
  # ===============================================================
  def chargeProfile(amount, profile_id, payment_profile_id)
    xml_obj = getXmlAuth
    xml_obj["transactionRequest"] = {
      "transactionType" => "authCaptureTransaction",
      "amount" => amount,
      "profile" => {
        "customerProfileId" => profile_id,
        "paymentProfile" => {
          "paymentProfileId" => payment_profile_id,
        },
      },
    }

    response = sendRequest("createTransactionRequest", xml_obj)
    validate_hash(response, amount)
    if !response.nil?
      return AuthorizeNet::Transaction.parse(response)
    end
  end

  # ===============================================================
  # Creates the given customer profile on Authorize.net
  # @param AuthorizeNet::CustomerProfile customer_profile
  # @param Number amount
  # @param AuthorizeNet::ValidationMode validation_mode (optional)
  # @return transaction_id
  # ===============================================================
  def createCustomerProfile(customer_profile, validation_mode=nil)
    xml_obj = getXmlAuth
    xml_obj["profile"] = customer_profile.to_h

    addValidationMode!(xml_obj, validation_mode)
    response = sendRequest("createCustomerProfileRequest", xml_obj)

    if !response.nil?
      return {
        :customer_profile_id => AuthorizeNet::Util.getXmlValue(
          response, "customerProfileId"),
        :payment_profile_id => AuthorizeNet::Util.getXmlValue(
          response, "customerPaymentProfileIdList numericString"),
      }
    end
  end

  # ===============================================================
  # Create Customer Payment Profile
  # @param String/Number customer_profile_id
  # @param AuthorizeNet::PaymentProfile payment_profile
  # @param AuthorizeNet::ValidationMode validation_mode (optional)
  # @return {customer_profile_id, payment_profile_id}
  # ===============================================================
  def createPaymentProfile(customer_profile_id, payment_profile, validation_mode=nil)
    xml_obj = getXmlAuth
    xml_obj["customerProfileId"] = customer_profile_id
    xml_obj["paymentProfile"] = payment_profile.to_h

    addValidationMode!(xml_obj, validation_mode)
    response = sendRequest("createCustomerPaymentProfileRequest", xml_obj)

    if !response.nil?
      return {
        :customer_profile_id => AuthorizeNet::Util.getXmlValue(
          response, "customerProfileId"),
        :payment_profile_id => AuthorizeNet::Util.getXmlValue(
          response, "customerPaymentProfileId"),
      }
    end
  end

  # ===============================================================
  # Delete Customer Payment Profile
  # @param String/Number customer_profile_id
  # @param String/Number payment_profile_id
  # @return boolean is delete successful?
  # ===============================================================
  def deletePaymentProfile(customer_profile_id, payment_profile_id)
    xml_obj = getXmlAuth
    xml_obj["customerProfileId"] = customer_profile_id
    xml_obj["customerPaymentProfileId"] = payment_profile_id

    response = sendRequest("deleteCustomerPaymentProfileRequest", xml_obj)
    return !response.nil?
  end

  # ===============================================================
  # Validate Customer Payment Profile
  # @param String/Number customer_profile_id
  # @param String/Number payment_profile_id
  # @param AuthorizeNet::ValidationMode::(String) validation_mode
  # @return boolean is update successful?
  # ===============================================================
  def validatePaymentProfile(customer_profile_id, payment_profile_id, validation_mode)
    xml_obj = getXmlAuth
    xml_obj["customerProfileId"] = customer_profile_id
    xml_obj["customerPaymentProfileId"] = payment_profile_id
    xml_obj["validationMode"] = validation_mode

    response = sendRequest("validateCustomerPaymentProfileRequest", xml_obj)
    return !response.nil?
  end

  # ===============================================================
  # Get customer profile information
  # @param String/Number customer_profile_id
  # @param String/Number customer_profile_id
  # @return AuthorizeNet::CustomerProfile
  # ===============================================================
  def getCustomerProfile(customer_profile_id)
    xml_obj = getXmlAuth
    xml_obj["customerProfileId"] = customer_profile_id

    response = sendRequest("getCustomerProfileRequest", xml_obj)
    if response
      return AuthorizeNet::CustomerProfile.parse(response)
    end
  end

  # ===============================================================
  # Gets transaction information
  # @param String/Number customer_profile_id
  # @param String/Number transaction_id
  # @return AuthorizeNet::Transaction
  # ===============================================================
  def getTransactionInfo(transaction_id)
    xml_obj = getXmlAuth
    xml_obj["transId"] = transaction_id

    response = sendRequest("getTransactionDetailsRequest", xml_obj)
    if response
      return AuthorizeNet::Transaction.parse(response)
    end
  end



  private

  def getXmlAuth
    return {
      "merchantAuthentication" => {
        "name" => @api_login_id,
        "transactionKey" => @api_transaction_key,
      }
    }
  end

  def addValidationMode!(xml_obj, validation_mode)
    if validation_mode
      xml_obj["validationMode"] = validation_mode
    end
  end

  # =============================================
  # Looks for potential errors in the response
  # and raises an error if it finds any
  # Passes through OK responses
  # @throws AuthorizeNet::Exception
  # =============================================
  def handleResponse(raw_response)
    logHttpResponse(raw_response)

    response = AuthorizeNet::Response.parseXml(raw_response.read_body)
    if response.result == AuthorizeNet::RESULT_OK && response.errors.nil?
      return response.parsed_xml
    else
      logErrorResponse(response)
      AuthorizeNet::ErrorHandler.handle(response)
    end
  end

  # =============================================
  # Validates that the returned transaction hash
  # value is what we expect it to be
  #
  # @throws AuthorizeNet::Exception
  # =============================================
  def validate_hash(response_xml, amount)
    if @signature_key.nil?
      return
    end

    formatted_amount = "%.2f" % amount
    transaction_id = AuthorizeNet::Util.getXmlValue(response_xml, "transId")
    hash_text = "^#{@api_login_id}^#{transaction_id}^#{formatted_amount}^"

    calculated_hash = OpenSSL::HMAC.hexdigest('sha512', [@signature_key].pack('H*'), hash_text).downcase
    trans_hash = AuthorizeNet::Util.getXmlValue(response_xml, "transHashSha2").downcase

    if calculated_hash != trans_hash
      if @logger.respond_to? :error
        @logger.error("[AuthorizeNet] Response Transaction Hash doesn't equal expected value. trans_hash=#{trans_hash} calculated_hash=#{calculated_hash}")
      end

      e = AuthorizeNet::Exception.new("[AuthorizeNet] Returned hash doesn't match expected value.")
      e.errors.push({:text => "Something went wrong. Please contact customer assistance or try again later"})
      raise e
    end
  end

  # =============================================
  # Send HTTP request to Authorize Net
  # @param Net::HTTPResponse
  # @return response
  # =============================================
  def sendRequest(type, xml_obj)
    uri = @is_sandbox ? AuthorizeNet::TEST_URI : AuthorizeNet::URI
    request = AuthorizeNet::Request.new(type, xml_obj, uri)

    if @logger.respond_to? :info
      @logger.info(request.toLog(@log_full_request))
    end

    return handleResponse(request.postRequest)
  end

  # =============================================
  # Log HTTP response from Authorize Net
  # @param Net::HTTPResponse
  # @return String log
  # =============================================
  def logHttpResponse(response)
    if @logger.respond_to? :logHttpResponse
      @logger.logHttpResponse(response)
    elsif @logger.respond_to? :info
      @logger.info("[AuthorizeNet] HTTP Response code=#{response.code} message=#{response.message}")
    end
  end

  # =============================================
  # Returns a log string with http response data
  # @param Net::HTTPResponse
  # @throws RuntimeError
  # =============================================
  def logErrorResponse(response)
    if @logger.respond_to? :info
      @logger.info("[AuthorizeNet] Responded with resultCode=\"#{response.result}\"")
    end

    if !response.messages.nil? and @logger.respond_to?(:info)
      response.messages.each do |msg|
        @logger.info("[AuthorizeNet] Message code=\"#{msg[:code]}\" text=\"#{msg[:text]}\"")
      end
    end

    if !response.errors.nil? and @logger.respond_to?(:error)
      response.errors.each do |error|
        @logger.error("[AuthorizeNet] Error code=\"#{error[:code]}\" text=\"#{error[:text]}\"")
      end
    end
  end

end
