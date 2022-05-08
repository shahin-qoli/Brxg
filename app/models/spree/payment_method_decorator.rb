module Spree::PaymentMethodDecorator
  def source_required?
    false
  end
end

Spree::PaymentMethod.prepend(Spree::PaymentMethodDecorator)    
