# A DoubleShot is a container for 2 single shots
class DoubleShot < BaseShot
  
  def initialize(window, ship, x, y)
    super
    
    c1 = 0xff008800
    c2 = 0xff22aa22
    
    s1 = SingleShot.new(window, self, x - 15, y, c1, c2)
    s2 = SingleShot.new(window, self, x + 15, y, c1, c2)
    
    @shots = [s1, s2]

    @snd_frequency = 0.15
    @snd_volume = 1.0
  end
  
  def draw
    @shots.each {|s| s.draw}
  end
  
  def update
    @shots.each {|s| s.update}
  end
  
  def collide?(thing)
    @shots.any? {|s| s.collide?(thing)}
  end
  
  def remove_shot(shot)
    @shots.delete(shot)
    if @shots.empty?
      @ship.remove_shot(self)
    end
  end

end
