=begin

This very simple example demonstrates the Gosu::Window update/draw
loop by incrementing a counter on each update, and drawing the value
on each call to draw.

=end

require 'rubygems'
require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super(640,480,false)
    self.caption = "Update/Draw Demo"
    
    # we load the font once during initialize, much faster than
    # loading the font before every draw
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @counter = 0
  end
  
  def update
    @counter += 1
  end
  
  def draw
    @font.draw(@counter, 0, 0, 1)
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      close  # exit on press of escape key
    end
  end

end

window = GameWindow.new
window.show