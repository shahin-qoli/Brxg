module Spree
  class BrxController < StoreController
    def verify_payment?
      request_url  = 'https://shop.burux.com/api/PaymentService/Verify'
      options = {
  headers: {
    "Content-Type": "application/json",
  },

  body: [{ "RequestID": @request_id_brx, "Price": @amount_brx }].to_json
}     
     
      response = HTTParty.post(request_url, options)

      response_object = JSON.parse(response.body.tr('[]',''))
      if response_object['IsSuccess'] == false
        true
      end  
    end

    def geturl()
      output = {}
      order_id = params['orderid']
      amount = params['amount']
      request_url  = 'https://shop.burux.com/api/PaymentService/Request'
      response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
               :Type => 'Inv', 
               :Price => amount, 
               :Model => '{orderID: order_id}', 
               :CallbackAction => 'RedirectToUrl',
               :ForceRedirectBank => 'true',
               :CallbackUrl => 'localhost:4000/bankpayment/{reqid}/{payid}/{type}',
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
      render json: {"payment_url": output[:payment_url]}
    end 
    def completion_route(custom_params = {})
      spree.order_path(@order, custom_params.merge(locale: locale_param))
    end

    def payment_method
      Spree::PaymentMethod.find(3)
    end 

    def getandverify
      @request_id_brx = params['reqid']
      @checkout_brx = Spree::BrxExpressCheckout.find_by request_id: @request_id_brx 
      order_id = @checkout_brx['order_id']
      if order_id.nil?
        redirect_to 'burux.ir'
      end  
      #@order = Spree::Order.find(order_id)
      #payment = @order.payments.last
      if @checkout_brx.nil?
          redirect_to "https://burux.com/" 
      else    
          @amount_brx = @checkout_brx['amount']

        #  if @checkout_brx['order_id'] == params['order_id']
     
          if verify_payment?
               redirect_to checkout_state_path(:payment)
               order = current_order || raise(ActiveRecord::RecordNotFound)               
               @order.payments.create!({
                source: Spree::BrxExpressCheckout.create({
                  request_id: @request_id_brx,
                  amount: @amount_brx
                }), amount: @amount_brx, payment_method: payment_method
                })
          
               @order.next
               #puts @order.complete?
               if @order.complete?
                  flash.notice = Spree.t(:order_processed_successfully)
                  flash[:order_completed] = true
                  session[:order_id] = nil
                  redirect_to(completion_route) and return

               else
                  redirect_to(checkout_state_path) and return
               end
          end   
         # end 
      end  
    end   
  end
end    