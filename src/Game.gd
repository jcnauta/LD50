extends Node2D

var turn_processed = true
var turn_number = 0
var turns_per_level = {}

func _ready():
    $City.connect("lose_level", self, "lost_level")
    $City.connect("powerup_change", self, "powerup_change")
    $UI.connect("powerup_change", self, "powerup_change")
    $UI/Scores.connect("play_level", self, "play_level")
    play_level(G.level_nr)

func toggle_menu():
    if G.showing_menu:
        $UI.hide_scores()
        get_tree().paused = false
    else:  # not showing menu, we are in-game - pause
        get_tree().paused = true
        G.just_paused = true
        $UI.show_scores()

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
    G.money += amount
    $UI.set_money(G.money)

func lost_level():
    if not G.money_per_level.has(G.level_nr) or G.money > G.money_per_level[G.level_nr]:
        G.money_per_level[G.level_nr] = G.money
    get_tree().paused = true
    $UI.show_scores()

func restart_level():
    disconnect("city_turn_processed", get_node("/root/Game"), "city_turn_processed")
    play_level(G.level_nr)

func powerup_change():
    $UI.update_powerups()

func play_level(level_to_play):
    G.level_nr = level_to_play
    G.money = 0
    var seed_info
    if typeof(level_to_play) == TYPE_STRING and level_to_play == "special":
        seed_info = {
            "seed": G.special_seed,
            "difficulty": G.special_difficulty,
            "goal": G.special_goal
        }
    else:
        seed_info = G.levels[G.level_nr]
    G.generate_level_info(seed_info)
    var level_info = G.level_info
    G.roadblocks = level_info.roadblocks
    G.icecreams = level_info.icecreams
    G.just_paused = false
    get_tree().paused = false
    $UI.reset()
    $UI.hide_scores()
    $City.generate_city(G.level_nr)
    turn_processed = true
    turn_number = 0

