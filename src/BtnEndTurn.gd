extends TextureButton

var game

func _ready():
    game = get_node("/root/Game")
    self.connect("button_up", game, "end_turn")

func _process(delta):
    if Input.is_action_just_released("end_turn"):
        game.end_turn()
