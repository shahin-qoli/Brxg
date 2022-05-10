Spree::Core::Engine.add_routes do
   get '/?action=bankpayment&reqid={reqid}&payid={payid}&paytyp={type}', :to => "CheckoutWithBrx#getandverify", :as => :get_verify
end

 