module Spree
    class PaymentRequest < Spree::Base
    	blongs_to :payment, class_name: 'Spree::Payment'
    end	 
end    