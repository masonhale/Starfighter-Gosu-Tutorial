class SuperShot < BaseShot

  def initialize(window, player, x, y)
    super
    @color1 = Gosu::Color.new(0xffaa0000) #D936F1
    @color2 = Gosu::Color.new(0xffaacc00) #9c1ddc
    @width = 4
    @speed = 5.5
    @snd_frequency = 0.3
    @snd_volume = 0.5
  end
  
end
