require 'authorize_net/data_object'

class AuthorizeNet::CreditCard < AuthorizeNet::DataObject

  ATTRIBUTES = {
    :card_num => {:key => "cardNumber"},
    :expiration => {:key => "expirationDate"},
    :security_code => {:key => "cardCode"},
    :card_type => {:key => "cardType"},
  }

  self::ATTRIBUTES.keys.each do |attr|
    attr_accessor attr
  end

end
