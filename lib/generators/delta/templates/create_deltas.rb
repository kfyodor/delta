class CreateDeltas < ActiveRecord::Migration
  def change
    create_table :deltas, force: :cascade do |t|
      # TODO: custom users key name
      t.integer :profile_id
      t.string :profile_type
      t.references :model, index: true, polymorphic: true
      t.json       :object, null: false # TODO -> text if JSON is not supported

      t.timestamp  :created_at
    end

    add_index :deltas, %i[profile_id profile_type]
  end
end
