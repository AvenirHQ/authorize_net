#AuthorizeNet

## Getting started

If you're going to be doing a lot of Authorize.net work, it's recommended that you make your own sandbox account.  You can register for one [here](https://developer.authorize.net/hello_world/sandbox/).  Then you can log in at [sandbox.authorize.net](https://sandbox.authorize.net).

> **NOTE:** Right when you make your account, the response page will have your API Login ID and API Transaction Key.  Save these values, because they are hard to get back if you don't save them the first time around.

Other things to know:

- DPM = Direct Post Method, this is using an html form to submit directly from the client to AuthorizeNet
- SIM = Server Integration Method, this is basically just a server sending CC info to their API directly
- CIM = Customer Information Manager, this isn't even an integration method.  This just refers to saving customer payment info on AuthorizeNet servers.
- Our v2 RRG API is going to use SIM and CIM.
- You can whitelist URLs for DPM in the AuthorizeNet settings.  Under **Transaction Format Settings**, click **Response/Receipt URLs**.
- It seems that most of the settings around DPM exist in the **Transaction Format Settings** and generally don't apply to us.
- In the AuthorizeNet settings, **MD5-Hash** is actually just a secret string that gets appended to transaction information before it gets hashed.  That hash can then be used to verify the authenticity of the AuthorizeNet server.
- There are also **Address Verification** and **Card Code Verification** in the **Security Settings** that will probably be helpful.

## Examples
Check out `examples.rb` for some quick examples.

## Interface
### AuthorizeNet::Api
To start, you'll want an `AuthorizeNet::Api` object.  The constructor takes your api authorization info.
`api = AuthorizeNet::Api.new(api_login_id, api_transaction_key, options)`.  Options may contain `:sandbox` which should be true for all sandbox requests, and `:md5_hash` which holds the optional md5_hash value that you can give to AuthorizeNet to validate transactions.

Then you can start using the below methods to interact with Authorize.net

### methods
- **chargeCard**
  - params:
    - `amount` (String/Number)
    - `credit_card` (AuthorizeNet::CreditCard)
    - `billing_address` (AuthorizeNet::Address) *optional*
  - returns:
    - AuthorizeNet::Transaction
- **chargeAndCreateProfile**
  - params:
    - `amount` (String/Number)
    - `customer_profile` (AuthorizeNet::CustomerProfile)
  - returns:
    - `transaction` (AuthorizeNet::Transaction)
    - `customer_profile_id`
    - `payment_profile_id`
- **chargeProfile**
  - params:
    - `amount` (String/Number)
    - `customer_profile_id` (String/Number)
    - `payment_profile_id` (String/Number)
  - returns:
    - AuthorizeNet::Transaction
- **createCustomerProfile**
  - params:
    - `customer_profile` (AuthorizeNet::CustomerProfile)
    - `validation_mode` (AuthorizeNet::ValidationMode::) *optional*
  - returns:
    - `customer_profile_id`
    - `payment_profile_id`
- **createPaymentProfile**
  - params:
    - `customer_profile_id` (String/Number)
    - `payment_profile` (AuthorizeNet::PaymentProfile)
    - `validation_mode` (AuthorizeNet::ValidationMode::) *optional*
  - returns:
    - `customer_profile_id`
    - `payment_profile_id`
- **deletePaymentProfile**
  - params:
    - `customer_profile_id` (String/Number)
    - `payment_profile_id` (String/Number)
  - returns:
    - true if successful
- **validatePaymentProfile**
  - params:
    - `customer_profile_id` (String/Number)
    - `payment_profile_id` (String/Number)
    - `validation_mode` (AuthorizeNet::ValidationMode::)
  - returns:
    - true if successful
- **getCustomerProfile**
  - params:
    - `customer_profile_id` (String/Number)
  - returns:
    - AuthorizeNet::CustomerProfile
- **getTransactionInfo**
  - params:
    - `transaction_id` (String/Number)
  - returns:
    - AuthorizeNet::Transaction


## Data Objects
- **AuthorizeNet::CreditCard**
  - `:card_num`
  - `:expiration`
  - `:security_code`
- **AuthorizeNet::Address**
  - `:first_name`
  - `:last_name`
  - `:company`
  - `:address`
  - `:city`
  - `:state`
  - `:zip`
  - `:country`
  - `:phone`
  - `:fax`
- **AuthorizeNet::PaymentProfile**
  - `:id`
  - `:credit_card` (AuthorizeNet::CreditCard)
  - `:billing_address` (AuthorizeNet::BillingAddress)
- **AuthorizeNet::CustomerProfile**
  - `:id`
  - `:merchant_id`
  - `:email`
  - `:description`
  - `:payment_profiles` (Array[AuthorizeNet::PaymentProfiles])
- **AuthorizeNet::Transaction**
  - `:id`
  - `:timestamp_local`
  - `:timestamp_utc`
  - `:type`
  - `:status`
  - `:account_num`
  - `:account_type`
  - `:auth_code`
  - `:credit_card` (AuthorizeNet::CreditCard)
  - `:customer_profile` (AuthorizeNet::CustomerProfile)
  - `:billing_address` (AuthorizeNet::BillingAddress)


## Logging
`AuthorizeNet::Api` has a method `setLogger(logger)` that allows you to add custom logging to the requests.  The Api looks for a few *optional* methods on the logger object.

### Methods
- `logger.info(string)` logs basic request info and response info
- `logger.error(string)` logs any errors returned by the AuthorizeNet Api
- `logger.logHttpResponse(Net::HTTP::Response)` allows for custom response logging

Additionally, if you want to log the full XML for every request, you can call `AuthorizeNet::Api.setLogFullRequest(true)`


## Error Handling
Any errors received from AuthorizeNet are thrown as `AuthorizeNet::Exception`.

### AuthorizeNet::Exception
Exceptions contain an array of errors in the field `:errors`.  Errors are hashes with four keys: `code`, `text`, `type`, and `field`.  `code` and `text` are passed through straight from Authorize.net and will always be populated. `type` and `field` are generated by this gem, and may be blank if they cannot be determined.  If you encounter an error with no type or field, feel free to send it to me (jonathanvkoh@gmail.com) and I will try and incorporate it into the error handler.


## Sending Custom Requests
To send custom requests you can use the AuthorizeNet::Request class.

### AuthorizeNet::Request
Coming Soon

