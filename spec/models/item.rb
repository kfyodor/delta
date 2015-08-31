class Item < ActiveRecord::Base
  belongs_to :line_item, touch: true
end
