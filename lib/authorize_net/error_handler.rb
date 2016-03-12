
class AuthorizeNet::ErrorHandler
  class << self
    ERROR_FIELD_REGEXES = [
      /'AnetApi\/xml\/v1\/schema\/AnetApiSchema\.xsd:([a-zA-Z]*)'/,
      /The element '([a-zA-Z]*)' in namespace 'AnetApi\/xml\/v1\/schema\/AnetApiSchema.xsd'/
    ]

    MESSAGE_CODES = {
      "E00003" => :invalid_field,
      "E00015" => :invalid_field_length,
      "E00027" => :missing_required_field,
      "E00039" => :duplicate_record_exists,
      "E00041" => :customer_profile_info_required,
    }

    ERROR_CODES = {
      "210" => :transaction_declined,
      "6" => :invalid_card_number,
      "7" => :invalid_expiration_date,
      "8" => :expired_credit_card,
    }

    ERROR_FIELDS = {
      :invalid_card_number => :card_number,
      :invalid_expiration_date => :card_expiration,
      :expired_credit_card => :card_expiration,

      "cardNumber" => :card_number,
      "expirationDate" => :card_expiration,
      "cardCode" => :card_security_code,
    }

    # =============================================
    # Creates an exception, populates it as well
    # as possible, and then raises it
    # @param AuthorizeNet::Response
    # @throws AuthorizeNet::Exception
    # =============================================
    def handle(response)
      exception = AuthorizeNet::Exception.new

      if !response.errors.nil?
        first_error = response.errors.first
        exception.message = first_error[:text]

        # Add errors to exception
        response.errors.each do |error|
          exception.errors << buildError(error)
        end

        raise exception

      # If there are no errors, then the "messages" are probably errors... *sigh*
      elsif !response.messages.nil? and response.result == AuthorizeNet::RESULT_ERROR
        first_msg = response.messages.first
        exception.message = first_msg[:text]

        # Add messages (that are sometimes actually errors) to exception
        response.messages.each do |msg|
          exception.errors << buildError(msg)
        end

        raise exception
      end

    end

    # =============================================
    # Attempts to determine the error type and field
    # for an error hash
    # @param Hash error
    # @return Hash error
    # =============================================
    def buildError(error)
      code = error[:code]
      text = error[:text]
      type = getTypeFromCode(code)
      field = nil

      if !type.nil? and ERROR_FIELDS.has_key? type
        field = ERROR_FIELDS[type]
      else
        field = getFieldFromText(text)
      end

      return {
        :code => code,
        :text => text,
        :type => type,
        :field => field,
      }
    end

    # =============================================
    # Attempts to determine the error type given
    # an error code
    # @param String code
    # @return Symbol|nil type
    # =============================================
    def getTypeFromCode(code)
      if ERROR_CODES.has_key? code
        return ERROR_CODES[code]
      elsif MESSAGE_CODES.has_key? code
        return MESSAGE_CODES[code]
      end
      return nil
    end

    # =============================================
    # Attempts to determine the error field given
    # an error message
    # @param String text
    # @return Symbol|nil field
    # =============================================
    def getFieldFromText(text)
      if text.nil?
        return nil
      end

      ERROR_FIELD_REGEXES.each do |regex|
        field_match = text.match(regex)
        if !field_match.nil?
          field = field_match[1]

          if ERROR_FIELDS.keys.include? field
            return ERROR_FIELDS[field]
          end
          return field
        end
      end

      return nil
    end

  end
end
