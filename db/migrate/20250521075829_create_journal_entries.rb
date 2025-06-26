class CreateJournalEntries < ActiveRecord::Migration
  def change
    create_table :journal_entries do |t|
      t.string :description
      t.integer :odoo_id
      t.integer :docyt_id

      t.timestamps null: false
    end
  end
end
