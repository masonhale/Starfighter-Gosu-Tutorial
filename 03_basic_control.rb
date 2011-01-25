=begin

This example adds a Ship class that is able to move around on screen
using the arrow keys or gamepad directional pad.

Key points:
  - button_down  and button_down?  methods
  - Note that button_down is only called once per key press
  - To get a "press and hold" interaction, should check the button_down?
    state in the update method

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
    self.caption = "Basic Control Demo"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @counter = 0
    # load image assets
    # params: window, file path, tileable?
    @background_image = Gosu::Image.new(self, "media/space.png", true)
    @ship = Ship.new(self)
  end
  
  def update
    @counter += 1
    @ship.update
  end
  
  def draw
    @font.draw("updates since button_down: #{@counter}", 0, 0, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("last button id: #{@last_btn}", 0, 25, ZOrder::UI, 1.0, 1.0, 0xffffff00)
        
    @background_image.draw(0, 0, ZOrder::Background) 
    @ship.draw
  end

  def button_down(id)
    @last_btn = id
    
    @counter = 0  # reset counter on each button down
    
    case id
    when Gosu::KbEscape
      close  # exit on press of escape key
    end
    
  end
  
end

class Ship
  attr_accessor :speed

  def initialize(window)
    @shipimg = Gosu::Image.new(window, 'media/starfighter.bmp', false)
    @window = window
    @x = window.width / 2
    @y = window.height / 2
    @speed = 5
    @x_offset = @shipimg.width / 2
    @y_offset = @shipimg.height / 2
  end
  
  def draw
    @shipimg.draw_rot(@x, @y, ZOrder::Ship, 0)
  end
  
  def update
    if @window.button_down?(Gosu::KbLeft) or @window.button_down?(Gosu::GpLeft)
      move_left
    end
    if @window.button_down?(Gosu::KbRight) or @window.button_down?(Gosu::GpRight)
      move_right
    end
    if @window.button_down?(Gosu::KbUp) or @window.button_down?(Gosu::GpUp)
      move_up
    end
    if @window.button_down?(Gosu::KbDown) or @window.button_down?(Gosu::GpDown)
      move_down
    end
  end
  
  def move_left
    if @x > 0 + @x_offset
      @x -= @speed
    end
  end
  
  def move_right
    if @x < @window.width - @x_offset
      @x += @speed
    end
  end
  
  def move_up
    if @y > 0 + @y_offset
     @y -= @speed
    end
  end

  def move_down
    if @y < @window.height - @y_offset
      @y += @speed
    end
  end
  
end


window = GameWindow.new
window.show
