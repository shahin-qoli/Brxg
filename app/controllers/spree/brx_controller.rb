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
      if response_object['IsSuccess'] == true
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
      render json: {"payment_url": output[:payment_url]}
    end 
    def completion_route_brx(orderid)
      "http://172.16.4.149:3000/checkout/thank-you?order=#{orderid}"
    end

    def completion_route(order, custom_params = {})
      spree.order_path(order, custom_params.merge(locale: locale_param))
    end

    def payment_method
      Spree::PaymentMethod.find(3)
    end 

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
               #order = current_order || raise(ActiveRecord::RecordNotFound)     
               @order_id_brx = @checkout_brx['order_id']
               @order_brx = Spree::Order.find(@order_id_brx)
               @order_brx_number = @order_brx.number   
               @order_brx.payments.create!({
                source: Spree::BrxExpressCheckout.create({
                  request_id: @request_id_brx,
                  amount: @amount_brx
                }), amount: @amount_brx, payment_method: payment_method
                })      
               puts "the request id is HERE "
               puts "the request id is HERE "
               puts "the request id is HERE " 
               puts @order_brx
               puts "the request id is HERE "
               puts "the request id is HERE "
               puts "the request id is HERE "
               @order_brx.next
               puts "the request id is HERE "
               puts "the request id is HERE "
               puts "the request id is HERE "
               puts @order_brx             
               #puts @order.complete?
               if @order_brx.complete?
                  payment = @order_brx.payments.last
                  payment.complete!                
                  flash.notice = Spree.t(:order_processed_successfully)
                  flash[:order_completed] = true
                  session[:order_id] = nil
                  redirect_to(completion_route_brx(@order_brx_number)) && return

               else
                  redirect_to(checkout_state_path) && return
               end
          end   
         # end 
      end  
    end   
  end
end    