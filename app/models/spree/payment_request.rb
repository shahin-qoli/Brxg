module Spree
    class PaymentRequest < Spree::Base
    	belongs_to :payment, class_name: 'Spree::Payment'
    end	 
end    
