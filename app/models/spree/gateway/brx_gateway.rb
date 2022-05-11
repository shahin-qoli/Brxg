module Spree
  class Gateway::BrxGateway < Gateway
    def provider_class
      Spree::Gateway::BrxGateway
    end
    def auto_capture?
      true
    end  
    """
    def payment_source_class
      Spree::CreditCard
    end
    """
    
    def method_type
      'brx'
    end

    def purchase(amount, ordr_id)
        request_url  = 'https://shop.burux.com/api/PaymentService/Request'
        response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
                 :Type => 'Inv', 
                 :Price => amount, 
                 :Model => '{PaymentTitle:"first try"}', 
                 :CallbackAction => 'RedirectToUrl',
                 :ForceRedirectBank => 'true',
                 :CallbackUrl => 'https://localhost:4000/bankpayment/{reqid}/{payid}/{type}',
               }.to_json,
       :headers => { 'Content-Type' => 'application/json' }})
       response_object = JSON.parse(response.body)
      
        payment_url = response_object['InvoiceUrl']
        request_id = response_object['RequestID']
        Spree::BrxExpressCheckout.create({
        request_id: request_id,  #53593b29-81c2-4f4b-afa3-a2d96a32c92c
        amount: amount, 
        order_id: order_id
          })      
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new  
        return payment_url
    end   

  
  end  
end
