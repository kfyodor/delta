class CreateDeltas < ActiveRecord::Migration
  def change
    create_table :deltas do |t|
      # TODO: custom users key name
      t.references :user, index: true, foreign_key: true
      t.references :model, index: true, polymorphic: true
      t.json       :delta, null: false

      t.timestamp  :created_at
    end
  end
end
