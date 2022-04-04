extends VBoxContainer

var GuyPrognosisScene = preload("res://src/GuyPrognosis.tscn")
var guy_progs = {}  # Guy types to GuyPrognosis instances


func set_prognoses(new_progs):
    for prog in get_children():
        prog.queue_free()
    guy_progs = {}
    # Takes dictionary with e.g. "lion": 3 entries.
    for guy_type in new_progs:
        var new_prog = GuyPrognosisScene.instance()
        new_prog.set_guy_type(guy_type)
        add_child(new_prog)
        guy_progs[guy_type] = new_prog
        guy_progs[guy_type].set_turns(new_progs[guy_type])
        
