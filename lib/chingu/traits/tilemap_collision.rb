=begin
  A trait to provide a collision and response against a tilemap

=end

module Chingu
  module TilemapCollision
    attr_reader :b_tile_col,:t_tile_col,:l_tile_col,:r_tile_col
    
    module ClassMethods
      def initialize_trait(options = {})
        trait_options[:tilemap_collision] = {:response => true}.merge(options)
        @colliding_tiles={}
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
      @colliding_tiles={}    
    end
    
    def vertical_map_collision       
      @t_tile_col = true if collision_ver(bb.l,bb.t+self.velocity_y,bb.w)
      @b_tile_col = true if collision_ver(bb.l,bb.b+self.velocity_y,bb.w)
    end
    
    def horizontal_map_collision
      if collision_hor(bb.l+self.velocity_x,bb.t,bb.h)
        @l_tile_col = true 
        @colliding_tiles[:left] = collision_hor(bb.l+self.velocity_x,bb.t,bb.h)
      end
      
      if collision_hor(bb.r+self.velocity_x,bb.t,bb.h)
        @r_tile_col = true 
        @colliding_tiles[:right] = collision_hor(bb.r+self.velocity_x,bb.t,bb.h)
      end      
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
          if self.tile_map.get_tile(first_tile_column,first_tile_row+i).solid
            return self.tile_map.get_tile(first_tile_column,first_tile_row+i)
          end          
        end
      end
      
      false
    end
    
    #
    # collision response against solid tiles
    # note: we are only responding when we are moving, with the exception of collisions on the bottom of the aabb.
    # this assumes a downwards force of gravity - will need to investigate if this is suitable for a generic approach
    #
    def do_response
      
      #only checking x axis collisions when we are moving in that direction
      if self.velocity_x.abs > 0
        if self.velocity_x > 0
          if @r_tile_col
            self.x = @colliding_tiles[:right].bounds.l - self.bb.w/2
            self.velocity_x = 0;
          end
        else
          if @l_tile_col
            self.x = @colliding_tiles[:left].bounds.r + 1 + self.bb.w/2
            self.velocity_x = 0;
          end
        end
      end
      
      if self.velocity_y < 0
        #moving up
      else
        #we are moving down, or stationary
      end
      
    end
  end
end
  
