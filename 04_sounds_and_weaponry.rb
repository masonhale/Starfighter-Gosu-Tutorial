=begin

This example demonstrates loading and playing of sounds
as well as additional interaction to fire weapons

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
    self.caption = "Sounds & Weaponry Demo"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @counter = 0

    @background_image = Gosu::Image.new(self, "media/space.png", true)
    @ship = Ship.new(self)

    # load background music
    @backmusic = Gosu::Song.new(self, "media/backmusic.m4a")
    @backmusic.play(true)
    
    @sounds = []
  end
  
  def play_sound(sound, frequency = 1.0, volume = 1.0)
    @sounds << sound.play(frequency, volume)
  end
  
  def clear_stopped_sounds
    @sounds.reject! {|snd| !snd.playing? && !snd.paused? }
  end
  
  def pause_sounds
    @sounds.each {|snd| snd.pause if snd.playing? }
  end
  
  def resume_sounds
    @sounds.each {|snd| snd.resume if snd.paused? }
  end
  
  def toggle_music
    if @backmusic.playing?
      @backmusic.pause
    else
      @backmusic.play(true)
    end
  end
  
  def update
    @counter += 1
    @ship.update
    clear_stopped_sounds
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
    when Gosu::KbQ, Gosu::KbEscape
      close  # exit on press of escape key
    when Gosu::KbP
      toggle_music
    else
      # pass additional button presses to ship to control weaponry
      @ship.button_down(id)
    end
  end
  
  def button_up(id)
    @ship.button_up(id)
  end

end

class Ship
  attr_accessor :speed

  def initialize(window)
    @ship_image = Gosu::Image.new(window, 'media/starfighter.bmp', false)
    @shield_image = Gosu::Image.new(window,"media/shield.png",false)
    @window = window
    @x = window.width / 2
    @y = window.height / 2
    @speed = 5
    @x_offset = @ship_image.width / 2
    @y_offset = @ship_image.height / 2
    @shots = []
    @rapid_fire = false
  end
  
  def draw
    @ship_image.draw_rot(@x, @y, ZOrder::Ship, 0)
    @shots.each {|shot| shot.draw }
    if shield_up?
      angle = (Gosu::milliseconds / 15) % 360
      @shield_image.draw_rot(@x, @y, ZOrder::Ship, angle, 0.5, 0.5, 0.75, 0.75, 0xff3366ff)
    end
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
    
    @shots.each {|shot| shot.update }
    
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
  
  def button_down(key)
    case key
    when Gosu::KbSpace, Gosu::GpButton1
      fire_shot(SingleShot.new(@window, self, @x, @y))
    when Gosu::KbLeftAlt, Gosu::KbRightAlt, Gosu::GpButton2
      fire_shot(DoubleShot.new(@window, self, @x, @y))
    when Gosu::KbRightControl, Gosu::KbLeftControl, Gosu::GpButton0
      fire_shot(SuperShot.new(@window, self, @x, @y))
    when Gosu::KbN, Gosu::GpButton3
      fire_shot(Nuke.new(@window, self, @x, @y))
    when Gosu::KbLeftShift, Gosu::KbRightShift, Gosu::GpButton6, Gosu::GpButton7
      raise_shield
    when Gosu::KbR
      toggle_rapid_fire
    end
  end
  
  def button_up(key)
    case key
    when Gosu::KbLeftShift, Gosu::KbRightShift, Gosu::GpButton6, Gosu::GpButton7
      lower_shield
    end
  end
  
  def can_shoot?
    (@shots.empty? || @rapid_fire) && !shield_up?
  end
  
  def fire_shot(shot)
    if can_shoot?
      @shots << shot
      shot.fire
    end
  end
  
  def remove_shot(shot)
    @shots.delete(shot)
  end
  
  def shield_up?
    @shield_up
  end
  
  def raise_shield
    @shield_up = true
  end
  
  def lower_shield
    @shield_up = false
  end
  
  def toggle_rapid_fire
    @rapid_fire = !@rapid_fire
  end

end

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
  
end


class SingleShot < BaseShot
  
end

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
  
  def remove_shot(shot)
    @shots.delete(shot)
    if @shots.empty?
      @ship.remove_shot(self)
    end
  end

end


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
  
end

window = GameWindow.new
window.show
