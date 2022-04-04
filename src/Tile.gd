extends Node2D


const house_img_1 = preload("res://img/spreadsheets_houses/houses_spreadsheet_1.png")
const house_img_2 = preload("res://img/spreadsheets_houses/houses_spreadsheet_2.png")
const house_img_3 = preload("res://img/spreadsheets_houses/houses_spreadsheet_3.png")
const water_img = preload("res://img/River_all.png")
const road_img = preload("res://img/Street_all_dark green.png")

var passable = false
var placeable = false
var coord
var visited_from = null  # For depth-first search
var path_length = null  # For ice cream search
var city
var tt

# Stuff (may be mutually exclusive) on this tile
var icecream = null
var roadblock = null
var date = null
var balloon = null
var guys = []

func init(init_coord):
    self.coord = init_coord
    self.position = init_coord * G.tile_dim
    return self

func _ready():
    city = get_node("/root/Game/City")
    
    house_img_1.flags = 3
    house_img_2.flags = 3
    house_img_3.flags = 3
    if randf() < 0.33:
        $SpriteHouse.texture = house_img_1
    elif randf() < 0.5:
        $SpriteHouse.texture = house_img_2
    else:
        $SpriteHouse.texture = house_img_3
    $SpriteHouse.visible = true
    
    water_img.flags = 3
    $SpriteWater.texture = water_img
    $SpriteWater.visible = true
    
    road_img.flags = 3
    $SpriteRoad.texture = road_img
    $SpriteRoad.visible = false

func set_passable(may_pass):
    passable = may_pass

func can_roadblock():
    return icecream == null and roadblock == null and date == null and guys.empty()

func can_icecream():
    return icecream == null and roadblock == null

func set_icecream(new_icecream):
    assert(can_icecream())
    icecream = new_icecream
    
func set_roadblock(new_roadblock):
    assert(can_roadblock())
    roadblock = new_roadblock
    set_passable(false)

func add_guy(guy):
    assert(guys.find(guy) == -1)
    guys.append(guy)

func remove_guy(guy):
    guys.remove(guys.find(guy))

func set_date(new_date):
    assert(date == null)
    date = new_date
    
func clear_date(old_date):
    assert(date == old_date)
    date = null

func add_balloon(new_balloon):
    balloon = new_balloon

func set_type(new_tt):
    tt = new_tt

