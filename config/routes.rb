Spree::Core::Engine.add_routes do
   get '/bankpayment/:reqid/:payid/:type', :to => "checkoutcontroller#getandverify", :as => :get_verify
end

