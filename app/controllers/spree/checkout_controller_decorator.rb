require "httparty"

module Spree
  module CheckoutWithBrx
    # If we're currently in the checkout
    def update
      if payment_params_valid? && paying_with_brx?
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          payment = @order.payments.last
          payment.process!
          #mollie_payment_url = "https://burux.ir/"
          
          #MollieLogger.debug("For order #{@order.number} redirect user to payment URL: #{payment_url}")
          get_payment_url
          redirect_to payment_url
        else
          render :edit
        end
      else
        super
      end
    end

    def get_payment_url
      amount = @order.amount 
      options = { :body => 
  {
    "App":"SpreeApp",
    "Type":"INV",
    "Price":amount,
    "Model":"{PaymentTitle:'پرداخت سفارش شماره تست بابت خرید از فروشگاه ویزیتور ها'}",
    "CallbackAction":"RedirectToUrl",
    "ForceRedirectBank":"true",
    "CallbackUrl":"www.burux.ir"
  }
}
                
      results = HTTParty.post("https://shop.burux.com/api/PaymentService/Request", options)
      payment_url = results[:InvoiceUrl]
      requestID = results[:RequestID]
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

  CheckoutController.prepend(CheckoutWithBrx)
  CheckoutController.prepend(CheckoutControllerDecorator)

end