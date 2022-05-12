
module Spree
  module Gateway::BrxGateway < PaymentMethod
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

    def purchase(amount, transaction_details, options = {})
      ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
    end
  end  
end
