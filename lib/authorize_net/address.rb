require 'authorize_net/data_object'

class AuthorizeNet::Address < AuthorizeNet::DataObject

  ATTRIBUTES = {
    :first_name => {:key => "firstName"},
    :last_name => {:key => "lastName"},
    :company => nil,
    :address => nil,
    :city => nil,
    :state => nil,
    :zip => nil,
    :country => nil,
    :phone => nil,
    :fax => nil,
  }

  self::ATTRIBUTES.keys.each do |attr|
    attr_accessor attr
  end

end
