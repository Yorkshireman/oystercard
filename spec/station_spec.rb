require 'spec_helper'
require 'station'

RSpec.describe 'Station' do
  it 'has a name' do
    expect(Station.new('foo').name).to eq 'foo'
  end
end
