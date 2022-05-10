module Spree
    class PaymentRequest < ActiveRecord::Base
    	belongs_to :payment, class_name: 'Spree::Payment'
    end	 
end    
