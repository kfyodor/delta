require 'spec_helper'

describe Delta do
  it 'has a version number' do
    expect(Delta::VERSION).not_to be nil
  end

  it "current_user is thread-safe" do
    t1 = Thread.new do
      Delta.current_user = :current_user_1
      sleep 2
      expect(Delta.current_user).to eq :current_user_1
    end

    t2 = Thread.new do
      Delta.current_user = :current_user_2
      expect(Delta.current_user).to eq :current_user_2
    end

    [t1, t2].map &:join

    expect(Delta.current_user).to eq nil
  end
end
