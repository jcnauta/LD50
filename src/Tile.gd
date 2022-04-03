extends Node2D

var passable = false
var coord
var visited_from = null  # For depth-first search
var city
var road_tex
var house_tex

func init(init_coord):
    self.coord = init_coord
    self.position = init_coord * G.tile_dim
#    $Sprite.modulate = Color.red
    return self

func _ready():
    city = get_node("/root/Game/City")
    house_tex = ImageTexture.new()
    var house_img = Image.new()
    house_img.load("res://img/house_2.png")
    house_tex.create_from_image(house_img, 3)
    $SpriteHouse.texture = house_tex
    $SpriteHouse.visible = true
    
    road_tex = ImageTexture.new()
    var road_img = Image.new()
    road_img.load("res://img/Street_really_all_for_now.png")
    road_tex.create_from_image(road_img, 3)
    $SpriteRoad.texture = road_tex
    $SpriteRoad.visible = false

func set_passable(may_pass):
    passable = may_pass
    
func update_sprite():
    if passable:
        $SpriteHouse.visible = false
        $SpriteRoad.visible = true
        $SpriteRoad.texture = road_tex
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
