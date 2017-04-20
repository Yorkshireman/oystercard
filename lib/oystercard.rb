MAXIMUM_ALLOWED_BALANCE = 90
MINIMUM_TOUCH_IN_BALANCE = 1
MINIMUM_FARE = 1

# rubocop:disable LineLength
class Oystercard # :nodoc:
  attr_accessor :balance
  attr_accessor :in_journey

  def initialize
    @balance = 0
    @in_journey = false
  end

  def top_up(amount)
    if top_up_would_exceed_max_balance?(amount)
      raise ArgumentError, "top-up of #{amount} would exceed maximum allowed balance of #{MAXIMUM_ALLOWED_BALANCE}"
    end

    self.balance += amount
  end

  def touch_in
    if minimum_balance_not_met?
      raise "balance of #{self.balance} is less than minimum balance of #{MINIMUM_TOUCH_IN_BALANCE}"
    end

    self.in_journey = true
  end

  def touch_out
    deduct(MINIMUM_FARE)
    self.in_journey = false
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
