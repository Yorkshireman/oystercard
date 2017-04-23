MAXIMUM_ALLOWED_BALANCE = 90
MINIMUM_TOUCH_IN_BALANCE = 1
MINIMUM_FARE = 1
PENALTY_FARE = 6

require_relative './station'
require_relative './journey'

# rubocop:disable LineLength
class Oystercard # :nodoc:
  attr_accessor :balance, :current_journey, :journeys

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

  def touch_in(station, journey = Journey.new)
    if journey_in_progress?
      raise "balance is less than minimum required balance of #{PENALTY_FARE}" if balance < PENALTY_FARE
      finish_journey
    end

    if minimum_balance_not_met?
      raise "balance of #{balance} is less than minimum required balance of #{MINIMUM_TOUCH_IN_BALANCE}"
    end

    commence(journey, station)
  end

  def touch_out(exit_station, new_journey = Journey.new)
    unless journey_in_progress?
      raise "balance is less than required balance of #{PENALTY_FARE}" if balance < PENALTY_FARE
      self.current_journey = new_journey
    end

    finish_journey(exit_station)
  end

  private

  def journey_in_progress?
    current_journey ? true : false
  end

  def commence(journey, station)
    journey.begin(station)
    self.current_journey = journey
  end

  def finish_journey(exit_station = nil)
    current_journey.finish(exit_station)
    deduct(current_journey.fare)
    journeys << current_journey
    self.current_journey = nil
  end

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
