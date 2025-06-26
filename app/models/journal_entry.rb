# == Schema Information
#
# Table name: journal_entries
#
#  id          :integer          not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  docyt_id    :integer
#  odoo_id     :integer
#
class JournalEntry < ActiveRecord::Base
end
