require 'spec_helper'

describe 'controller', type: :request do
  let!(:order) { Order.create address: "Address" }

  it 'tracks current_user in controller' do
    expect do
      post "/orders/update_address"
    end.to change(order.deltas, :count).by(1)

    expect(order.deltas.last.user).to eq User.last
  end
end
