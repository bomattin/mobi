require_relative 'player'
require_relative 'property'
require_relative 'event_space'
require_relative 'special_property'

class GameState

  attr_reader :spaces
  attr_reader :players
  attr_reader :player_doubles
  attr_reader :current_player
  attr_reader :player_positions
  attr_reader :banker

  def initialize(num_players, banker_ind)
    @players = [:player1, :player2, :player3, :player4].slice(0..num_players)
    @player_doubles = [0,0,0,0] # Keep track of how many doubles each player has rolled
    @player_positions = [0,0,0,0] # Player positions on the board
    @current_player = 0
    @banker = @players[banker_ind]

    # Define the functions of special (non-property) spaces, like
    lux_tax = Proc.new do |player, players|
      player.cash -= 100
    end

    # or Go
    go = Proc.new do |player|
      player.cash += 200
    end

    # Utility space
    util = Proc.new do |player, bank|
      unless self.owner == player
        # If the set of all utilities in game are a subset of this util's owner's properties, 10x dice roll
        # Alternatively (and perhaps much better), we can group all utilities using the grouped_properties attribute
        # and iterate that way.
        if (self.owner.properties.map(&:name).to_set) > ['Electric Company', 'Water Works'].to_set
          fee = 10 * ((1 + rand(6)) + 1 + rand(6))
          player.cash -= fee
          bank.cash += fee
        else
          fee = 4 * ((1 + rand(6)) + 1 + rand(6))
          player.cash -= fee
          bank.cash += fee
        end
      end
    end

    # Community chest cards
    comm_chest_cards = [
        Proc.new do |player, bank|
          player.cash -= 100
          bank.cash += 100
        end,
        Proc.new do |player, bank|
          player.cash += 200
          bank.cash -= 200
        end,
    ]


    @spaces = [
        EventSpace.new(go),
        Property.new('Mediterranean Avenue', [2, 10, 30, 90, 160, 250], 50, 30),
        Property.new('Baltic Avenue', [4, 20, 60, 180, 320, 450], 50, 30),
        EventSpace.new(lux_tax),
        SpecialProperty.new('Water Works', [0, 0, 0, 0, 0, 0], 0, 100, util),
        EventSpace.new(nil, comm_chest_cards),
    ]

    @spaces[0].grouped_properties = [@spaces[2],] # Example color grouping
    @spaces[1].grouped_properties = [@spaces[1],]
  end

  def move
    # Get current player
    # Roll some dice
    # Check doubles as necessary
    # Move the player to
    player_positions[@current_player] = (d1 + d2 + player_positions[@current_player]) % @spaces.length
    # Check if current is less than previous. If it is, we passed go. Collect $200
    # Play the current space.
    curr_space = @spaces[player_positions[@current_player]]
    unless curr_space.owner and curr_space.owner == :bank
      @spaces[player_positions[@current_player]].play(@players[@current_player], bank: bank, players: players)
    else
      auction_space(curr_space, players[@current_player])
    end
  end

  def sell_property(prop, player, bank)
    # Give player money from bank
    # Adjust property status, etc
  end

  def auction_space(prop, player)
    # stub
  end

end