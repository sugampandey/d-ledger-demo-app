# == Schema Information
#
# Table name: accounting_classes
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  docyt_id   :integer
#  odoo_id    :integer
#
class AccountingClass < ActiveRecord::Base
end
