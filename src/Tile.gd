extends Node2D

var passable = false
var coord
var visited_from = null  # For depth-first search
var city

func init(init_coord):
    self.coord = init_coord
    self.position = init_coord * G.tile_dim
    $Sprite.modulate = Color.red
    return self

func _ready():
    city = get_node("/root/Game/City")

func set_passable(may_pass):
    passable = may_pass
    
func update_sprite():
    if passable:
        $Sprite.modulate = Color.white
        var neighs = {}
        for dir in G.dirs4:
            neighs[dir] = city.tile_at_coord(city.add_coords(coord, dir))
        var l = Vector2(-1, 0)
        var u = Vector2(0, -1)
        var r = Vector2(1, 0)
        var d = Vector2(0, 1)
        if neighs[l].passable and neighs[u].passable and neighs[r].passable and neighs[d].passable:
            $Sprite.frame = 11
        elif neighs[l].passable and neighs[u].passable and neighs[r].passable:
            $Sprite.frame = 13
        elif neighs[l].passable and neighs[d].passable and neighs[r].passable:
            $Sprite.frame = 12
        elif neighs[l].passable and neighs[u].passable and neighs[d].passable:
            $Sprite.frame = 15
        elif neighs[d].passable and neighs[u].passable and neighs[r].passable:
            $Sprite.frame = 14
        elif neighs[l].passable and neighs[u].passable:
            $Sprite.frame = 0
        elif neighs[r].passable and neighs[u].passable:
            $Sprite.frame = 1
        elif neighs[l].passable and neighs[d].passable:
            $Sprite.frame = 2
        elif neighs[r].passable and neighs[d].passable:
            $Sprite.frame = 3
        elif neighs[u].passable and neighs[d].passable:
            $Sprite.frame = 5
        elif neighs[l].passable and neighs[r].passable:
            $Sprite.frame = 4
        elif neighs[l].passable:
            $Sprite.frame = 9
        elif neighs[u].passable:
            $Sprite.frame = 6
        elif neighs[r].passable:
            $Sprite.frame = 7
        elif neighs[d].passable:
            $Sprite.frame = 8
        else:
            $Sprite.frame = 10
