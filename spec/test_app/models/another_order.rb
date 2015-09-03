class AnotherOrder < ActiveRecord::Base
  self.table_name = "orders"

  belongs_to :user
  # belongs_to :shop, polymorphic: true

  has_one :image, foreign_key: 'order_id'

  has_many :line_items, foreign_key: 'order_id'
  has_many :items, through: :line_items

  validates :address, presence: true

  track_deltas_on :address
  track_deltas_on :items, serialize: [:name]
  track_deltas_on :user,  serialize: [:name]
  track_deltas_on :image, serialize: [:url]
end
