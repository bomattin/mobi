require_relative 'space'
class Property < Space
  # A class representing a property in the game of Monopoly
  # Mutators in this class all follow a pattern of returning booleans for success/failure
  # Rather than raising exceptions.
  attr_reader :owner
  attr_reader :housing_status
  attr_reader :mortgaged_value
  attr_reader :rent_values # current rent value is rentvalues[@prop_vals.index(housing_status)]
  attr_reader :development_cost
  attr_accessor :grouped_properties # Properties in the same color group


  @@prop_vals = [:rent, :house1, :house2, :house3, :house4, :hotel]

  def initialize(name, rent_values, development_cost, mortgage_value)
    # Sanity check our assumptions
    unless rent_values.length == 6
      raise ArgumentError.new('Must have 6 rent values')
    end
    unless mortgage_value.is_a?(Numeric) and name.is_a?(String) and development_cost.is_a?(Numeric)
      raise ArgumentError.new('One or more arguments has an invalid type')
    end
    rent_values.each do |val|
      unless val.is_a?(Numeric)
        raise ArgumentError.new('Non-integer in rent_values')
      end
    end

    @owner = :bank
    @housing_status = :rent
    @mortgaged_value = mortgage_value
    @name = name
    @rent_values = rent_values
    @development_cost = development_cost
    @grouped_properties = []
  end

  def set_owner!(new_owner_name)
    if [:bank, :player1, :player2, :player3, :player4].include? new_owner_name
      @owner = new_owner_name
      true
    else
      false
    end
  end

  def upgrade_property!
    current = @@prop_vals.index @housing_status
    if current and current != @@prop_vals.length - 1
      @housing_status = @@prop_vals[current+1]
      true
    else
      false
    end
  end

  def downgrade_property!
    current = @@prop_vals.reverse.index @housing_status
    if current and current != @@prop_vals.reverse.length - 1
      @housing_status = @@prop_vals.reverse[current+1]
      true
    else
      false
    end
  end

  def return_property_to_bank!
    @owner = :bank
  end

  def mortgage!
    puts @housing_status
    if @housing_status != :rent
      false
    else
      # player.cash += @mortgaged_value # No more!
      @housing_status = :mortgaged
      true
    end
  end

  def demortgage!
    if @housing_status != :mortgaged
      false
    else
      # player.cash -= @mortgaged_value * 1.10
      @housing_status = :rent
      true
    end
  end

  def play(player)
    grouped = true
    for prop in grouped_properties do
      grouped = false unless prop.owner == @owner
    end
    if @housing_status == :mortgaged
      player.cash -= @rent_values[0]
    elsif grouped
      player.cash -= 2 * @rent_values[@@prop_vals.index(@housing_status)]
    else
      player.cash -= @rent_values[@@prop_vals.index(@housing_status)]
    end
  end
end