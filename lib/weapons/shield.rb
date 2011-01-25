class Shield
  attr_accessor :x, :y, :radius
  
  def self.load_image(window)
    @shield_image = Gosu::Image.new(window,"media/shield.png",false)
  end
  
  def initialize(window, ship, x, y)
    @window = window
    @ship = ship
    @x = x
    @y = y
    @image = self.class.load_image(window)
  end
  
  def radius
    45
  end
  
  def update
    @x = @ship.x
    @y = @ship.y
  end
  
  def draw
    angle = (Gosu::milliseconds / 15) % 360
    @image.draw_rot(@x, @y, ZOrder::Ship, angle, 0.5, 0.5, 0.75, 0.75, 0xff3366ff)
  end
  
  def collide?(thing)
    GameUtilities.collide?(self, thing)
  end

end