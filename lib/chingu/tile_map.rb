=begin
  tile_map.rb - A collection of classes to display and handle tile map info
  
  - TileMap : A BasicGameObject which handles the drawing, moving and querying of the map
  - TileSet : A hash of Gosu::Images which correspond to the tile faces within the map
=end

module Chingu
  class TileMap < BasicGameObject    
    attr_accessor :map,:name,:tids
    attr_reader :x,:y,:tile_width,:tile_height,:map_width,:map_height
    
    include Chingu::NamedResource
    
    def self.autoload(name)
      case
        when name.include?(".tmx") then
          TmxTileMap[name]
        else
          fail("tilemap format not recognised")
      end    
    end

    def initialize(options={})
      fail("size not specified") unless options[:size] and options[:tilesize]

      @width = options[:size][0]
      @height = options[:size][1]
          
      @tile_width = options[:tilesize][0]
      @tile_height = options[:tilesize][1]

      @map_height = @tile_height * @height
      @map_width = @tile_width * @width
      
      @x = @y =@offset_x = @offset_y = 0
      
      @map = Array.new(@width){Array.new(@height){Tile.new({})}}
      
      get_drawable_grid
      
      @tileset = nil
    end
    
    def no_of_tiles
      @width*@height
    end
    
    def add_tileset(options={})
      fail("tileset cannot added before tile id's are defined") unless @tids
      @tileset = TileSet.new(:tids=>@tids,:tilesets=>options)
    end
    
    #
    # Return the tile at position [row, column] within the tile map
    # i.e. get_tile(2,2) refers to the tile that is in the second row and
    # second column of the map. Returns false if the values passed are out of bounds
    #
    def get_tile(row,column)
      return false if row < 0 or column < 0
      return false if row >= @width or column >= @height
      
      @map[row,column]
    end      
    
    #
    #create a tileset and assign each tile a face from it
    def set_tiles(tile_array, tileset_info)
      fail("wrong sized tile info given to map") unless tile_array.size == no_of_tiles
      add_tileset tileset_info
      t =0
      @height.times{|h| @map.each{|w| w[h].set_info tile_array[t],@tileset;t+=1}} #breadth first through a 2d array - feels dubious...
    end
    
    #
    #draws every tile that is visible on screen
    def draw        
      unless @min_x > @max_x or @min_y > @max_y then #unless the map is completely off screen
        @map[@min_x..@max_x].each_with_index do |x,i|
          x[@min_y..@max_y].each_with_index do |y,j|

            if @x <= 0
              xp = (i*@tile_width)+@offset_x
            else #the extremities of the map are visible
              xp = (i+((@x-@offset_x)/@tile_width).floor)*@tile_width+@offset_x
            end

            if @y <= 0
              yp = (j*@tile_height)+@offset_y
            else
              yp = (j+((@y-@offset_y)/@tile_height).floor)*@tile_height+@offset_y
            end
              
            y.draw xp, yp
          end
        end
      end
    end
    
    #
    # moves the entire map d =  [x,y] pixels
    def move(d=[])
      fail("did not recieve an array of size 2") unless d.is_a? Array and d.size == 2

      @x += d[0]
      @y += d[1]
        
      get_drawable_grid
    end

    def x= value
      @x = value
      
      get_drawable_grid
    end

    def y= value
      @y = value
      
      get_drawable_grid
    end

    #
    # given screen coordinates, return the row and column that this would map to. Considers
    # the position of the tile map within the world
    #
    def get_map_cell(position=[])
      fail("argument is not an array of size 2") unless position.is_a? Array and position.size == 2
        
      row = position[0]-@x
      column = position[1]-@y
      
      row = (row.to_f/@tile_width).floor
      column = (column.to_f/@tile_height).floor
      
      [row,column]
    end
    
    #
    #given a set of screen coordinates, return whether it is within the bounds of the tile map
    #
    def within_map?(position=[])
      c = get_map_cell position            
      if c[0] >=0 and c[0] < @width and c[1] >=0 and c[1] < @height then 
        return true
      end
      return false
    end     

    #
    # Converts a set of screen coordinates to map coordinates
    #
    def to_map_coords(position=[])
      [position[0]-@x,position[1]-@y]
    end  
    
    private

    # methods to handle the range of input on drawable map
    def min_x nv ; nv >= 0 ? @min_x =nv : @min_x = 0 end
    def min_y nv ; nv >= 0 ? @min_y =nv : @min_y = 0 end
    def max_x nv ; nv <= @width-1 ? @max_x =nv : @max_x = @width-1 end
    def max_y nv ; nv <= @height-1 ? @max_y =nv : @max_y = @height-1 end
    
    # sets max and min x and y values so we can know what portion of the tile map
    # is to be drawn
    def get_drawable_grid
      min = get_map_cell [0,0]
      max = get_map_cell [$window.width-1,$window.height-1]
      min_x min[0]
      max_x max[0]
      min_y min[1]
      max_y max[1]

      @offset_x = -(@tile_width - (@x % @tile_width))
      @offset_x = 0 if @offset_x == -@tile_width
      
      @offset_y = -(@tile_height - (@y % @tile_height))
      @offset_y = 0 if @offset_y == -@tile_height
        
    end
    
    class TileSet
      attr_reader :name
      
      #named resource so that the path to the tileset can be found
      include Chingu::NamedResource
     
      TileSet.autoload_dirs = [ File.join("media","maps")]

      def self.find(name)
        (path = find_file(name)) ? path : nil
      end
      
      def initialize options
        @tids = options[:tids]
        sets = []
        options[:tilesets].each do |ts|
          image = ts[:image]
          ftid = ts[:firstid] || 1
          sets <<{:image =>image,:name=>name,:ftid=>ftid, :spacing =>ts[:spacing]}
        end

        #load all tiles from tileset images
        sets.each do |s|
          ts_path = TileSet.find(s[:image])
          fail("tileset #{ts_path} not found") unless ts_path
          sp = s[:spacing] || 0 #gosu doesnt handle spaced tiles :(
          s[:tiles] =Gosu::Image.load_tiles($window,ts_path,16,16,true)
        end
        
        #keep only the tiles used in the map
        @tiles = {}
        
        @tids.each do |x|
          next if x ==0
          #find which set x is in
          ind = 0
          
          sets.each{|s| x < s[:ftid] ? lambda{ind = sets.index(s)-1;break} : ind = sets.index(s)}
          
          tiles = sets[ind][:tiles] # the set x is found in
          index = x - sets[ind][:ftid] # the index of x in the set
          
          @tiles[x]=tiles[index] unless x ==0
        end
        
      end
      
      #
      #given a tile number, return an image that maps to it
      def get_tile tile_no
        @tiles[tile_no] ? @tiles[tile_no] : fail("tile #{tile_no} does not exist in map")
      end
    end
    
    class Tile
      attr_accessor :solid, :image, :name, :type, :tileset
      @@debug = false
      def self.debug= v
        @@debug = v
      end

      def initialize options
        @name = options[:name] || "t_default.png"
        @solid = true      
      end
      
      def set_info type, tileset
        @type = type
        @tileset = tileset
        type ==0 ? empty : @image = tileset.get_tile(type)
      end
        
      def empty
        @solid = false
        @image = nil
      end
      
      def draw(x, y)
        @tileset.get_tile(type).draw(x,y,5) if @image
        $window.font.draw(@type,x,y,100) if @@debug
      end    
    end
    
  end
end
