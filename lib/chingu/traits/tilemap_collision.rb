=begin
  A trait to provide a collision and response against a tilemap

=end

module Chingu
  module TilemapCollision
    attr_reader :tile_map
    module ClassMethods
      def initialize_trait(options = {})
        trait_options[:tilemap_collision] = {:apply => true}.merge(options)
      end
    end
      
    private

    #
    # checking for collisions on the left and right sides of an aabb
    #    
    def vertical_map_collision
      no_of_checks = ( bb.w / @map.tile_width).ceil
      
      first_tile_row = (@x-bb.w/2) - (@x-bb.w/2) % @map.tile_width

      #check top of bb
      first_tile_column = (@y-bb.h/2) / @map.tile_height
      
      no_of_checks.times do |i|
        
      end
      
      #check bottom of bb
      
    end
    
    def horizontal_map_collision
      
    end
    
  end
end
  
