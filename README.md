This is another ruby tutorial for the awesome Gosu game library. (http://www.libgosu.org)

This tutorial builds on the Ruby Tutorial example that is included in the game library. As a project to help teach my teenage son Ruby programming, we dissected the original Gosu Ruby Tutorial and put it back to together in steps to learn the basics of game programming and to make a game of our own. This tutorial borrows heavily from the media assets of the Gosu examples.

## Running

First, you need to install the gosu gem:
```bash
$ gem install gosu
```

Please note: the gosu gem depends on the SDL2 library. You may need to install the SDL2 library on your system. 
On a Mac, you can use Homebrew to install SDL2:
```bash
$ brew install sdl2
```

Run the Main.rb file to see the final game:
```bash
$ ruby Main.rb
```


## Background

The original Ruby Tutorial featured Asteroids-style navigation where left and right arrow keys rotate the ship, and the up and down keys control thrust and brake. The objective of the tutorial was to fly around the screen collecting stars.

This tutorial features "Galaga-style" fixed-angle navigation, where left and right move the ship along the x-axis and up and down move the ship along the y-axis. 

More importantly we added weapons! The weapons include single-shot (Space Key) and double-shot (Option/Alt Key) lasers, a "super shot" cannon (Control Key) that fires slowly but destroys anything in its path, and finally a nuke (N Key) that clears all obstacles from the screen when detonated. The nuke is only available if the ship's power level is full.

While in the original tutorial flying over a star would "collect" the star, in this tutorial hitting a star with your ship destroys the ship with an appropriately gratuitous explosion. To protect your ship you have a shield (Shift Key) that can be activated provided the ship's energy tank is not empty.


## Tutorial Steps

This tutorial is broken into 6 steps:
  
### 01_basic_window.rb 
Demonstrates Gosu::Window and its update/draw loop

### 02_graphics.rb
Demonstrates loading images and drawing to the window

<img width="642" alt="Screenshot: 02_graphics.rb" src="https://github.com/masonhale/Starfighter-Gosu-Tutorial/assets/69448/b61d499b-bf22-4d36-a3da-5fe99ab7b590">

### 03_basic_control.rb
Demonstrates input with a Ship that can fly around the screen

<img width="642" alt="Screenshot: 03_basic_control.rb" src="https://github.com/masonhale/Starfighter-Gosu-Tutorial/assets/69448/29926982-2126-411e-b691-13355d2a218c">

### 04_sounds_and_weaponry.rb
Adds weapons and sounds to 03_basic_control

<img width="646" alt="Screenshot: 04_sounds_and_weaponry.rb" src="https://github.com/masonhale/Starfighter-Gosu-Tutorial/assets/69448/7b405a9d-2fa6-4ebb-9577-8f6e69cff89c">

### 05_collisions.rb
Add Stars as obstacles with simple collision detection

<img width="641" alt="Screenshot: 05_collisions.rb" src="https://github.com/masonhale/Starfighter-Gosu-Tutorial/assets/69448/05f7385a-d3f8-46fa-a638-5e210249799c">

### Main.rb
Complete game with user interface, life counting, pause, etc. 
      
Classes are organized into separate files in lib directory

<img width="642" alt="Starfighter game: Main.rb" src="https://github.com/masonhale/Starfighter-Gosu-Tutorial/assets/69448/9ee7ff94-e054-4e14-a90f-ae47e8f3ecb7">

Pressing 'P' will pause the game and display the various controls. There are cheat codes available on the pause screen, but you will have to look through the source code to discover what those are.
