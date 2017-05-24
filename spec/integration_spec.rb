require 'spec_helper'
require 'ap'

describe 'Integration test' do
  let(:user)   { User.create(name: 'user') }
  let(:items)  { [0, 1].map { |i| Item.create name: "Item #{i}" } }

  let(:last_delta_by_name) do
    ->(order, name){
      order.deltas.last.object.select do |o|
        o['name'] == name
      end.last['object']
    }
  end

  context 'track deltas' do
    let!(:order) { Order.create(address: 'Address', items: items, user: user) }
    let!(:empty_order) { Order.create address: 'addr' }


    context 'attributes' do
      it 'tracks arrtibute change' do
        addr = 'new address'
        expect { order.update(address: addr) }
          .to change(order.deltas, :count).by(1)

        expect(last_delta_by_name[order, 'address']).to eq(addr)
      end
    end

    context 'has_many associations' do
      context 'add' do
        it 'tracks has_many through association add' do
          item = Item.create(name: 'New item')

          expect { order.items << item }
            .to change { order.reload.deltas.count }.by(1)

          expect(last_delta_by_name[order, 'items']).to eq({ 'id' => item.id })
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
          .to eq({ 'id' => order.image.id })
      end

      it 'tracks has_one association added by create_assoc' do
        expect {
          order.create_image url: 'whatever'
        }.to change(order.deltas, :count).by 1

        expect(last_delta_by_name[order, 'image'])
          .to eq({ 'id' => order.image.id })
      end

      # it 'tracks has_one association added by build_assoc' do
      #   expect {
      #     order.build_image url: 'whatever'
      #   }.not_to change(order.deltas, :count)

      #   ap order.deltas_cache

      #   expect { order.save }.to change(order.deltas, :count).by(1)
      # end
    end

    context 'belongs_to' do
      it 'tracks belongs_to associations' do
        user = User.create(name: 'New user')

        expect { order.update user: user }
          .to change(order.deltas, :count).by 1

        expect(last_delta_by_name[order, 'user']).to eq({ 'id' => user.id })
      end
    end

    it 'tracks deltas after failed validation' do
      o = Order.create(address: 'addr', items: items, user: user)

      o.address = nil
      o.user    = User.create(name: 'new user')

      expect { o.save }.not_to change(o.deltas, :count)

      o.address = 'new address'
      expect { o.save }.to change(o.deltas, :count).by(1)

      expect(o.deltas.last.object.map {|o| o['name'] } )
        .to contain_exactly('address', 'user')
    end
  end

  context 'track deltas on' do
    let!(:order) { AnotherOrder.create(address: 'Address', items: items, user: user) }
    # let!(:empty_order) { AnotherOrder.create address: "addr" }

    context 'has_many' do
      it 'tracks and serializes association' do
        item = Item.create(name: 'New item')

        expect { order.items << item }
          .to change { order.reload.deltas.count }.by(1)

        expect(last_delta_by_name[order, 'items'])
          .to eq({ 'id' => item.id, 'name' => item.name })
      end
    end

    context 'has_one' do
      it 'tracks has_one association' do
        expect {
          order.image = Image.create(url: 'whatever')
        }.to change(order.deltas, :count).by 1

        expect(last_delta_by_name[order, 'image'])
          .to eq({ 'id' => order.image.id, 'url' => order.image.url })
      end
    end

    context 'belongs_to' do
      it 'tracks belongs_to associations' do
        user = User.create(name: 'New user')

        expect { order.update user: user }
          .to change(order.deltas, :count).by 1

        expect(last_delta_by_name[order, 'user'])
          .to eq({ 'id' => user.id, 'name' => user.name })
      end
    end

    context 'association changes' do
      it 'tracks change of has_many assoc' do
        order.items << Item.create(name: 'Item')

        li = order.line_items.first

        expect {
          li.update quantity: 2
        }.to change(order.deltas, :count).by 1

        expect(last_delta_by_name[order, 'line_items'])
          .to eq({ 'id' => li.id, 'quantity' => 2})
      end

      it 'tracks change of has_one assoc' do
        i = Image.create(url: 'sample')
        order.image = i

        expect {
          i.update url: 'new_url'
        }.to change(order.deltas, :count).by 1

        expect(last_delta_by_name[order, 'image'])
          .to eq({ 'id' => i.id, 'url' => 'new_url' })
      end

    end
  end
end
