require 'spec_helper'
require 'oystercard'
# rubocop:disable Metrics/BlockLength
# rubocop:disable LineLength
RSpec.describe Oystercard do
  let(:mock_entry_station) { instance_double('Station', name: 'Waterloo') }
  let(:mock_exit_station) { instance_double('Station', name: 'Aldgate East') }
  let(:test_minimum_fare) { 666 }
  let(:test_penalty_fare) { 999 }

  describe 'defaults' do
    it 'balance is 0' do
      expect(subject.balance).to eq 0
    end

    it 'journeys is empty array' do
      expect(subject.journeys).to eq []
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
    let(:journey) { instance_double('Journey') }

    context 'when previous journey was not completed' do
      let(:unfinished_journey) { instance_double('Journey', entry_station: mock_entry_station) }
      before(:each) { subject.current_journey = unfinished_journey }

      context 'when balance is less than PENALTY_FARE' do
        before(:each) { subject.balance = PENALTY_FARE - 1 }

        it 'raises RuntimeError with appropriate message' do
          expect { subject.touch_in(mock_entry_station, journey) }.to raise_error(
            RuntimeError, "balance is less than minimum required balance of #{PENALTY_FARE}"
          )
        end
      end

      context 'when balance is >= PENALTY_FARE' do
        before :each do
          subject.balance = PENALTY_FARE + 1
          allow(unfinished_journey).to receive(:finish)
          allow(unfinished_journey).to receive(:fare).and_return(PENALTY_FARE)
          allow(journey).to receive(:begin)
        end

        it 'finishes current_journey' do
          expect(subject.current_journey).to receive(:finish)
          subject.touch_in(mock_entry_station, journey)
        end

        it 'deducts penalty fare' do
          subject.touch_in(mock_entry_station, journey)
          expect(subject.balance).to eq 1
        end

        it 'adds journey to journeys array' do
          subject.touch_in(mock_entry_station, journey)
          expect(subject.journeys).to include unfinished_journey
        end
      end
    end

    context 'when no current_journey' do
      context 'when balance is less than MINIMUM_TOUCH_IN_BALANCE' do
        it 'raises RuntimeError with appropriate message' do
          subject.balance = MINIMUM_TOUCH_IN_BALANCE - 1
          expect { subject.touch_in(mock_entry_station, journey) }.to raise_error(
            RuntimeError, "balance of #{subject.balance} is less than minimum required balance of #{MINIMUM_TOUCH_IN_BALANCE}"
          )
        end
      end

      context 'when balance is >= MINIMUM_TOUCH_IN_BALANCE' do
        before :each do
          subject.balance = MINIMUM_TOUCH_IN_BALANCE
          allow(journey).to receive(:begin)
          subject.touch_in(mock_entry_station, journey)
        end

        it 'begins new journey, passing entry_station' do
          expect(journey).to have_received(:begin).with(mock_entry_station)
        end

        it 'populates current_journey correctly' do
          expect(subject.current_journey).to eq journey
        end
      end
    end
  end

  describe '#touch_out' do
    context 'when a journey is not already in progress' do
      # maybe change to 'journey'
      let(:new_journey) { instance_double('Journey') }

      context 'when balance is less than penalty fare' do
        it 'raises RuntimeError with appropriate message' do
          expect { subject.touch_out(mock_exit_station, new_journey) }.to raise_error(
            RuntimeError, "balance is less than required balance of #{PENALTY_FARE}"
          )
        end
      end

      context 'when balance is not less than penalty fare' do
        before(:each) { subject.balance = PENALTY_FARE + 1 }

        it 'does not raise an Exception' do
          allow(new_journey).to receive(:finish)
          allow(new_journey).to receive(:fare).and_return(PENALTY_FARE)
          expect { subject.touch_out(mock_exit_station, new_journey) }.to_not raise_error
        end

        it 'finishes the journey, passing exit station' do
          expect(new_journey).to receive(:finish).with(mock_exit_station)
          allow(new_journey).to receive(:fare).and_return(PENALTY_FARE)
          subject.touch_out(mock_exit_station, new_journey)
        end

        it 'deducts penalty fare' do
          allow(new_journey).to receive(:finish)
          allow(new_journey).to receive(:fare).and_return(PENALTY_FARE)
          expect { subject.touch_out(mock_exit_station, new_journey) }.to change { subject.balance }.by(-PENALTY_FARE)
        end

        it 'adds journey to journeys array' do
          allow(new_journey).to receive(:finish)
          allow(new_journey).to receive(:fare).and_return(PENALTY_FARE)
          subject.touch_out(mock_exit_station, new_journey)
          expect(subject.journeys).to include new_journey
        end
      end
    end

    context 'when a journey is in progress' do
      let(:journey) { instance_double('Journey') }
      let(:journey_with_entry_station) { instance_double('Journey', entry_station: mock_entry_station) }

      before :each do
        subject.current_journey = journey_with_entry_station
        allow(journey_with_entry_station).to receive(:finish)
        allow(journey_with_entry_station).to receive(:fare).and_return(MINIMUM_FARE)
      end

      it 'finishes the journey, passing exit station' do
        expect(journey_with_entry_station).to receive(:finish).with(mock_exit_station)
        subject.touch_out(mock_exit_station, journey)
      end

      it 'deducts minimum fare' do
        expect { subject.touch_out(mock_exit_station, journey) }.to change { subject.balance }.by(-MINIMUM_FARE)
      end

      it 'sets @current_journey to nil' do
        subject.touch_out(mock_exit_station, journey)
        expect(subject.current_journey).to be_nil
      end

      it 'adds journey to the journeys array' do
        subject.touch_out(mock_exit_station, journey)
        expect(subject.journeys).to include journey_with_entry_station
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable LineLength
