require_relative 'property'

# A class for spaces that act like properties (in that they can be owned), but have variable effects
# Ex: Railroads, Util Companies
class SpecialProperty < Property

  attr_reader :play_event

  def initialize(name, rent_values, development_cost, mortgage_value, play_event)
    super(name, rent_values, development_cost, mortgage_value)
    @play_event = play_event
  end

  def play(player, bank, players = nil, cards = nil)
    @play_event.instance_exec(player, bank, players, cards)
  end

end