require_relative 'space'
require_relative 'player'

# A class for non-property event spaces. Chance, Go To Jail, etc.
class EventSpace < Space

  attr_reader :event
  attr_reader :cards

  def initialize(event, cards = nil)
    @event = event
    @cards = cards
  end

  def play(player, bank = nil, players = nil)
    if @cards
      @cards.shuffle.pop.call(player, bank, players)
    else
      @event.instance_exec(player, bank, players)
    end
  end


end