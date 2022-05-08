module Spree::Payment::ProcessingDecorator

  """
  def process!
    if payment_method.is_a? Spree::Gateway::BrxGateway
      redirec
    else
      super
  end
   
  def process_with_brx
    amount ||= money.money
    started_processing!
    response = payment_method.process(
      amount,
      source,
      gateway_options
    )
    handle_response(response, :started_processing, :failure)
  end
    
  """ 
end
Spree::Payment.include(Spree::Payment::ProcessingDecorator)