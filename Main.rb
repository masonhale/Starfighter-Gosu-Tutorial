require 'rubygems'
require 'gosu'

require_relative 'lib/zorder'
require_relative 'lib/game_utilities'
require_relative 'lib/ship'
require_relative 'lib/star'
require_relative 'lib/weapons'

class GameWindow < Gosu::Window
  
  def initialize
    super(640,480,false)
    self.caption = "Starfighter"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @counter = 0

    @background_image = Gosu::Image.new(self, "media/space.png", true)
    @ship = Ship.new(self)

    # load background music
    @backmusic = Gosu::Song.new(self, "media/backmusic.m4a")
    @backmusic.play(true)
    
    # use image of ship for life counter
    @life_image = Ship.load_image(self)
    
    @sounds = []
    
    start_game
  end
  
  def current_level
    (@score / 1000) + 1
  end
  
  def start_game
    @paused = false
    @game_over = false
    @life_counter = 3
    @base_speed = 0.5
    @score = 0
    @stars = []
    @ship.reset
  end
  
  # Will create a new player if lives are available
  def new_player
    if @life_counter > 0 then
      @life_counter -= 1
      @ship.spawn
    else
      @game_over = true
    end
  end
  
  def toggle_paused
    if @paused
      resume_sounds
    else
      pause_sounds
    end
    @paused = !@paused
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
    unless @paused || @game_over
      @ship.update
      @stars.each {|star| star.update}
      check_collisions
      clear_stopped_sounds
      populate_stars
    end
  end
  
  def check_collisions
    destroyed = []
    @stars.each do |star|
      # note: ship will check for collisions with itself 
      # and all of its shots 
      if @ship.collide?(star)
        # update score here
        @score += (10 * (3.0 / star.size)).to_i
        destroyed << star
      end
    end
    # remove stars here because we don't want to 
    # modify array while we're iterating thru it
    destroyed.each {|star| star.destroy }
  end
  
  def populate_stars
    
    @base_speed = ((current_level - 1) * 0.2) + 0.5
    max_speed = 10
      
    max_stars = 12 + (current_level * 2)
    prob = 2 + (current_level * 0.5 )
  
    if rand(100) < prob and @stars.size < max_stars then
      @stars.push(Star.new(self, [@base_speed, max_speed].min))
    end
  end

  def remove_star(star)
    @stars.delete(star)
  end
  
  def draw
    draw_game_ui
    # TODO tile background image to fit Window size
    @background_image.draw(0, 0, ZOrder::Background) 
    @stars.each {|star| star.draw}
    
    @ship.draw unless @game_over
  end
  
  def draw_game_ui
    @font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    
    w = @font.text_width("Level: #{current_level}")
    @font.draw("Level: #{current_level}", (width - 20 - w), 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)

    draw_life_counter
    draw_pause_screen if @paused
    draw_game_over_screen if @game_over
    draw_energy_gauge
  end
  
  def draw_text(text, x, y)
    w = @font.text_width(text)
    h = @font.height
    @font.draw(text, (x - w / 2), (y - h / 2), ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
  
  def draw_pause_screen  
    draw_text("PAUSED", 310, 240)
    draw_text("ESC - Quit", 310, 280)
    draw_text("Space/Alt/Ctrl - Fire Weapon", 310, 300)
    draw_text("Shift - Shield", 310, 320)
    draw_text("N - Nuke", 310, 340)
    draw_text("M - Toggle Music", 310, 360)   
  end
  
  def draw_game_over_screen
    draw_text("GAME OVER", 310, 240)
    draw_text("Press Enter to Play Again", 310, 280)    
  end
  
  def draw_life_counter
    if @life_counter > 0
      # draw number of lives remaining
      @life_counter.times do |i|
        @life_image.draw_rot(20 + (i * 28), (height - 20), ZOrder::UI, 0, 0.5, 0.5, factor_x=0.4, factor_y=0.4)
      end
      # draw box around the life counter
      draw_line(0, (height - 40), 0xffffff00, 10 + (@life_counter * 28), (height - 40), 0xffffff00, ZOrder::UI)
      draw_line(10 + (@life_counter * 28), height, 0xffffff00, 10 + (@life_counter * 28), (height - 40), 0xffffff00, ZOrder::UI)
    end
  end
  
  def draw_energy_gauge
    # draw shield gauge
    sc = 0xcc3366ff  # blue gauge

    if @ship.shield_counter >= Ship::MAX_SHIELD_ENERGY then
      sc = 0xccff6633  # orange gauge
    end
    
    sh = height - (@ship.shield_counter * 0.05)
    draw_quad((width - 10), height, sc, 
               width, height, sc, 
               (width - 10), sh, sc, 
               width, sh, sc, ZOrder::UI)
    
  end

  def button_down(id)
    if @game_over then
      if id == Gosu::KbEnter or id == Gosu::KbReturn or id == Gosu::GpButton9
        self.start_game
      end  
    else
      case id
      when Gosu::KbQ, Gosu::KbEscape
        close  # exit on press of escape key
      when Gosu::KbP
        toggle_paused
      when Gosu::KbM
        toggle_music
      end
      
      # CHEAT CODES
      if @paused
        case id
        when Gosu::GpButton10, Gosu::GpButton11, Gosu::KbLeftShift, Gosu::KbRightShift
          @ship.toggle_cheat_energy
        when Gosu::KbRightControl, Gosu::KbLeftControl
          @ship.toggle_rapid_fire
        end
      else
        @ship.button_down(id)
      end
      
    end
  end
  
  def button_up(id)
    @ship.button_up(id)
  end

end

window = GameWindow.new
window.show
