extends HBoxContainer

var guy_type

func set_guy_type(new_guy_type):
    guy_type = new_guy_type
    $Portrait.texture = G.guy_imgs[guy_type]

func set_turns(n_turns):
    var text: String
    if n_turns == 0:
        text = "found love"
    elif n_turns == 1:
        text = "[color=red]1 turn left[/color]"
    else:
        text = str(n_turns) + " turns left"
    $VBoxContainer/Turns.bbcode_text = text
