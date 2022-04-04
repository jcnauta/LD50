extends Node2D

var city
var coord = null
var love_found = false
var guy_type

func init(new_date, new_city):
    pause_mode = Node.PAUSE_MODE_PROCESS
    city = new_city
    set_coord(new_date)
    return self

func set_coord(new_coord):
    if coord != null:
        var old_tile = city.tile_at_coord(coord)
        old_tile.clear_date(self)
    var new_tile = city.tile_at_coord(new_coord)
    new_tile.set_date(self)
    coord = new_coord
    position = new_coord * G.tile_dim

func set_guy_type(new_type):
    guy_type = new_type
    $SpriteAnimation.animation = new_type

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
