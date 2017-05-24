require 'spec_helper'

describe 'controller', type: :request do
  before do
    Delta.config.controller_profile_method = :current_user
  end

  let(:user) { User.create }
  let!(:order) { Order.create address: 'Address', user: user }

  it 'tracks current_user in controller' do
    expect do
      post '/orders/update_address'
    end.to change(order.deltas, :count).by(1)

    expect(order.deltas.last.profile).to eq User.last
    pp order.deltas
  end
end
