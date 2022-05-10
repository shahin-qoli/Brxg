class CreateSpreeBrxExpressCheckouts < SpreeExtension::Migration[6.0]
  def change
    create_table :spree_brx_express_checkouts do |t|
      t.string :request_id
      t.string :amount
      t.string :order_id

      t.timestamps
    end
  end
end
