ActiveRecord::Schema.define(version: 1) do
  create_table :orders, force: :cascade do |t|
    t.integer :user_id
    t.string :address
    t.timestamps null: false
  end

  create_table :users, force: :cascade do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :items, force: :cascade do |t|
    t.string :name
    t.timestamps null: false
  end

  create_table :images, force: :cascade do |t|
    t.string :url
    t.integer :order_id
    t.integer :another_order_id
    t.timestamps null: false
  end

  create_table :line_items, force: :cascade do |t|
    t.integer :order_id
    t.integer :quantity, default: 1
    t.integer :another_order_id
    t.integer :item_id
    t.timestamps null: false
  end
end
