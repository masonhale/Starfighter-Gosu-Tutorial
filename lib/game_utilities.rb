module GameUtilities

  # returns a random color
  def self.random_color(base_brightness = 40)
    color = Gosu::Color.new(0xff000000)
    color.red = rand(255-base_brightness) + base_brightness
    color.green = rand(255-base_brightness) + base_brightness
    color.blue = rand(255-base_brightness) + base_brightness
    color
  end
  
  # Determines if two objects collide given their x,y coordinates and radii
  def self.collide?(thing1, thing2)
    dist = Gosu::distance(thing1.x, thing1.y, thing2.x, thing2.y)
    dist < (thing1.radius + thing2.radius)
  end

end