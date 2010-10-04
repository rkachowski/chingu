#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(640,480,false)
    self.input = { :escape => :exit }
    self.caption = "Tile maps fps:#{$window.fps}"
    push_game_state(Test2State.new())
    
  end
  
  def update
    super
    self.caption = "Tile maps fps:#{$window.fps}"
  end
end

class TestState < GameState
  def initialize
    super
    @map = TmxTileMap["test_one.tmx"]
  end
  
  def draw
    super
   @map.draw
  end
    
    def update
    super
    end
    
end

class Test2State < GameState
  def initialize
    super
    @map = TmxTileMap["test_3_layers.tmx"]
  end
  
  def draw
    super
   @map.draw
  end
    
    def update
    super
    end
    
end

Game.new.show
