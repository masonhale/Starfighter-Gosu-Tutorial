class BaseShot

  attr_accessor :x, :y, :width, :height, :color1, :color2, :speed
  
  def self.load_sound(window)
    @fire_sound ||= Gosu::Sample.new(window, 'media/fire.ogg')
  end
  
  def initialize(window, ship, x, y, color1 = 0xffd936f1, color2 = 0xff000000)
    @window = window
    @ship = ship
    @x = x
    @y = y
    @width = 2  # this is actually 1/2 of width
    @height = 20
    @speed = 10.0
    @snd_frequency = 0.15
    @snd_volume = 2.0
    @color1 = Gosu::Color.new(color1)
    @color2 = Gosu::Color.new(color2)
    @snd = self.class.load_sound(@window)
    @muted = false
  end
  
  def update
    @y -= @speed
    if (@x > @window.width or @y > @window.height or @x < 0.0 or @y < 0.0)
      @ship.remove_shot(self)
    end
  end
  
  def draw    
    @window.draw_quad(x - width, y, @color1, 
                      x + width, y, @color1, 
                      x - width, y + height, @color2, 
                      x + width, y + height, @color2, 
                      ZOrder::Shot)

  end
  
  def fire
    play_sound
  end
  
  def play_sound
    @window.play_sound( @snd, @snd_frequency, @snd_volume )
  end
  
  def collide?(thing)
    if (Gosu::distance(@x - @width, @y, thing.x, thing.y) < thing.radius) or 
       (Gosu::distance(@x + @width, @y, thing.x, thing.y) < thing.radius) then
      true
    else
      false
    end
  end
  
end
