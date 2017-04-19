require 'spec_helper'
require 'oystercard'

RSpec.describe Oystercard do
  it 'has an opening balance of zero' do
    expect(subject.balance).to eq 0
  end

  it 'can be topped-up by a stipulated amount' do
    expect { subject.top_up(10) }.to change { subject.balance }.by(10)
  end
end
