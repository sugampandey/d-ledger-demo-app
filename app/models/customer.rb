# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  docyt_id   :integer
#  odoo_id    :integer
#
class Customer < ActiveRecord::Base
end
