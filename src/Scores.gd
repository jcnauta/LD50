extends Control

signal play_level

var button_to_level = {}

func show_scores(money_per_level, current_level):
#    money_per_level = {
#        1: 2, 
#        2: 2,
#        3: 243,
#        4: 947,
##        5: 13,
##        6: 35,
##        7: 21,
##        8: 8,
##        9: 14
#       }
    var turn_nums = $VBoxContainer/HBoxContainer/TurnNumbers
    var level_nums = $VBoxContainer/HBoxContainer/LevelNumbers
    turn_nums.bbcode_text = "[right]"
    level_nums.bbcode_text = ""
    var total_money = 0
    for lvl in money_per_level:
        if lvl == current_level:
            level_nums.bbcode_text += "[color=green]"
            turn_nums.bbcode_text += "[color=green]"
        level_nums.bbcode_text += "Neighborhood " + str(lvl) + "\n"
        turn_nums.bbcode_text += "$" + str(money_per_level[lvl]) + "\n"
        if lvl == current_level:
            level_nums.bbcode_text += "[/color]"
            turn_nums.bbcode_text += "[/color]"
        total_money += money_per_level[lvl]
    # ADD NEXT LEVEL AND TOTAL
    if len(money_per_level) < len(G.levels):
        level_nums.bbcode_text += "Neighborhood " + str(len(money_per_level) + 1) + "\n"
        turn_nums.bbcode_text += "-\n"
    level_nums.bbcode_text += "\nTOTAL: "
    turn_nums.bbcode_text += "\n$" + str(total_money) + "[/right]"
    # ADD BUTTONS
    var buttons = $VBoxContainer/HBoxContainer/Buttons
    for ch in buttons.get_children():
        buttons.remove_child(ch)
    var margin = MarginContainer.new()
    margin.rect_min_size.y = 11
    buttons.add_child(margin)
    var buttons_to_add = len(money_per_level)
    if len(money_per_level) < len(G.levels):
        buttons_to_add += 1
    for lvl_nr in buttons_to_add:
        var new_button = Button.new()
        new_button.text = "Play"
        buttons.add_child(new_button)
        new_button.connect("button_up", self, "play_clicked", [new_button])
        button_to_level[new_button] = lvl_nr + 1
        margin = MarginContainer.new()
        margin.rect_min_size.y = 22
        buttons.add_child(margin)
    # Move and resize to fit contents
    rect_position.y = 325 - 25 * len(money_per_level)
    rect_min_size.y = 40 * len(money_per_level)
    show()

func play_clicked(btn):
    var level_to_play = button_to_level[btn]
    emit_signal("play_level", level_to_play)
    hide()
