class LineItem < ActiveRecord::Base
  belongs_to :order, touch: true
  belongs_to :item
end
