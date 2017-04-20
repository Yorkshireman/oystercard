require 'spec_helper'
require 'oystercard'
# rubocop:disable Metrics/BlockLength
# rubocop:disable LineLength
RSpec.describe Oystercard do
  describe 'defaults' do
    it 'has an opening balance of zero' do
      expect(subject.balance).to eq 0
    end

    it 'has an opening \'in_journey\' status of \'false\'' do
      expect(subject.in_journey).to eq false
    end
  end

  describe '#top_up' do
    it 'raises @balance by a stipulated amount' do
      expect { subject.top_up(10) }.to change { subject.balance }.by(10)
    end

    context 'when maximum balance would be exceeded' do
      it 'raises ArgumentError with an appropriate message' do
        expect { subject.top_up(91) }.to raise_error(
          ArgumentError, "top-up of 91 would exceed maximum allowed balance of #{MAXIMUM_ALLOWED_BALANCE}"
        )
      end
    end
  end

  describe '#touch_in' do
    context 'when balance is less than MINIMUM_TOUCH_IN_BALANCE' do
      it 'raises RuntimeError with an appropriate message' do
        expect { subject.touch_in }.to raise_error(
          RuntimeError, "balance of 0 is less than minimum balance of #{MINIMUM_TOUCH_IN_BALANCE}"
        )
      end
    end

    context 'when balance is not less than MINIMUM_TOUCH_IN_BALANCE' do
      it 'sets @in_journey to true' do
        subject.balance = MINIMUM_TOUCH_IN_BALANCE
        expect { subject.touch_in }.to change { subject.in_journey }.to true
      end
    end
  end

  describe '#touch_out' do
    it 'changes @in_journey to false' do
      subject.in_journey = true
      expect { subject.touch_out }.to change { subject.in_journey }.to false
    end

    it 'deducts minimum fare' do
      subject.balance = 10
      expect { subject.touch_out }.to change { subject.balance }.by(-MINIMUM_FARE)
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable LineLength
