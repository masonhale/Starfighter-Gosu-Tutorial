class Ship
  
  MAX_SHIELD_ENERGY = 1000
  
  attr_accessor :speed, :x, :y, :shield_counter
  
  def self.load_explosion_sound(window)
    @explosion_snd ||= Gosu::Sample.new(window, 'media/explosion.ogg')
  end
  
  def self.load_image(window)
    @ship_image ||= Gosu::Image.new(window, 'media/starfighter.bmp', false)
  end
  
  def initialize(window)
    @ship_image = self.class.load_image(window)
    @explosion = self.class.load_explosion_sound(window)
    
    @window = window
    @x = window.width / 2
    @y = window.height / 2
    @speed = 5
    @x_offset = @ship_image.width / 2
    @y_offset = @ship_image.height / 2
    @shots = []
    @shield = Shield.new(window, self, @x, @y)
    reset
  end
  
  def reset
    reset_shield_counter
    @exploding = false
    @shield_up = false
    @cheat_energy = false
    @rapid_fire = false
    @x = @window.width / 2
    @y = 400
  end
  
  def reset_shield_counter
    unless @cheat_energy
      @shield_counter = -30
    end
  end
  
  def draw
    if @exploding
      c1 = Gosu::Color.new(0xffff0000)
      c1.alpha = @exploding_counter
      c1.green = (@exploding_counter / 2)

      scale = 1.5 + (((200 - @exploding_counter)/200.0) * 0.75)
      @ship_image.draw_rot(@x, @y, ZOrder::Ship, 0, 0.5, 0.5, scale, scale, c1)
    elsif @spawning
      c1 = Gosu::Color.new(0xcc0099ff)
      @ship_image.draw_rot(@x, @y, ZOrder::Ship, 0, 0.5, 0.5, 1, 1, c1)
    else
      @ship_image.draw_rot(@x, @y, ZOrder::Ship, 0)
      if shield_up?
        @shield.draw
      end
    end
    
    @shots.each {|shot| shot.draw }
  end
  
  def update
    update_explosion
    update_spawning
    update_shield_energy
    move
    @shield.update
    @shots.each {|shot| shot.update }
  end
  
  def update_shield_energy
    if !@shield_up && @shield_counter < 1000
      @shield_counter += 1.5
    end
    
    if @shield_up && !@cheat_energy then
      @shield_counter -= 6
      if @shield_counter < 0
        @shield_up = false
        reset_shield_counter
      end
    end
  end
  
  def update_explosion
    if @exploding then
      @exploding_counter -= 1
      if @exploding_counter <= 0 then
        @exploding = false
        @window.new_player
      end
    end
  end
  
  def update_spawning
    if @spawning then
      @spawning_counter ||= 100
      @spawning_counter -= 1
      if @spawning_counter < 0 then
        @spawning = false
      end
    end
  end
  
  
  def spawn
    @spawning = true
    @spawning_counter = nil
    reset
  end
  
  def move
    return if @exploding
    
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
  
  def button_down(key)
    case key
    when Gosu::KbSpace, Gosu::GpButton1
      fire_shot(SingleShot.new(@window, self, @x, @y))
    when Gosu::KbLeftAlt, Gosu::KbRightAlt, Gosu::GpButton2
      fire_shot(DoubleShot.new(@window, self, @x, @y))
    when Gosu::KbRightControl, Gosu::KbLeftControl, Gosu::GpButton0
      fire_shot(SuperShot.new(@window, self, @x, @y))
    when Gosu::KbN, Gosu::GpButton3
      fire_nuke
    when Gosu::KbLeftShift, Gosu::KbRightShift, Gosu::GpButton6, Gosu::GpButton7
      raise_shield
    end
  end
  
  def button_up(key)
    case key
    when Gosu::KbLeftShift, Gosu::KbRightShift, Gosu::GpButton6, Gosu::GpButton7
      lower_shield
    end
  end
  
  def can_shoot?
    (@shots.empty? || @rapid_fire) && !shield_up? && !@spawning && !@exploding
  end
  
  def can_collide?
    !@spawning && !@exploding
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
    unless @exploding or @spawning then
      if @shield_counter > 0
        @shield_up = true
      end
    end
  end
  
  def lower_shield
    @shield_up = false
  end
  
  def toggle_rapid_fire
    @rapid_fire = !@rapid_fire
  end
  
  def toggle_cheat_energy
    @cheat_energy = !@cheat_energy
    if @cheat_energy then
      @shield_counter = MAX_SHIELD_ENERGY
    end
  end
  
  def radius
    @radius ||= @ship_image.width / 2
  end
  
  def destroy
    @window.play_sound(@explosion)
    @exploding = true
    @exploding_counter = 200
  end
  
  def collide?(thing)    
    # check for shield collision
    if shield_up?
      if @shield.collide?(thing)
        return true
      end
    else
      if can_collide? && GameUtilities.collide?(self, thing)
        # collision with ship destroys the ship
        self.destroy
        return true
      end
    end
    
    # check if any of the shots collide with the obstacle
    @shots.any? {|shot| shot.collide?(thing) }
  end
  
  def fire_nuke
    if @shield_counter >= MAX_SHIELD_ENERGY
      fire_shot Nuke.new(@window, self, @x, @y)
      unless @cheat_energy then
        reset_shield_counter
      end
    end
  end

end
