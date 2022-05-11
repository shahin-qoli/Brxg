module Spree::PaymentDecorator


  def capture!(amount = nil) 
      return true if completed?
      started_processing!
      money = ::Money.new(@amount_brx, currency)
      capture_events.create!(amount: money.to_f)
      split_uncaptured_amount
  end
end
Spree::Payment.prepend(Spree::PaymentDecorator)