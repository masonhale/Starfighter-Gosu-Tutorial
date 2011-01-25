
class SingleShot < BaseShot
  
  # collision with obstacle destroys this shot
  def collide?(thing)
    if super
      @ship.remove_shot(self) 
      true
    end
  end
  
end