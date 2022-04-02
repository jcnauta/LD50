extends Node2D


func _ready():
    pass

func destroy():
    $Tween.interpolate_property($SpriteAnimation, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.connect("tween_completed", self, "queue_free")
