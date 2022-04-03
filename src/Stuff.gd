extends Sprite

var coord

func set_coord(new_coord):
    coord = new_coord
    position = new_coord * G.tile_dim
