class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.integer :odoo_id
      t.integer :docyt_id

      t.timestamps null: false
    end
  end
end
