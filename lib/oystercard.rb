class Oystercard # :nodoc:
  attr_accessor :balance

  def initialize
    @balance = 0
  end

  def top_up(amount)
    self.balance += amount
  end
end
