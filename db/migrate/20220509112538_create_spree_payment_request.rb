require 'spree_extension/migration'

class CreateSpreePaymentRequest < SpreeExtension::Migration[6.1]
  def change
    create_table :spree_payment_requests do |t|
      t.belongs_to :order, index: { unique: true }, null: false
      t.string :requestid
      t.string :amount

      t.timestamps
    end
  end
end
