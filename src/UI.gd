extends Node2D


func set_turn_number(turn_nr):
    $VBoxContainer/TurnCounter.bbcode_text = \
        "[center]CURRENT DELAY:\n" + str(turn_nr) + " TURNS[/center]"

func show_scores(turns_per_level, current_level):
    $Scores.show_scores(turns_per_level, current_level)