func update_sprite():
    var l = Vector2(-1, 0)
    var u = Vector2(0, -1)
    var r = Vector2(1, 0)
    var d = Vector2(0, 1)
    var neighs = {}
    for dir in G.dirs4:
        neighs[dir] = city.tile_at_coord(city.add_coords(coord, dir))
    if tt == "road":
        $SpriteHouse.visible = false
        $SpriteWater.visible = false
        $SpriteRoad.visible = true
        $SpriteRoad.texture = road_img
        if neighs[l].tt == "road" and neighs[u].tt == "road" and \
                neighs[r].tt == "road" and neighs[d].tt == "road":
            $SpriteRoad.frame = 11
        elif neighs[l].tt == "road" and neighs[u].tt == "road" and neighs[r].tt == "road":
            $SpriteRoad.frame = 13
        elif neighs[l].tt == "road" and neighs[d].tt == "road" and neighs[r].tt == "road":
            $SpriteRoad.frame = 12
        elif neighs[l].tt == "road" and neighs[u].tt == "road" and neighs[d].tt == "road":
            $SpriteRoad.frame = 15
        elif neighs[d].tt == "road" and neighs[u].tt == "road" and neighs[r].tt == "road":
            $SpriteRoad.frame = 14
        elif neighs[l].tt == "road" and neighs[u].tt == "road":
            $SpriteRoad.frame = 0
        elif neighs[r].tt == "road" and neighs[u].tt == "road":
            $SpriteRoad.frame = 1
        elif neighs[l].tt == "road" and neighs[d].tt == "road":
            $SpriteRoad.frame = 2
        elif neighs[r].tt == "road" and neighs[d].tt == "road":
            $SpriteRoad.frame = 3
        elif neighs[u].tt == "road" and neighs[d].tt == "road":
            $SpriteRoad.frame = 5
        elif neighs[l].tt == "road" and neighs[r].tt == "road":
            $SpriteRoad.frame = 4
        elif neighs[l].tt == "road":
            $SpriteRoad.frame = 9
        elif neighs[u].tt == "road":
            $SpriteRoad.frame = 6
        elif neighs[r].tt == "road":
            $SpriteRoad.frame = 7
        elif neighs[d].tt == "road":
            $SpriteRoad.frame = 8
        else:
            $SpriteRoad.frame = 10
    elif tt == "house":
        $SpriteHouse.visible = true
        $SpriteWater.visible = false
        $SpriteRoad.visible = false
        if neighs[l].tt == "house" and neighs[u].tt == "house" and \
                neighs[r].tt == "house" and neighs[d].tt == "house":
            $SpriteHouse.frame = 11
        elif neighs[l].tt == "house" and neighs[u].tt == "house" and neighs[r].tt == "house":
            $SpriteHouse.frame = 13
        elif neighs[l].tt == "house" and neighs[d].tt == "house" and neighs[r].tt == "house":
            $SpriteHouse.frame = 12
        elif neighs[l].tt == "house" and neighs[u].tt == "house" and neighs[d].tt == "house":
            $SpriteHouse.frame = 15
        elif neighs[d].tt == "house" and neighs[u].tt == "house" and neighs[r].tt == "house":
            $SpriteHouse.frame = 14
        elif neighs[l].tt == "house" and neighs[u].tt == "house":
            $SpriteHouse.frame = 0
        elif neighs[r].tt == "house" and neighs[u].tt == "house":
            $SpriteHouse.frame = 1
        elif neighs[l].tt == "house" and neighs[d].tt == "house":
            $SpriteHouse.frame = 2
        elif neighs[r].tt == "house" and neighs[d].tt == "house":
            $SpriteHouse.frame = 3
        elif neighs[u].tt == "house" and neighs[d].tt == "house":
            $SpriteHouse.frame = 5
        elif neighs[l].tt == "house" and neighs[r].tt == "house":
            $SpriteHouse.frame = 4
        elif neighs[l].tt == "house":
            $SpriteHouse.frame = 9
        elif neighs[u].tt == "house":
            $SpriteHouse.frame = 6
        elif neighs[r].tt == "house":
            $SpriteHouse.frame = 7
        elif neighs[d].tt == "house":
            $SpriteHouse.frame = 8
        else:
            $SpriteHouse.frame = 10
    elif tt == "water":
        $SpriteHouse.visible = false
        $SpriteWater.visible = true
        $SpriteRoad.visible = false
        if neighs[l].tt == "water" and neighs[u].tt == "water" and \
                neighs[r].tt == "water" and neighs[d].tt == "water":
            $SpriteWater.frame = 11
        elif neighs[l].tt == "water" and neighs[u].tt == "water" and neighs[r].tt == "water":
            $SpriteWater.frame = 13
        elif neighs[l].tt == "water" and neighs[d].tt == "water" and neighs[r].tt == "water":
            $SpriteWater.frame = 12
        elif neighs[l].tt == "water" and neighs[u].tt == "water" and neighs[d].tt == "water":
            $SpriteWater.frame = 15
        elif neighs[d].tt == "water" and neighs[u].tt == "water" and neighs[r].tt == "water":
            $SpriteWater.frame = 14
        elif neighs[l].tt == "water" and neighs[u].tt == "water":
            $SpriteWater.frame = 0
        elif neighs[r].tt == "water" and neighs[u].tt == "water":
            $SpriteWater.frame = 1
        elif neighs[l].tt == "water" and neighs[d].tt == "water":
            $SpriteWater.frame = 2
        elif neighs[r].tt == "water" and neighs[d].tt == "water":
            $SpriteWater.frame = 3
        elif neighs[u].tt == "water" and neighs[d].tt == "water":
            $SpriteWater.frame = 5
        elif neighs[l].tt == "water" and neighs[r].tt == "water":
            $SpriteWater.frame = 4
        elif neighs[l].tt == "water":
            $SpriteWater.frame = 9
        elif neighs[u].tt == "water":
            $SpriteWater.frame = 6
        elif neighs[r].tt == "water":
            $SpriteWater.frame = 7
        elif neighs[d].tt == "water":
            $SpriteWater.frame = 8
        else:
            $SpriteWater.frame = 10
    else:
        assert(false)
