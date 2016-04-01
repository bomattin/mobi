class Player
  attr_accessor :cash
  attr_reader :properties
  attr_reader :player_id

  def initialize(id)
    @cash = 1520
    @properties = []
    @player_id = [:player1, :player2, :player3, :player4][id]
  end


  # This should be handled by GameState
=begin
  def buy_property!(property)
    if @cash < property.rent_values[0]
      false
    else
      @cash -= property.rent_values[0]
      property.set_owner!(@player_id)
      true
    end
  end
=end

end