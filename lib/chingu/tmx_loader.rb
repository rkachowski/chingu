require 'stringio'
require 'zlib'
require 'crack/xml'

# load a tmx file (produced by Tiled map editor mapeditor.org )
# return a TileMap and TileSets that match tmx info

module Chingu

  class TmxTileMap
    include Chingu::NamedResource
    
    TmxTileMap.autoload_dirs = [ File.join("media","maps"),"maps",ROOT,File.join("..","media","maps")]
    
    def self.autoload(name)
      @name = name
        (path = find_file(name)) ? load(path) : fail("tilemap '#{name}' not found")
    end
      
    def self.load file
      file = File.new file

      file_info = file.readlines.join.strip

      tmx_info = Crack::XML.parse(file_info)
      
      #create a map along tmx definitions
      map = create_map get_global_map_info(tmx_info)

      #fill map with tile data
      fill_map(map, get_layer_info(tmx_info), get_tileset_info(tmx_info))
      
      map.name = @name
      
      map
    end

    private

    #
    # take tmx map info and decode it
    def self.uncode_map_info data
      data= data.unpack('m')
      data = StringIO.new(data.join)
      data = Zlib::GzipReader.new(data)
    end
    
    #
    #take info (name,dimensions etc) and return a TileMap that meets this
    def self.create_map info
      TileMap.new(:size=>[info[:width],info[:height]],:tilesize=>[info[:tile_width],info[:tile_height]])
    end
    
    #
    # get global map info (height + width etc) from a crack'd tmx hash
    def self.get_global_map_info tmx_info
      result = {}
      
      result[:tile_width] = tmx_info["map"]["tilewidth"].to_i
      result[:tile_height] = tmx_info["map"]["tileheight"].to_i
      
      #taking width from first layer 
      result[:width] = tmx_info["map"]["width"].to_i
      result[:height] = tmx_info["map"]["height"].to_i
      
      result
    end
    
    #
    # extract tileset information from a crack'd tmx hash
    def self.get_tileset_info tmx_info
      result = []
      
      if tmx_info["map"]["tileset"].is_a? Array
        tmx_info["map"]["tileset"].each{ |t| result << get_tileset(t)}
      else
        result << get_tileset(tmx_info["map"]["tileset"])
      end
    
      result
    end
    
    def self.get_tileset tileset_info
      tileset = {}
      
      tileset[:name] = tileset_info["name"]
      tileset[:image] = tileset_info["image"]["source"]
      tileset[:firstid] = tileset_info["firstgid"].to_i
      
      tileset
    end
    
    #
    # extract tile layout info from a crack'd tmx hash
    def self.get_layer_info tmx_info
      result = []
      
      #if there are multiple layers
      if tmx_info["map"]["layer"].is_a? Array
        tmx_info["map"]["layer"].each { |l| result<< get_layer(l) }
      else
        result<< get_layer(tmx_info["map"]["layer"])
      end
      
      result
    end
    
    def self.get_layer layer
      layer_info = {}
        layer_info[:name] = layer["name"]
        layer_info[:data] = layer["data"]
        layer_info
    end
    
    #
    # take map and fill it with tile layout info
    def self.fill_map map, info, tileset
      tilez = Array.new
      
      info.each do |h| 
        layer = h
        raw_map_data = uncode_map_info layer[:data]

        string_map_data = ""
        raw_map_data.to_a.each{|rd| string_map_data << rd}
        #string_map_data is now a String of size n_tiles*4
        
        t = string_map_data.bytes.to_a #get byte data of each char
        
        tiles = Array.new(t.size/4)
        0.upto(t.size/4-1){|i| p=0; tiles[i] = t[i*4..i*4+3].inject{|s,n| p+=1; s+n+(p*255*n)} }
        tilez << tiles
      end
    
      #merge tile layers
      tilez.each{|t| t.each_with_index{|tx,i| tilez[0][i] = tx unless tx ==0}}
        
       #add tile ids
      map.tids= tilez.first.uniq
      
      #add the tile info to our map
      map.set_tiles tilez[0],tileset
    end
    
  end

end
