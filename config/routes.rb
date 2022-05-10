Spree::Core::Engine.add_routes do
   get '/bankpayment/:reqid/:payid/:type', :to => "checkoutwithbrx#getandverify", :as => :get_verify
end

 /bankpayment/{reqid}/{payid}/{type}