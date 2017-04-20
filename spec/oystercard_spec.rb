require 'spec_helper'
require 'oystercard'
# rubocop:disable Metrics/BlockLength
# rubocop:disable LineLength
RSpec.describe Oystercard do
  describe 'defaults' do
    it 'balance is 0' do
      expect(subject.balance).to eq 0
    end

    it 'entry_station is nil' do
      expect(subject.entry_station).to be_nil
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
    let(:station) { double }

    context 'when balance is less than MINIMUM_TOUCH_IN_BALANCE' do
      it 'raises RuntimeError with an appropriate message' do
        expect { subject.touch_in(station) }.to raise_error(
          RuntimeError, "balance of 0 is less than minimum balance of #{MINIMUM_TOUCH_IN_BALANCE}"
        )
      end
    end

    context 'when balance is not less than MINIMUM_TOUCH_IN_BALANCE' do
      it 'populates @entry_station correctly' do
        subject.balance = MINIMUM_TOUCH_IN_BALANCE
        expect { subject.touch_in(station) }.to change { subject.entry_station }.to station
      end
    end
  end

  describe '#touch_out' do
    it 'deducts minimum fare' do
      subject.balance = 10
      expect { subject.touch_out }.to change { subject.balance }.by(-MINIMUM_FARE)
    end

    it 'sets @entry_station to nil' do
      subject.entry_station = 'foo'
      expect { subject.touch_out }.to change { subject.entry_station }.to nil
    end
  end

  describe '#in_journey?' do
    context 'when @entry_station is truthy' do
      it 'returns true' do
        subject.entry_station = 'foo'
        expect(subject.in_journey?).to eq true
      end
    end

    context 'when @entry_station is nil' do
      it 'returns false' do
        expect(subject.in_journey?).to eq false
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable LineLength
