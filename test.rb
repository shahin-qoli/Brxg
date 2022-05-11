require 'httparty'
require 'json'
    def verify_payment?
      output = {}
      @amount = 10000
      request_url  = 'https://shop.burux.com/api/PaymentService/Verify'
      options = {
  headers: {
    "Content-Type": "application/json",
  },

  body: [{ "RequestID": "3a5f7594-27e0-45f8-b092-11a0370f8459", "Price": "10000" }].to_json
}     
     
      response = HTTParty.post(request_url, options)
      puts response.code
      response_object = JSON.parse(response.body.tr('[]',''))             
      if response_object['IsSuccess'] == false
         true
      end  
    end


if verify_payment?
   puts "on"
  
end                

