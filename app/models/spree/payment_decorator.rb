module Spree::PaymentDecorator
		extend ActiveSupport::Concern

		prepend do
			has_one :payment_request, class_name: 'Spree::PaymentRequest', dependent: :destroy
			accepts_nested_attributes_for :present_note, reject_if: :all_blank
		end
		
	    def payment_request_with_default
                    payment_request || build_payment_request
        end
end



Spree::Payment.prepend(Spree::PaymentDecorator)   
