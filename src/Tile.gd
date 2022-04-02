extends Node2D

var passable = false
var coord
var visited_from = null  # For depth-first search

func init(coord):
    self.coord = coord
    self.position = coord * G.tile_dim
    return self

func set_passable(may_pass):
    passable = may_pass
    $Sprite.modulate = Color.white
