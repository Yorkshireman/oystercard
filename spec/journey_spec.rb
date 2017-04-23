require 'spec_helper'
require 'journey'

# rubocop:disable Metrics/BlockLength
RSpec.describe Journey do
  let(:mock_entry_station) { instance_double('Station', name: 'Waterloo') }
  let(:mock_exit_station) { instance_double('Station', name: 'Aldgate East') }

  describe '#begin' do
    context 'when passed entry_station' do
      it 'creates @entry_station variable and sets its value' do
        subject.begin(mock_entry_station)
        expect(subject.entry_station).to eq mock_entry_station
      end
    end
  end

  describe '#finish' do
    it 'creates @exit_station variable and sets its value' do
      subject.finish(mock_exit_station)
      expect(subject.exit_station).to eq mock_exit_station
    end

    context 'when passed exit_station and journey has entry_station' do
      it 'fare is minimum fare' do
        subject.begin(mock_entry_station)
        subject.finish(mock_exit_station)
        expect(subject.fare).to eq MINIMUM_FARE
      end
    end

    context 'when passed exit_station and journey has no entry_station' do
      it 'fare is penalty fare' do
        subject.finish(mock_exit_station)
        expect(subject.fare).to eq PENALTY_FARE
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
