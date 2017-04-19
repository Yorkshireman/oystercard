class Oystercard # :nodoc:
  MAXIMUM_ALLOWED_BALANCE = 90
  attr_accessor :balance

  def initialize
    @balance = 0
  end

  def top_up(amount)
    if top_up_would_exceed_max_balance?(amount)
      raise ArgumentError, 'maximum balance allowed is 90'
    end

    self.balance += amount
  end

  private

  def top_up_would_exceed_max_balance?(amount)
    (amount + self.balance) > MAXIMUM_ALLOWED_BALANCE
  end
end
