class Nuke < BaseShot
    
  def self.load_image(window)
    @loaded_image ||= Gosu::Image.new(window,"media/shield.png",false)
  end
  
  def initialize(window, ship, x, y)
    super
    @size = 0.5
    @image = self.class.load_image(window)
    @angle = 0.0
    @snd_frequency = 0.4
    @snd_volume = 0.3
  end
  
  def draw
    @image.draw_rot(@x, @y, ZOrder::Shot, @angle, 0.5, 0.5, @size, @size, 0xffff6633)
  end
  
  def update
    @angle -= 5
    @size *= 1.05
    if (@size * 20) > @window.width then
      @ship.remove_shot(self)
    end
  end
  
  def radius
    @size * 60
  end
  
  def collide?(thing)
    GameUtilities.collide?(self, thing)
  end
  
end
