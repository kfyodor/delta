class Order < ActiveRecord::Base
  belongs_to :user
  # belongs_to :shop, polymorphic: true
  # has_one :order_comment
  has_many :line_items
  has_many :items, through: :line_items
end
