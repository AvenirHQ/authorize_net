require 'authorize_net/data_object'
require 'authorize_net/payment_profile'

class AuthorizeNet::CustomerProfile < AuthorizeNet::DataObject

  ATTRIBUTES = {
    :id => {:key => "customerProfileId"},
    :merchant_id => {:key => "merchantCustomerId"},
    :email => nil,
    :description => nil,
    :payment_profiles => {
      :key => "paymentProfiles",
      :type => AuthorizeNet::DataObject::TYPE_OBJECT_ARRAY,
      :class => AuthorizeNet::PaymentProfile,
    },
  }

  self::ATTRIBUTES.keys.each do |attr|
    attr_accessor attr
  end

  def initialize
    @payment_profiles = []
  end

end
