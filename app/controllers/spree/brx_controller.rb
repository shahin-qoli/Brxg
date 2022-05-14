module Spree
  class PaypalController < StoreController
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



    def getandverify(order)
      @request_id_brx = params['reqid']
      @checkout_brx = Spree::BrxExpressCheckout.find_by request_id: @request_id_brx 
      @order = @checkout_brx['order_id']
      payment = @order.payments.last
      if @checkout_brx.nil?
          redirect_to "https://burux.com/" 
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
  end
end    