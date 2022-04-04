extends Node2D

var turn_processed = true
var turn_number = 0
var turns_per_level = {}
var money_per_level = {}
var level_nr = 1
var money = 0

func _ready():
    $City.connect("lose_level", self, "lost_level")
    $City.connect("powerup_change", self, "powerup_change")
    $UI.connect("powerup_change", self, "powerup_change")
    $UI/Scores.connect("play_level", self, "play_level")
    play_level(level_nr)

func end_turn():
    # Prevent player from ending the turn before the previous one is over
    if turn_processed:
        turn_processed = false
        $City.end_turn()

func city_turn_processed():
    turn_processed = true
    turn_number += 1
    $UI.set_turn_number(turn_number)
    add_money(G.money_per_turn)
    for guy in $City/Guys.get_children():
        if not guy.love_found:
            add_money(G.money_per_guy)

func add_money(amount):
    money += amount
    $UI.set_money(money)

func lost_level():
#    turns_per_level[level_nr] = turn_number
    money_per_level[level_nr] = money
    $UI.show_scores(money_per_level, level_nr)
    money = 0

func powerup_change():
    $UI.update_powerups()

func play_level(level_to_play):
    level_nr = level_to_play
    G.generate_level_info(level_nr - 1)
    var level_info = G.levels[level_nr - 1]
    G.roadblocks = level_info.roadblocks
    G.icecreams = level_info.icecreams
    $UI.reset()
    $City.generate_city(level_nr)
    turn_processed = true
    turn_number = 0

