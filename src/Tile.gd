extends Node2D

var passable = false
var coord
var visited_from = null  # For depth-first search



func init(init_coord):
    self.coord = init_coord
    self.position = init_coord * G.tile_dim
    return self

func set_passable(may_pass):
    passable = may_pass
    $Sprite.modulate = Color.red
