require 'spec_helper'
require 'ap'

describe "Integration test" do
  before(:all) do
    Order.track_deltas :address, :items, :user, :image
  end

  let(:user)   { User.create(name: "user") }
  let(:items)  { [0, 1].map { |i| Item.create name: "Item #{i}" } }
  let!(:order) { Order.create(address: "Address", items: items, user: user) }
  let!(:empty_order) { Order.create address: "addr" }

  let(:last_delta_by_name) do
    ->(order, name){
      order.deltas.last.object.select do |o|
        o['name'] == name
      end.last["object"]
    }
  end

  context 'attributes' do
    it 'tracks arrtibute change' do
      addr = "new address"
      expect { order.update(address: addr) }
        .to change(order.deltas, :count).by(1)

      expect(last_delta_by_name[order, 'address']).to eq(addr)
    end
  end

  context 'has_many associations' do
    context 'add' do
      it 'tracks has_many through association add' do
        item = Item.create(name: "New item")

        expect { order.items << item }
          .to change { order.reload.deltas.count }.by(1)

        expect(last_delta_by_name[order, 'items']).to eq({ "id" => item.id })
      end

      it 'tracks has_many associations add via assoc_ids=' do
        expect {
          empty_order.item_ids = items.map(&:id)
        }.to change(empty_order.deltas, :count).by(items.count)
      end

      it 'tracks has_many assotiations add via assoc=' do
        expect {
          empty_order.items = items
        }.to change(empty_order.deltas, :count).by(items.count)
      end
    end

    context 'remove' do
      it 'tracks remove via delete' do
        expect do
          order.items.delete(items.first)
        end.to change(order.deltas, :count).by(1)

        expect(order.deltas.last.object[0]['action']).to eq "R"
      end

      it 'tracks remove via assoc = []' do
        expect do
          order.items = []
        end.to change(order.deltas, :count).by(2)
      end

      it 'tracks remove via assoc_ids = []' do
        expect do
          order.item_ids = []
        end.to change(order.deltas, :count).by(2)
      end
    end
  end

  context 'has_one' do
    it 'tracks has_one association' do
      expect {
        order.image = Image.create(url: 'whatever')
      }.to change(order.deltas, :count).by 1

      expect(last_delta_by_name[order, 'image'])
        .to eq({ "id" => order.image.id })
    end

    it 'tracks has_one assotiation added by create_assoc' do
      expect {
        order.create_image url: 'whatever'
      }.to change(order.deltas, :count).by 1

      expect(last_delta_by_name[order, 'image'])
        .to eq({ "id" => order.image.id })
    end
  end

  context 'belongs_to' do
    it 'tracks belongs_to associations' do
      user = User.create(name: "New user")

      expect { order.update user: user }
        .to change(order.deltas, :count).by 1

      expect(last_delta_by_name[order, 'user']).to eq({ "id" => user.id })
    end
  end

  it 'tracks deltas after failed validation' do
    o = Order.create(address: 'addr', items: items, user: user)

    o.address = nil
    o.user    = User.create(name: "new user")

    expect { o.save }.not_to change(o.deltas, :count)

    o.address = "new address"
    expect { o.save }.to change(o.deltas, :count).by(1)

    expect(o.deltas.last.object.map {|o| o['name'] } )
      .to contain_exactly("address", "user")
  end
end
