require 'authorize_net/data_object'
require 'authorize_net/address'
require 'authorize_net/customer_profile'
require 'authorize_net/credit_card'
require 'authorize_net/util'

class AuthorizeNet::Transaction < AuthorizeNet::DataObject

  ATTRIBUTES = {
    :id => {:key => "transId"},
    :timestamp_local => {:key => "submitTimeLocal"},
    :timestamp_utc => {:key => "submitTimeUTC"},
    :type => {:key => "transactionType"},
    :status => {:key => "transactionStatus"},
    :account_num => {:key => "accountNumber"},
    :account_type => {:key => "accountType"},
    :auth_code => {:key => "authCode"},
    :credit_card => {
      :key => "creditCard",
      :type => AuthorizeNet::DataObject::TYPE_OBJECT,
      :class => AuthorizeNet::CreditCard,
    },
    :customer_profile => {
      :key => "customer",
      :type => AuthorizeNet::DataObject::TYPE_OBJECT,
      :class => AuthorizeNet::CustomerProfile,
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

  def parse(xml)
    super

    merchant_id = AuthorizeNet::Util.getXmlValue(xml, 'customer id')
    if !merchant_id.nil?
      @customer_profile ||= AuthorizeNet::CustomerProfile.new
      @customer_profile.merchant_id = merchant_id
    end
  end

end
