=begin
  A trait to provide a collision and response against a tilemap

=end

module Chingu
  module TilemapCollision
    attr_reader :b_tile_col,:t_tile_col,:l_tile_col,:r_tile_col
    
    module ClassMethods
      def initialize_trait(options = {})
        trait_options[:tilemap_collision] = {:response => true}.merge(options)
      end
    end
    
    def update_trait
      reset_tile_col_vars
      if self.tile_map
        vertical_map_collision
        horizontal_map_collision
        
        do_response if trait_options[:tilemap_collision][:response]
        
        puts "l = #{@l_tile_col} r = #{@r_tile_col} t = #{@t_tile_col} b = #{@b_tile_col}"
      end
    end
      
    private
    
    def reset_tile_col_vars
      @b_tile_col = false
      @t_tile_col = false
      @l_tile_col = false      
      @r_tile_col = false      
    end
    
    def vertical_map_collision       
      @t_tile_col = true if collision_ver(bb.l,bb.t,bb.w)
      @b_tile_col = true if collision_ver(bb.l,bb.b,bb.w)
    end
    
    def horizontal_map_collision
      @l_tile_col = true if collision_hor(bb.l,bb.t,bb.h)
      @r_tile_col = true if collision_hor(bb.r,bb.t,bb.h)      
    end

    #
    # checking for collisions on the top and bottom sides of an aabb
    #
    def collision_ver(x,y,width)
      no_of_checks = ((width + x % self.tile_map.tile_width)/ self.tile_map.tile_width).ceil
      
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
      no_of_checks = ((height + y % self.tile_map.tile_height)/ self.tile_map.tile_height).ceil
      
      first_tile_row = (y / self.tile_map.tile_height).floor 
      first_tile_column = (x / self.tile_map.tile_width).floor
           
      no_of_checks.times do |i|
        if self.tile_map.get_tile(first_tile_column,first_tile_row+i)
          return true if self.tile_map.get_tile(first_tile_column,first_tile_row+i).solid          
        end
      end
      
      false
    end
    
    #
    # collision response against solid tiles
    #
    def do_response
      puts "respose"
    end
  end
end
  
