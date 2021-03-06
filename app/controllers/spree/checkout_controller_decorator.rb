require 'httparty'
require 'json'

module Spree
  module CheckoutWithBrx


    # If we're currently in the checkout
    def update
      if payment_params_valid? && paying_with_brx?
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          payment = @order.payments.last
          #mollie_payment_url = "https://burux.ir/"
          
          #MollieLogger.debug("For order #{@order.number} redirect user to payment URL: #{payment_url}")
          brx = Spree::PaymentMethod.find_by_type 'Spree::Gateway::BrxGateway'
          payment_url= brx.get_payment_url(order_id= @order.id, amount= @order.amount)
          #payment_url = request_api[:payment_url]
          puts "hereeeeeeeeeeeeeeeeee"
          puts params['order_id']
          redirect_to payment_url
        else
          render :edit
        end
      else
        super
      end
    end

    def getandverify
      @request_id_brx = params['reqid']
      @checkout_brx = Spree::BrxExpressCheckout.find_by request_id: @request_id_brx 
      if @checkout_brx.nil?
          redirect_to "" 
      else    
          @amount_brx = @checkout_brx['amount']
   
          if @checkout_brx['order_id'] == params['order_id']
            #started_processing!
            if verify_payment?
               #redirect_to checkout_state_path(:payment)
               """
               order = current_order || raise(ActiveRecord::RecordNotFound)               
               @order.payments.create!({
                source: Spree::BrxExpressCheckout.create({
                  request_id: @request_id_brx,
                  amount: @amount_brx
                }), amount: @amount_brx, payment_method: payment_method
                })
               """
               puts @order.complete?
               #payment = @order.payments.last
               #payment.capture! 
               #payment.complete!
               @order.next
               puts @order.complete?
               if @order.complete?
                  payment = @order.payments.last
                  payment.complete!
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
 

    def cleanup string
      string.titleize
    end

    def payment_method
      #order = current_order || raise(ActiveRecord::RecordNotFound)
      #payment_method_id = PaymentMethod.find(payment_method_id_param)  #Spree::Payment[:payment_method_id_param]      
      #Spree::Gateway::BrxGateway
      Spree::PaymentMethod.find(3)
    end  


    def verify_payment?
      request_url  = 'https://shop.burux.com/api/PaymentService/Verify'
      options = {
      headers: {
      "Content-Type": "application/json",
      },

      body: [{ "RequestID": @request_id_brx, "Price": @amount_brx }].to_json}     
     
      response = HTTParty.post(request_url, options)

      response_object = JSON.parse(response.body.tr('[]',''))
      if response_object['IsSuccess'] == true
        true
      end  
    end

  end
  module CheckoutControllerDecorator

    def payment_method_id_param
      params[:order][:payments_attributes].first[:payment_method_id]
    end

    def paying_with_brx?
      payment_method = PaymentMethod.find(payment_method_id_param)
      payment_method.is_a? Gateway::BrxGateway
    end

    def payment_params_valid?
      (params[:state] === 'payment') && params[:order][:payments_attributes]
    end
  end

end

Spree::CheckoutController.prepend(Spree::CheckoutWithBrx)
Spree::CheckoutController.prepend(Spree::CheckoutControllerDecorator)