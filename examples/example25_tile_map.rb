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
      switch_game_state(Test2State.new)
    when 1 then
      switch_game_state(Test3State.new)
    when 2 then
      switch_game_state(TestState.new)
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
    self.input = {:holding_left=>lambda{@map.move [-5,0]},:holding_right=>lambda{@map.move [5,0]},
      :holding_down=>lambda{@map.move [0,5]},:holding_up=>lambda{@map.move [0,-5]}}
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

Game.new.show
