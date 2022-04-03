extends Node2D

var turn_processed = true
var turn_number = 0
var turns_per_level = {}
var level_nr = 1

func _ready():
    $City.connect("lose_level", self, "lost_level")
    $UI/Scores.connect("play_level", self, "play_level")
    $City.generate_city(level_nr)

func end_turn():
    # Prevent player from ending the turn before the previous one is over
    if turn_processed:
        turn_processed = false
        $City.end_turn()

func city_turn_processed():
    turn_processed = true
    turn_number += 1
    $UI.set_turn_number(turn_number)

func lost_level():
    turns_per_level[level_nr] = turn_number
    $UI.show_scores(turns_per_level, level_nr)

func play_level(level_to_play):
    level_nr = level_to_play
    $City.generate_city(level_nr)
    turn_processed = true
    turn_number = 0
