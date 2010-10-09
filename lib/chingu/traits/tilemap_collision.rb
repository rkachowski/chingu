=begin
  A trait to provide a collision and response against a tilemap

=end

module Chingu
  module TilemapCollision
    attr_reader :b_collision,:t_collision,:l_collision,:r_collision
    
    module ClassMethods
      def initialize_trait(options = {})
        trait_options[:tilemap_collision] = {:apply => true}.merge(options)
      end
    end
    
    def update_trait
      reset_collision_vars
      if self.tile_map
        vertical_map_collision
        horizontal_map_collision 
        puts "l = #{@l_collision} r = #{@r_collision} t = #{@t_collision} b = #{@b_collision}"
      end
    end
      
    private
    
    def reset_collision_vars
      @b_collision = false
      @t_collision = false
      @l_collision = false      
      @r_collision = false      
    end
    
    def vertical_map_collision       
      @t_collision = true if collision_ver(bb.l,bb.t,bb.w)
      @b_collision = true if collision_ver(bb.l,bb.b,bb.w)
    end
    
    def horizontal_map_collision
      @l_collision = true if collision_hor(bb.l,bb.t,bb.h)
      @r_collision = true if collision_hor(bb.r,bb.t,bb.h)      
    end

    #
    # checking for collisions on the top and bottom sides of an aabb
    #
    def collision_ver(x,y,width)
      no_of_checks = ( width / self.tile_map.tile_width).ceil       
      no_of_checks +=1 if (x % self.tile_map.tile_width) != 0
      
      first_tile_column = (x / self.tile_map.tile_width).floor
      first_tile_row = (y / self.tile_map.tile_height).floor  
      
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column+i,first_tile_row)
          return true if self.tile_map.get_tile(first_tile_column+i,first_tile_row).solid          
        end
      end
            
      false
    end
    
    #
    # checking for collisions on the left and right sides of an aabb
    #
    def collision_hor(x,y,height)
      no_of_checks = ((height + y % self.tile_map.tile_height)/ self.tile_map.tile_height).ceil #( height / self.tile_map.tile_height).ceil       
      #no_of_checks +=1 if (y % self.tile_map.tile_height) != 0
      
      first_tile_row = (y / self.tile_map.tile_height).floor 
      first_tile_column = (x / self.tile_map.tile_width).floor
           
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column,first_tile_row+i)
          return true if self.tile_map.get_tile(first_tile_column,first_tile_row+i).solid          
        end
      end
      
      false
    end
    
  end
end
  
