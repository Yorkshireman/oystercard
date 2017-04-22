require 'spec_helper'
require 'station'

RSpec.describe 'Station' do
  it 'has a name' do
    expect(Station.new('foo').name).to eq 'foo'
  end

  it 'has a zone' do
    expect(Station.new('foo', 8).zone).to eq 8
  end
end
