
module Spree
  class Gateway::BrxGateway < PaymentMethod
    def provider_class
      Spree::Gateway::BrxGateway
    end
    """
    def payment_source_class
      Spree::CreditCard
    end
    """
    def method_type
      'brx'
    end

    def supports?(source)
      true
    end
    def provider
      provider_class.new
    end
    def source_required?
      false
    end
    def auto_capture?
      true
    end


 """   def self.get_payment_url(order_id, amount)
      output = {}
      request_url  = 'https://shop.burux.com/api/PaymentService/Request'
      response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
               :Type => 'Inv', 
               :Price => amount, 
               :Model => '{orderID: order_id}', 
               :CallbackAction => 'RedirectToUrl',
               :ForceRedirectBank => 'true',
               :CallbackUrl => 'www.burux.ir',
             }.to_json,
      :headers => { 'Content-Type' => 'application/json' }})
      response_object = JSON.parse(response.body)
      output[:payment_url] = response_object['InvoiceUrl']
      output[:request_id] = response_object['RequestID']
      Spree::BrxExpressCheckout.create({
          request_id: output[:request_id],  #53593b29-81c2-4f4b-afa3-a2d96a32c92c
          amount: amount, 
          order_id: order_id
        })
      return output[:payment_url]
    end """

    def get_payment_url(order_id, amount)
      output = {}
      request_url  = 'https://shop.burux.com/api/PaymentService/Request'
      response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
               :Type => 'Inv', 
               :Price => amount, 
               :Model => '{orderID: order_id}', 
               :CallbackAction => 'RedirectToUrl',
               :ForceRedirectBank => 'true',
               :CallbackUrl => 'www.burux.ir',
             }.to_json,
      :headers => { 'Content-Type' => 'application/json' }})
      response_object = JSON.parse(response.body)
      output[:payment_url] = response_object['InvoiceUrl']
      output[:request_id] = response_object['RequestID']
      Spree::BrxExpressCheckout.create({
          request_id: output[:request_id],  #53593b29-81c2-4f4b-afa3-a2d96a32c92c
          amount: amount, 
          order_id: order_id
        })
      return output[:payment_url]
    end 

  end  
end
