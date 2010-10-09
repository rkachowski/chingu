=begin
  A trait to provide a collision and response against a tilemap

=end

module Chingu
  module TilemapCollision
    module ClassMethods
      def initialize_trait(options = {})
        trait_options[:tilemap_collision] = {:apply => true}.merge(options)
      end
    end
    
    def update_trait
      vertical_map_collision if self.tile_map
    end
      
    private

    #
    # checking for collisions on the left and right sides of an aabb
    #    
    def vertical_map_collision
      
      #how many tiles can the top of the bounding box intersect
      no_of_checks = ( bb.w / self.tile_map.tile_width).ceil       
      no_of_checks +=1 if ((self.x-bb.w/2) % self.tile_map.tile_width) != 0
      
      #in which row is the 
      first_tile_column = ((self.x-bb.w/2) / self.tile_map.tile_width).floor

      #check top of bb
      first_tile_row = ((self.y-bb.h/2) / self.tile_map.tile_height).floor      
      no_of_checks.times do |i|
        #puts "checking tile at column #{first_tile_column +i}, row #{first_tile_row}"
        if self.tile_map.get_tile(first_tile_column+i,first_tile_row)
          puts "top collision!" if self.tile_map.get_tile(first_tile_column+i,first_tile_row).solid
          puts "nothing" if not self.tile_map.get_tile(first_tile_column+i,first_tile_row).solid
        end
      end
      
      first_tile_row = (self.y+bb.h/2) / self.tile_map.tile_height
      
      #check bottom of bb
      no_of_checks.times do |i|
        #puts("top collision!") if self.tile_map.get_tile(first_tile_row +i,first_tile_column).solid
      end
    end
    
    def horizontal_map_collision
      
    end
    
  end
end
  
