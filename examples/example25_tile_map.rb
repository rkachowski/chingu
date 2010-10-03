#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

class Game < Chingu::Window
  def initialize
    super(640,480,false)
    self.input = { :escape => :exit }
    self.caption = "Tile maps"
  end
end

class TestState < GameState
  def initialize
    super
  end
    
end

Game.new.show
