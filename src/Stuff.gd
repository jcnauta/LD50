extends Sprite

var coord
var getting_eaten = false

func set_coord(new_coord):
    coord = new_coord
    position = new_coord * G.tile_dim

func get_eaten():
    if getting_eaten:
        return
    getting_eaten = true
    $EatSound.play()
    $Tween.interpolate_property(self, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.connect("tween_all_completed", self, "queue_free")
    $Tween.start()
