
module Spree
  class Gateway::BrxGateway < Gateway
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
    def auto_capture?
      true
    end
    def purchase(amount, transaction_details, options = {})
      ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
    end
  end  
end
