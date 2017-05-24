class AnotherOrder < ActiveRecord::Base
  self.table_name = 'orders'

  belongs_to :user
  # belongs_to :shop, polymorphic: true

  has_one :image

  has_many :line_items
  has_many :items, through: :line_items

  validates :address, presence: true

  track_deltas_on :address
  track_deltas_on :items,      serialize: [:name]

  track_deltas_on :user,       serialize: [:name]

  track_deltas_on :image,      serialize: [:url],
                               notify:    true

  track_deltas_on :line_items, serialize: [:quantity],
                               only:      [],
                               notify:    true
end
