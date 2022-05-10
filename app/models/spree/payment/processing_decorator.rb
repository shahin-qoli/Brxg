module Spree::Payment::ProcessingDecorator

  def capture!(amount = nil)
    return true if completed?

        started_processing!
        money = ::Money.new(amount, currency)
        capture_events.create!(amount: money.to_f)
        split_uncaptured_amount

    end
  end
end
Spree::Payment.include(Spree::Payment::ProcessingDecorator)