module Spree::Payment::ProcessingDecorator

  def capture!(amount = nil)
      started_processing!
      money = ::Money.new(@amount_brx, currency)
      capture_events.create!(amount: money.to_f)
      split_uncaptured_amount
  end
end
Spree::Payment::Processing.prepend(Spree::Payment::ProcessingDecorator)