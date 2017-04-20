require 'spec_helper'
require 'oystercard'

# rubocop:disable Metrics/BlockLength
RSpec.describe Oystercard do
  describe 'defaults' do
    it 'has an opening balance of zero' do
      expect(subject.balance).to eq 0
    end

    it 'has an opening \'in_journey\' status of \'false\'' do
      expect(subject.in_journey).to eq false
    end
  end

  context 'topping-up' do
    it 'can be topped-up by a stipulated amount' do
      expect { subject.top_up(10) }.to change { subject.balance }.by(10)
    end

    it 'has a maximum balance' do
      expect { subject.top_up(91) }.to raise_error(
        # rubocop:disable LineLength
        ArgumentError, "top-up of 91 would exceed maximum allowed balance of #{MAXIMUM_ALLOWED_BALANCE}"
        # rubocop:enable LineLength
      )
    end
  end

  it 'can have a fare deducted from its balance' do
    subject.balance = 10
    expect { subject.deduct(5) }.to change { subject.balance }.by(-5)
  end

  context 'touching-in/out' do
    context 'when balance is not less than MINIMUM_TOUCH_IN_BALANCE' do
      it 'can touch-in' do
        subject.balance = MINIMUM_TOUCH_IN_BALANCE
        expect { subject.touch_in }.to change { subject.in_journey }.to true
      end
    end

    it 'can touch-out' do
      subject.in_journey = true
      expect { subject.touch_out }.to change { subject.in_journey }.to false
    end

    context 'when balance is less than MINIMUM_TOUCH_IN_BALANCE' do
      it 'refuses to touch-in' do
        expect { subject.touch_in }.to raise_error(
          # rubocop:disable LineLength
          RuntimeError, "balance of 0 is less than minimum balance of #{MINIMUM_TOUCH_IN_BALANCE}"
          # rubocop:enable LineLength
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
