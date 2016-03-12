require 'authorize_net/data_object'
require 'authorize_net/credit_card'
require 'authorize_net/address'

class AuthorizeNet::PaymentProfile < AuthorizeNet::DataObject

  ATTRIBUTES = {
    :id => {:key => "customerPaymentProfileId"},
    :credit_card => {
      :key => "creditCard",
      :type => AuthorizeNet::DataObject::TYPE_OBJECT,
      :class => AuthorizeNet::CreditCard,
    },
    :billing_address => {
      :key => "billTo",
      :type => AuthorizeNet::DataObject::TYPE_OBJECT,
      :class => AuthorizeNet::Address,
    },
  }

  self::ATTRIBUTES.keys.each do |attr|
    attr_accessor attr
  end

  # Override
  def to_h
    hash = super

    hash.delete('creditCard')
    if !@credit_card.nil?
      hash['payment'] = {
        'creditCard' => @credit_card.to_h
      }
    end

    return hash
  end

end
