require 'spree_extension/migration'

class CreateSpreeBrxPayments < SpreeExtension::Migration[6.1]
  def change
    create_table :spree_brx_payments do |t|
      t.string :request_id
      t.string :amount
      t.string :order_id

      t.timestamps
    end
  end
end
