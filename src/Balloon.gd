extends Node2D

var city
var coord

func init(new_coord, new_city):
    pause_mode = Node.PAUSE_MODE_PROCESS
    city = new_city
    set_coord(new_coord)
    return self

func set_coord(new_coord):
    var new_tile = city.tile_at_coord(new_coord)
    new_tile.add_balloon(self)
    coord = new_coord
    position = new_coord * G.tile_dim
