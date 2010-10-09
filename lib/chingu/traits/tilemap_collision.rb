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
      if self.tile_map
        vertical_map_collision
        horizontal_map_collision 
      end
    end
      
    private

    #
    # checking for collisions on the left and right sides of an aabb
    #    
    def vertical_map_collision      
      #how many tiles can the top of the bounding box intersect
      no_of_checks = ( bb.w / self.tile_map.tile_width).ceil       
      no_of_checks +=1 if ((self.x-bb.w/2) % self.tile_map.tile_width) != 0
      
      #check top of bb
      first_tile_column = ((self.x-bb.w/2) / self.tile_map.tile_width).floor
      first_tile_row = ((self.y-bb.h/2) / self.tile_map.tile_height).floor  
          
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column+i,first_tile_row)
          puts "top collision!" if self.tile_map.get_tile(first_tile_column+i,first_tile_row).solid          
        end
      end
      
      #check bottom of bb      
      first_tile_row = (self.y+bb.h/2) / self.tile_map.tile_height
      
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column+i,first_tile_row)
          puts "bottom collision!" if self.tile_map.get_tile(first_tile_column+i,first_tile_row).solid          
        end
      end
      
    end
    
    #
    # checking for collisions on left and right side of aabb
    #
    def horizontal_map_collision
      #how many tiles can the left of the bounding box intersect
      no_of_checks = ( bb.h / self.tile_map.tile_height).ceil       
      no_of_checks +=1 if ((self.y-bb.h/2) % self.tile_map.tile_height) != 0
      
      #check left of bb
      first_tile_row = ((self.y-bb.h/2) / self.tile_map.tile_height).floor 
      first_tile_column = ((self.x-bb.w/2) / self.tile_map.tile_width).floor
           
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column,first_tile_row+i)
          puts "left collision!" if self.tile_map.get_tile(first_tile_column,first_tile_row+i).solid          
        end
      end
      
      #check right of bb      
      first_tile_column = ((self.x+bb.w/2) / self.tile_map.tile_width).floor
      
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column,first_tile_row+i)
          puts "right collision!" if self.tile_map.get_tile(first_tile_column,first_tile_row+i).solid            
        end
      end
      
    end
    
  end
end
  
