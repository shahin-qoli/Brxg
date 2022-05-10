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
          
          request_api = get_payment_url
          payment_url = request_api[:payment_url]

          Spree::BrxExpressCheckout.create({
          request_id: "f83c8ea8-6f7b-4648-b844-ea524311509d", #request_api[:request_id]
          amount: @order.amount, 
          order_id: params['order_id']
        })

          redirect_to payment_url
        else
          render :edit
        end
      else
        super
      end
    end

    def getandverify
      #param = Rack::Utils.parse_query URI(getandverify).query
      @request_id_brx = params['reqid']
      @checkout_brx = Spree::BrxExpressCheckout.find_by request_id: @request_id_brx 
      if @checkout_brx.nil?
          redirect_to "https://burux.com/" 
      else    
          @amount_brx = @checkout_brx['amount']

          if @checkout_brx['order_id'] == params['order_id']
            if verify_payment?
               @order.payment.capture!(@amount_brx)
               redirect_to completion_route
            else
               redirect_to "https://burux.ir/" 
            end   
          end 
      end  
    end    
  
    def cleanup string
      string.titleize
    end


    def verify_payment?
      output = {}
      request_url  = 'https://shop.burux.com/api/PaymentService/Verify'
      response = HTTParty.post(request_url, { :body => { :RequestID => @request_id_brx, 
               :Price => @amount_brx, 
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' }})
      response_object = JSON.parse(response.body)
      if response_object[:IsSuccess] == false
      end  
    end

    def get_payment_url
      output = {}
      request_url  = 'https://shop.burux.com/api/PaymentService/Request'
      response = HTTParty.post(request_url, { :body => { :App => 'Spree', 
               :Type => 'Inv', 
               :Price => @order.amount, 
               :Model => '{PaymentTitle:"first try"}', 
               :CallbackAction => 'RedirectToUrl',
               :ForceRedirectBank => 'true',
               :CallbackUrl => 'www.burux.ir',
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' }})
      response_object = JSON.parse(response.body)
      
      output[:payment_url] = response_object['InvoiceUrl']
      output[:request_id] = response_object['RequestID']
      return output
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