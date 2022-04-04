extends TextureButton

var game

func _ready():
    game = get_node("/root/Game")
    self.connect("button_up", game, "restart_level")
