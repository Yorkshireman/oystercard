class Journey # :nodoc:
  attr_reader :fare, :entry_station, :exit_station

  def begin(entry_station)
    @entry_station = entry_station
  end

  def finish(exit_station = nil)
    @exit_station = exit_station
    @fare = calculate_fare(entry_station, exit_station)
  end

  private

  def calculate_fare(entry_station, exit_station)
    return MINIMUM_FARE if entry_station && exit_station
    PENALTY_FARE
  end
end
