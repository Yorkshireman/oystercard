require 'spec_helper'
require 'oystercard'

RSpec.describe Oystercard do
  it 'has an opening balance of zero' do
    expect(subject.balance).to eq 0
  end

  it 'can be topped-up by a stipulated amount' do
    expect { subject.top_up(10) }.to change { subject.balance }.by(10)
  end

  it 'has a maximum balance of 90' do
    expected_message = 'top-up of 91 would exceed maximum allowed balance'
    expect { subject.top_up(91) }.to(
      raise_error(ArgumentError, expected_message)
    )
  end

  it 'can have a fare deducted from its balance' do
    subject.top_up(10)
    expect { subject.deduct(5) }.to change { subject.balance }.by(-5)
  end
end
