#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(640,480,false)
    self.input = { :escape => :exit,:space=>:push_next_map }
    self.caption = "Tile maps fps:#{$window.fps}"
    transitional_game_state(Chingu::GameStates::FadeTo, {:speed => 5, :debug => true})
    @current_state = 0
    
    push_next_map  
  end
  
  def push_next_map
    case @current_state
    when 0 then
      switch_game_state(Test4State.new)
    when 1 then
      switch_game_state(Test3State.new)
    when 2 then
      switch_game_state(TestState.new)
    when 3 then
      switch_game_state(Test2State.new)
      @current_state = -1
    end
    
    @current_state +=1
  end    
  
  def update
    super
  end
end

class MapState < GameState
  def initialize
    super     
  end
    
end
  

class TestState < MapState
  def initialize
    super
    @map = TileMap["test_one.tmx"]
    $window.caption = "single layer, single tileset"
  end
  
  def draw
    super
   @map.draw
  end
  
  def update
    super
    $window.caption = "single layer, single tileset fps = #{$window.fps}"
  end  
  
end

class Test2State < MapState
  def initialize
    super
    @map = TileMap["test_3_layers.tmx"]
    $window.caption = "3 tile layers"
  end
  
  def draw
    super
   @map.draw
  end    
  
  def update
    super
    $window.caption = "3 tile layers fps = #{$window.fps}"
  end
end

class Test3State < MapState
  def initialize
    super
    @map = TileMap["test_multiple_tilesets.tmx"]
    $window.caption = "single layer, multiple tilesets"
  end
  
  def draw
    super
   @map.draw
  end    
  
  def update
    super
    $window.caption = "single layer, multiple tilesets fps = #{$window.fps}"
  end
end

class Test4State < MapState
  def initialize
    super
    @map = TileMap["multiple_layer_multiple_tileset.tmx"]
    $window.caption = "2 layers 2 tilesets"
    
    @char = TestChar.create(:x=>200,:y=>200)
    @char.tile_map=@map
    self.input = {:holding_up=>lambda{@char.y-=1},:holding_down=>lambda{@char.y+=1},
                  :holding_left=>lambda{@char.velocity_x-=1},:holding_right=>lambda{@char.velocity_x+=1}}    
  end
  
  def draw
    super
   @map.draw
  end    
  
  def update
    super
    $window.caption = "2 layers 2 tilesets fps = #{$window.fps}"
  end
end

class TestChar < GameObject
  traits :collision_detection, :tilemap_collision,
         :bounding_box, :velocity
  
  attr_accessor :tile_map
  
  def initialize options={}
    super
    @image = Image["16x16.png"]    
  end
end

Game.new.show




















