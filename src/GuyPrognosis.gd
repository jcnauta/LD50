extends HBoxContainer

var guy_type

func set_guy_type(new_guy_type):
    guy_type = new_guy_type
    $TextureRect.texture = null
