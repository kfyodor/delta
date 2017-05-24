require 'spec_helper'

describe Delta do
  it 'has config' do
    expect(Delta.config).to be_instance_of(Delta::Config)
  end

  it 'is configurable' do
    Delta.configure do |c|
      c.controller_profile_method = :current_admin
    end

    expect(Delta.config.controller_profile_method)
      .to eq(:current_admin)

    Delta.class_eval { @@config = Delta::Config.new }
  end

  it 'current_user is thread-safe' do
    t1 = Thread.new do
      Delta.set_current_profile_proc ->{ :current_user_1 }
      sleep 0.2
      expect(Delta.current_profile).to eq :current_user_1
    end

    t2 = Thread.new do
      sleep 0.1
      Delta.set_current_profile_proc ->{ :current_user_2 }
      expect(Delta.current_profile).to eq :current_user_2
    end

    [t1, t2].map &:join

    expect(Delta.current_profile).to eq nil
  end
end
