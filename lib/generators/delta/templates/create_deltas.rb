class CreateDeltas < ActiveRecord::Migration
  def change
    create_table :deltas, force: :cascade do |t|
      # TODO: custom users key name
      t.references :user, index: true, foreign_key: true
      t.references :model, index: true, polymorphic: true
      t.json       :object, null: false # TODO -> text if JSON is not supported

      t.timestamp  :created_at
    end
  end
end
