MAXIMUM_ALLOWED_BALANCE = 90
MINIMUM_TOUCH_IN_BALANCE = 1
MINIMUM_FARE = 1

require_relative './station'

# rubocop:disable LineLength
class Oystercard # :nodoc:
  attr_accessor :balance, :entry_station, :journeys

  def initialize
    @balance = 0
    @journeys = []
  end

  def top_up(amount)
    if top_up_would_exceed_max_balance?(amount)
      raise ArgumentError, "top-up of #{amount} would exceed maximum allowed balance of #{MAXIMUM_ALLOWED_BALANCE}"
    end

    self.balance += amount
  end

  def touch_in(station)
    if minimum_balance_not_met?
      raise "balance of #{self.balance} is less than minimum balance of #{MINIMUM_TOUCH_IN_BALANCE}"
    end

    self.entry_station = station
  end

  def touch_out(station)
    journey = { entry_station: entry_station, exit_station: station }
    journeys << journey
    deduct(MINIMUM_FARE)
    self.entry_station = nil
  end

  def in_journey?
    !entry_station.nil?
  end

  private

  def deduct(fare)
    self.balance -= fare
  end

  def top_up_would_exceed_max_balance?(amount)
    (amount + self.balance) > MAXIMUM_ALLOWED_BALANCE
  end

  def minimum_balance_not_met?
    self.balance < MINIMUM_TOUCH_IN_BALANCE
  end
end
# rubocop:enable LineLength
