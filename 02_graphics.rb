=begin

This example demonstrates how to load graphics and draw various images

Key points
  - ZOrder module
  - Color
  - image
  - draw
  - draw_rot
  - draw_quad
  
=end

require 'rubygems'
require 'gosu'

# Use module to define relative Z-order of game elements
module ZOrder
  Background = 0
  Star = 1
  Shot = 2
  Ship = 3
  UI = 4
end

class GameWindow < Gosu::Window

  def initialize
    super(640,480,false)
    self.caption = "Graphics Demo"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @counter = 0
    
    # load image assets
    # params: window, file path, tileable?
    @background_image = Gosu::Image.new(self, "media/space.png", true)
    
    # given a 'sprite' image, splits it into evenly-sized 'tiles'
    # based on given width, height
    # returns an array of Gosu::Image objects
    @star_anim = Gosu::Image::load_tiles(self, "media/star.png", 25, 25, false)
    
    # Note that pure magenta color (0xffff00ff) in BMP files is 
    # rendered as transparent
    @ship_image =  Gosu::Image.new(self, 'media/starfighter.bmp', false)
    
    
    @shield_image = Gosu::Image.new(self, 'media/shield.png', false)
    
  end
  
  def update
    @counter += 1
  end
  
  def draw
    @font.draw("Updates: #{@counter}", 0, 0, ZOrder::UI, 1.0, 1.0, 0xffffff00)

    # params: x,y,z
    @background_image.draw(0, 0, ZOrder::Background) 
        
    # display each image tile separately
    @star_anim.each_with_index do |tile, i|
      tile.draw(100 + (40 * i), 50, ZOrder::Star)
    end
    
    # iterate through tiles, by selecting appropriate image from array
    img = @star_anim[(Gosu::milliseconds / 100) % @star_anim.size]
    img.draw(100, 120, ZOrder::Star)
    
    # scaled up 2x with color shift
    img.draw(100, 220, ZOrder::Star, 2.0, 2.0, 0xff1199dd)
    
    # rotated -90 degrees, scaled up 3x with color shift
    # note that image is drawn centered at x,y instead of top,left
    img.draw_rot(100, 340, ZOrder::Star, -90, 0.5, 0.5, 3.0, 3.0, 0xff99dd33)
    
    # use draw_quad to draw some example shots
    x = 400
    y = 120
    draw_quad(x - 2, y, 0xffd936f1, 
              x + 2, y, 0xffd936f1, 
              x - 2, y + 20, 0xff000000, 
              x + 2, y + 20, 0xff000000, ZOrder::Shot)
    
    x = 400
    y = 220
    draw_quad(x - 4, y, 0xffaa0000, 
              x + 4, y, 0xffaa0000, 
              x - 4, y + 20, 0xffaacc00, 
              x + 4, y + 20, 0xffaacc00, ZOrder::Shot)
                        
    # here we use draw_rot to draw ship centered at x,y
    # this makes it easier draw the shield around it
    @ship_image.draw_rot(400, 360, ZOrder::Ship, 0)
    
    # use draw_rot method to draw rotating image of ship
    angle = (Gosu::milliseconds / 15) % 360
    @shield_image.draw_rot(400, 360, ZOrder::Shot, angle, 0.5, 0.5, 0.75, 0.75, 0xff3366ff)
  end

  def button_down(id)
    case id
    when Gosu::KbEscape
      close  # exit on press of escape key
    end
    
  end
  
end

window = GameWindow.new
window.show