require_relative '../src/property'
require_relative '../src/player'
require 'test/unit'

class PropertyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @player1 = Player.new(0)
    @p1 = Property.new('Marvin Gardens', [24, 120, 360, 850, 1025, 1200], 150, 140)
    @p2 = Property.new('Ventnor Avenue', [22, 110, 330, 800, 975, 1150], 150, 130)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_positive_init
    begin
      p = Property.new('Marvin Gardens', [24, 120, 360, 850, 1025, 1200], 150, 140)
    rescue Exception => e
      fail(e)
    end
    assert(true)
  end

  def test_negative_init
    begin
      p = Property.new('Marvin Gardens', [24, 120, 360, 850, 1025], 150, 140)
    rescue ArgumentError => e
      assert(true)
    end
  end

  def test_upgrade
    @p1.upgrade_property!
    @p1.upgrade_property!
    assert_equal(:house2, @p1.housing_status)
    @p1.upgrade_property!
    @p1.upgrade_property!
    @p1.upgrade_property!
    assert_equal(:hotel, @p1.housing_status)
    assert_false(@p1.upgrade_property!) # Shouldn't be able to upgrade past hotel
  end

  def test_downgrade
    for i in 1..6
      @p1.upgrade_property!
    end
    assert_equal(:hotel, @p1.housing_status)
    @p1.downgrade_property!
    @p1.downgrade_property!
    assert_equal(:house3, @p1.housing_status)
    @p1.downgrade_property!
    @p1.downgrade_property!
    @p1.downgrade_property!
    assert_equal(:rent, @p1.housing_status)
  end

  def test_owner_validation
    assert_true(@p1.set_owner!(:player1))
    assert_false(@p1.set_owner!(:bret))
  end
  
  def test_mortgage_flow
    # Test that mortgaging properly increases player's currency, that a mortgaged property can't be upgraded
    # and that a property with developments cannot be mortgaged
    
    assert_true(@p1.mortgage!(@player1))
    assert_false(@p1.upgrade_property!)
    assert_equal(1520 + @p1.mortgaged_value, @player1.cash) # todo: Constant for player's starting cash

    assert_true(@p2.upgrade_property!)
    assert_equal(:house1, @p2.housing_status)
    assert_false(@p2.mortgage!(@player1))
  end

end