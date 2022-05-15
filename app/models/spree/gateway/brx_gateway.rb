
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

    def getandverify
      payment = @order.payments.last
      @request_id_brx = params['reqid']
      @checkout_brx = Spree::BrxExpressCheckout.find_by request_id: @request_id_brx 
      if @checkout_brx.nil?
          redirect_to "" 
      else    
          @amount_brx = @checkout_brx['amount']

          if @checkout_brx['order_id'] == params['order_id']
     
            if verify_payment?
               #redirect_to checkout_state_path(:payment)
               order = current_order || raise(ActiveRecord::RecordNotFound)               
               order.payments.create!({
                source: Spree::BrxExpressCheckout.create({
                  request_id: @request_id_brx,
                  amount: @amount_brx
                }), amount: @amount_brx, payment_method: payment_method
                })
          
               @order.next
               puts @order.complete?
               if @order.complete?
                  flash.notice = Spree.t(:order_processed_successfully)
                  flash[:order_completed] = true
                  session[:order_id] = nil
                  redirect_to(completion_route) and return

               else
                  redirect_to(checkout_state_path) and return
               end
            end   
          end 
      end  
    end  
    
    def get_payment_url(order_id, amount)
      output = {}
      request_url  = 'https://shop.burux.com/api/PaymentService/Request'
      response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
               :Type => 'Inv', 
               :Price => amount, 
               :Model => '{orderID: order_id}', 
               :CallbackAction => 'RedirectToUrl',
               :ForceRedirectBank => 'true',
               :CallbackUrl => 'http://bshop.burux.com/bankpayment/{reqid}/{payid}/{type}',
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
