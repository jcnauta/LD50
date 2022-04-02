extends Node2D

var passable = false

func init(coords):
    self.position = coords * G.tile_dim
    return self

func set_passable(may_pass):
    passable = may_pass
    $Sprite.modulate = Color.white
