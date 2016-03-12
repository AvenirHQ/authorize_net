require 'authorize_net'

### FILL THESE OUT BEFORE TRYING EXAMPLES ###
api_login_id = "YOUR API LOGIN ID"
api_transaction_key = "YOUR API TRANSACTION KEY"

# First things first, we need to make an API object
# The third argument specifies whether or not to use the sandbox API
api = AuthorizeNet::Api.new(api_login_id, api_transaction_key, true)

#+=====================================
# 0) Logging (optional)
#+=====================================
# Super basic logger to see what's going on
# Having a logger is totally optional
class Logger
  def info(s)
    puts "[info] #{s}"
  end

  def error(s)
    puts "[error] #{s}"
  end
end

api.setLogger(Logger.new)


#+=====================================
# 1) One-off credit card charges
#+=====================================
puts "=== Credit Card Charge Response ==="

# Make a credit card object
cc = AuthorizeNet::CreditCard.new
cc.card_num = '4012888888881881' # Random Visa Number
cc.expiration = '0922'
cc.security_code = '605'
# Use that credit card object to make a charge through the API
# Here we're charging 1 cent

begin
  transaction = api.chargeCard(0.07, cc)
  puts transaction.id
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end

# You also have the option of sending a billing address
address = AuthorizeNet::Address.new
address.first_name = "Rick"
address.last_name = "Sanchez"
address.address = '123 Eastern Parkway'
address.city = 'Brooklyn'
address.state = 'NY'
address.country = 'USA'
address.zip = '11216'

begin
  transaction2 = api.chargeCard(0.13, cc, address)
  puts transaction2.id
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end



#+=====================================
# 2) Making a CustomerProfile
#+=====================================
puts "\n\n=== Making a Customer Profile ==="

# We can also store payment data in a profile that we
# can charge multiple times. to do this we need to make
# a CustomerProfile with at least one PaymentProfile

# A PaymentProfile is just a credit card and an address
# Here we're just using our existing objects
payment_profile = AuthorizeNet::PaymentProfile.new
payment_profile.credit_card = cc
payment_profile.billing_address = address

# Then we need to add that payment profile to a CustomerProfile
# CustomerProfiles have a few identifying fields:
#   merchant_id, email, description
# You are required to fill out at least one of those fields.
# Here we're using email
customer_profile = AuthorizeNet::CustomerProfile.new
customer_profile.email = "fake@email.com"
customer_profile.payment_profiles.push(payment_profile)

begin
  response = api.createCustomerProfile(customer_profile)
  puts response
  customer_profile_id = response["customer_profile_id"]
  payment_profile_id = response["payment_profile_id"]
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end


#+=====================================
# 3) Charging a PaymentProfile
#+=====================================
puts "\n\n=== Charging a Payment Profile ==="

# Charging a payment profile is as easy as passing in
# the charge amount with a valid customer_profile_id
# and payment_profile_id pair,
begin
  transaction3 = api.chargeProfile(0.17, customer_profile_id, payment_profile_id)
  puts transaction3.id
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end


#+=====================================
# 4) Adding a PaymentProfile
#+=====================================
puts "\n\n=== Adding a Payment Profile ==="

# A CustomerProfile can have multiple PaymentProfiles
# Let's add another one to our CustomerProfile
# First we need another Credit Card
cc2 = AuthorizeNet::CreditCard.new
cc2.card_num = '371449635398431' # Random Amex Number
cc2.expiration = '1221'
cc2.security_code = '5544'

# It's not totally clear to me how this is possible,
# but it seems that AuthorizeNet doesn't always require
# a billing address.  Let's ignore that for now
payment_profile2 = AuthorizeNet::PaymentProfile.new
payment_profile2.credit_card = cc2

begin
  response = api.createPaymentProfile(customer_profile_id, payment_profile2)
  puts response
  payment_profile_id2 = response["payment_profile_id"]
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end


#+=====================================
# 5) Getting a CustomerProfile
#+=====================================
puts "\n\n=== Getting a Customer Profile ==="
# getCustomerProfile returns an AuthorizeNet::CustomerProfile object

begin
  customer_profile = api.getCustomerProfile(customer_profile_id)
  puts customer_profile.to_h
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end


#+=====================================
# 6) Deleting a PaymentProfile
#+=====================================
puts "\n\n=== Deleting a Payment Profile ==="

begin
  # return value is kind of redundant, since unsuccessful requests throw errors
  is_successful = api.deletePaymentProfile(customer_profile_id, payment_profile_id)
  puts "Successful delete: #{is_successful}"
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end

#+=====================================
# 7) Getting a Transaction
#+=====================================
puts "\n\n=== Getting a Transaction ==="
# getTransactionInfo returns an AuthorizeNet::Transaction object
begin
  transaction2 = api.getTransactionInfo(transaction2.id)
  puts transaction2.to_h
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end

puts "\n"

begin
  transaction3 = api.getTransactionInfo(transaction3.id)
  puts transaction3.to_h
rescue AuthorizeNet::Exception => e
  e.errors.each do |error|
    puts error
  end
end
