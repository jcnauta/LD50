extends Node2D

signal powerup_change

var city

var money_text
var turn_counter_text
var roadblock_btn
var icecream_btn

func _ready():
    roadblock_btn = $VBoxContainer/RoadblockBtn
    icecream_btn = $VBoxContainer/IcecreamBtn
    money_text = $VBoxContainer/HBoxContainer/Money
    turn_counter_text = $VBoxContainer/HBoxContainer2/TurnCounter
    city = get_node("/root/Game/City")
    roadblock_btn.connect("button_up", self, "roadblock_clicked")
    icecream_btn.connect("button_up", self, "icecream_clicked")
    set_money(0)
    
func set_turn_number(turn_nr):
    turn_counter_text.bbcode_text = str(turn_nr)

func set_money(money):
    money_text.bbcode_text = str(money)

func show_scores(money_per_level, current_level):
    $Scores.show_scores(money_per_level, current_level)

func roadblock_clicked():
    if G.roadblocks > 0:
        city.set_mode("roadblock")
        emit_signal("powerup_change")

func icecream_clicked():
    if G.icecreams > 0:
        city.set_mode("icecream")
        emit_signal("powerup_change")

func update_powerups():
    roadblock_btn.update()
    icecream_btn.update()

func reset():
    set_money(0)
    set_turn_number(0)
    update_powerups()
