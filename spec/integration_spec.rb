require 'spec_helper'

describe "Integration test" do
  before(:all) do
    Order.track_deltas :address, :items, :user
  end

  let!(:order) do
    user  = User.create(name: "user")
    items = [0, 1].map { |i| Item.create name: "Item #{i}" }
    order = Order.create(address: "Address", items: items, user: user)
  end

  let(:last_delta_by_name) do
    ->(name){
      order.deltas.last.object.select do |o|
        o['name'] == name
      end.last["object"]
    }
  end

  it 'tracks arrtibute change' do
    addr = "new address"
    expect { order.update(address: addr) }
      .to change(order.deltas, :count).by(1)

    expect(last_delta_by_name['address']).to eq(addr)
  end

  it 'tracks has_many through association add' do
    item = Item.create(name: "New item")

    expect { order.items << item }
      .to change { order.reload.deltas.count }.by(1)

    expect(last_delta_by_name['items']).to eq({ "id" => item.id })
  end

  it 'tracks belongs_to associations' do
    user = User.create(name: "New user")

    expect { order.update user: user }
      .to change(order.deltas, :count).by 1

    expect(last_delta_by_name['user']).to eq({ "id" => user.id })
  end
end
