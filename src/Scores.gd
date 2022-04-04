extends Control

signal play_level

var button_to_level = {}
var seed_inp
var difficulty_inp

func _ready():
    pause_mode = Node.PAUSE_MODE_PROCESS
    var game = get_node("/root/Game")
    $CloseBtn.connect("button_up", game, "toggle_menu")

func show_scores():
#    G.money_per_level = {
#        1: 2, 
#        2: 2,
#        3: 243,
#        4: 947,
#        5: 13,
#        6: 35,
#        7: 21,
#        8: 8,
#        9: 14
#       }
    if G.just_paused:
        $CloseBtn.show()
    else:
        $CloseBtn.hide()
    var level_nums = $VBoxContainer/HBoxContainer/LevelNumbers
    var money_nums = $VBoxContainer/HBoxContainer/MoneyNumbers
    var money_goal = $VBoxContainer/HBoxContainer/MoneyGoals
    level_nums.bbcode_text = "[b]Area[/b]\n"
    money_goal.bbcode_text = "[b]Goal[/b]\n"
    money_nums.bbcode_text = "[b]Best[/b]\n"
    var total_money = 0
    var total_goal = 0
    var amount_helper
    for lvl in G.levels:
        if typeof(lvl) == typeof(G.level_nr) and lvl == G.level_nr:
            level_nums.bbcode_text += "[color=green]"
            money_nums.bbcode_text += "[color=green]"
            money_goal.bbcode_text += "[color=green]"
        level_nums.bbcode_text += str(lvl) + "\n"
        if G.money_per_level[lvl] == -1:
            amount_helper = "-"
        else:
            amount_helper = G.money_per_level[lvl]
            money_nums.bbcode_text += "$"
        money_nums.bbcode_text += str(amount_helper) + "\n"
        money_goal.bbcode_text += "$" + str(G.levels[lvl].goal) + "\n"
        if typeof(lvl) == typeof(G.level_nr) and lvl == G.level_nr:
            level_nums.bbcode_text += "[/color]"
            money_nums.bbcode_text += "[/color]"
            money_goal.bbcode_text += "[/color]"
        if typeof(amount_helper) != TYPE_STRING:  # amount_helper != "-":
            total_money += G.money_per_level[lvl]
        total_goal += G.levels[lvl].goal
    # ADD SPECIAL LEVEL
    level_nums.bbcode_text += "Special\n"
    if G.money_per_level.has("special") and G.money_per_level["special"] != -1:
        money_nums.bbcode_text += "$" + str(G.money_per_level["special"]) + "\n"
        total_money += G.money_per_level["special"]
    else:
        money_nums.bbcode_text += "-\n"
    money_goal.bbcode_text += "$" + str(G.special_goal) + "\n"
    total_goal += G.special_goal
    
    # ADD BUTTONS
    var buttons = $VBoxContainer/HBoxContainer/Buttons
    for ch in buttons.get_children():
        buttons.remove_child(ch)
    var margin = MarginContainer.new()
    margin.rect_min_size.y = 57
    buttons.add_child(margin)
    for lvl_nr in G.levels:
        var new_button = Button.new()
        new_button.text = "Play"
        buttons.add_child(new_button)
        new_button.connect("button_up", self, "play_clicked", [new_button])
        button_to_level[new_button] = lvl_nr
        margin = MarginContainer.new()
        margin.rect_min_size.y = 22
        buttons.add_child(margin)

    # Add widget for custom play
    difficulty_inp = LineEdit.new()
    difficulty_inp.max_length = 2
    difficulty_inp.rect_min_size.x = 80
    difficulty_inp.placeholder_text = "difficulty (1-99)"
    seed_inp = LineEdit.new()
    seed_inp.max_length = 3
    seed_inp.placeholder_text = "seed (1-999)"
    var button_random = Button.new()
    button_random.text = "Play Special"
    buttons.add_child(button_random)
    button_random.connect("button_up", self, "play_clicked", [button_random])
    button_to_level[button_random] = "special"
        
    margin = MarginContainer.new()
    margin.rect_min_size.y = 5
    buttons.add_child(margin)
    buttons.add_child(difficulty_inp)
    margin = MarginContainer.new()
    margin.rect_min_size.y = 5
    buttons.add_child(margin)
    buttons.add_child(seed_inp)
    
    # ADD TOTAL
    level_nums.bbcode_text += "\nTOTAL"
    money_nums.bbcode_text += "\n$" + str(total_money)
    money_goal.bbcode_text += "\n$" + str(total_goal)
    
    # Move and resize to fit contents
    rect_position.y = 320 - 25 * len(G.money_per_level)
    rect_min_size.y = 30 + 40 * len(G.money_per_level)
    G.showing_menu = true
    show()

func play_clicked(btn):
    var level_to_play = button_to_level[btn]
    if typeof(level_to_play) == TYPE_STRING and level_to_play == "special":
        if seed_inp.text.is_valid_integer() and difficulty_inp.text.is_valid_integer():
            var seed_int = int(seed_inp.text)
            var difficulty_int = int(difficulty_inp.text)
            if seed_int > 0 and seed_int < 1000 and difficulty_int > 0 and difficulty_int < 100:
                G.special_seed = seed_int
                G.special_difficulty = difficulty_int
                emit_signal("play_level", level_to_play)
    else:
        emit_signal("play_level", level_to_play)
    
func hide_scores():
    G.showing_menu = false
    hide()
