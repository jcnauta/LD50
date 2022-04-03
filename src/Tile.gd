extends Node2D


const house_img = preload("res://img/house_pale.png")
const road_img = preload("res://img/Street_really_all_for_now.png")

var passable = false
var placeable = false
var coord
var visited_from = null  # For depth-first search
var city

# Stuff (may be mutually exclusive) on this tile
var icecream = null
var roadblock = null
var date = null
var characters = []

func init(init_coord):
    self.coord = init_coord
    self.position = init_coord * G.tile_dim
#    $Sprite.modulate = Color.red
    return self

func _ready():
    city = get_node("/root/Game/City")
    
    house_img.flags = 3
    $SpriteHouse.texture = house_img
    $SpriteHouse.visible = true
    
    road_img.flags = 3
    $SpriteRoad.texture = road_img
    $SpriteRoad.visible = false

func set_passable(may_pass):
    passable = may_pass

func can_roadblock():
    return icecream == null and roadblock == null and date == null and characters.empty()

func can_icecream():
    return icecream == null and roadblock == null

func update_sprite():
    if passable:
        $SpriteHouse.visible = false
        $SpriteRoad.visible = true
        $SpriteRoad.texture = road_img
        $SpriteRoad.modulate = Color.white
        var neighs = {}
        for dir in G.dirs4:
            neighs[dir] = city.tile_at_coord(city.add_coords(coord, dir))
        var l = Vector2(-1, 0)
        var u = Vector2(0, -1)
        var r = Vector2(1, 0)
        var d = Vector2(0, 1)
        if neighs[l].passable and neighs[u].passable and neighs[r].passable and neighs[d].passable:
            $SpriteRoad.frame = 11
        elif neighs[l].passable and neighs[u].passable and neighs[r].passable:
            $SpriteRoad.frame = 13
        elif neighs[l].passable and neighs[d].passable and neighs[r].passable:
            $SpriteRoad.frame = 12
        elif neighs[l].passable and neighs[u].passable and neighs[d].passable:
            $SpriteRoad.frame = 15
        elif neighs[d].passable and neighs[u].passable and neighs[r].passable:
            $SpriteRoad.frame = 14
        elif neighs[l].passable and neighs[u].passable:
            $SpriteRoad.frame = 0
        elif neighs[r].passable and neighs[u].passable:
            $SpriteRoad.frame = 1
        elif neighs[l].passable and neighs[d].passable:
            $SpriteRoad.frame = 2
        elif neighs[r].passable and neighs[d].passable:
            $SpriteRoad.frame = 3
        elif neighs[u].passable and neighs[d].passable:
            $SpriteRoad.frame = 5
        elif neighs[l].passable and neighs[r].passable:
            $SpriteRoad.frame = 4
        elif neighs[l].passable:
            $SpriteRoad.frame = 9
        elif neighs[u].passable:
            $SpriteRoad.frame = 6
        elif neighs[r].passable:
            $SpriteRoad.frame = 7
        elif neighs[d].passable:
            $SpriteRoad.frame = 8
        else:
            $SpriteRoad.frame = 10
