class Image < ActiveRecord::Base
  belongs_to :order
  belongs_to :another_order
end
