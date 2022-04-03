extends Node2D

var coord = null
var love_found = false

func init(coord):
    set_coord(coord)
    return self

func set_coord(new_coord):
    self.coord = new_coord
    self.position = new_coord * G.tile_dim

func found_love():
    if love_found:
        return
    love_found = true
    $Tween.interpolate_property($SpriteAnimation, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.connect("tween_all_completed", self, "destroy")
    $Tween.start()

func destroy():
    queue_free()
