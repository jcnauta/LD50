extends Node2D

var city

func _ready():
    var roadblockBtn = $VBoxContainer/RoadblockBtn
    var icecreamBtn = $VBoxContainer/IcecreamBtn
    city = get_node("/root/Game/City")
    roadblockBtn.connect("button_up", self, "roadblock_clicked")
    icecreamBtn.connect("button_up", self, "icecream_clicked")
    
func set_turn_number(turn_nr):
    $VBoxContainer/TurnCounter.bbcode_text = \
        "[center]CURRENT DELAY:\n" + str(turn_nr) + " TURNS[/center]"

func show_scores(turns_per_level, current_level):
    $Scores.show_scores(turns_per_level, current_level)

func roadblock_clicked():
    city.set_mode("roadblock")

func icecream_clicked():
    city.set_mode("icecream")
