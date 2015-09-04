class Item < ActiveRecord::Base
  belongs_to :line_item, touch: true
  has_one :order, through: :line_item
  has_one :another_order, through: :line_item
end
