extends Node2D

var city
var coord
var collected = false

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

func collect():
    if collected:
        return
    collected = true
    $Money.show()
    $Money/Kaching.play()
    $Tween.interpolate_property($SpriteAnimation, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.interpolate_property($Money, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.interpolate_property($Money, "position",
        Vector2(0, 0), Vector2(-30, -50), 1.0,
        Tween.TRANS_LINEAR)
    $Tween.interpolate_property($Money, "scale",
        Vector2(1, 1), Vector2(3, 3), 1.0,
        Tween.TRANS_LINEAR)
    $Tween.connect("tween_all_completed", self, "destroy")
    $Tween.start()

func destroy():
    queue_free()
