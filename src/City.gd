extends Node2D

signal city_turn_processed
signal lose_level

var TileScene = preload("res://src/Tile.tscn")
var GuyScene = preload("res://src/Guy.tscn")
var HeartScene = preload("res://src/Heart.tscn")
var IcecreamScene = preload("res://src/Icecream.tscn")
var RoadblockScene = preload("res://src/Roadblock.tscn")

const street_len_min = 6
const street_len_max = 12
const choice_zero = 10
const generate_timeout_max = 0.2

var tiles = []
var passable_coords = []
var date_coords = []
var spawn_coords = []
var generate_timeout = generate_timeout_max
var turn_processed = true
var level_lost = false
var click_mode = "roadblock" # {icecream, roadblock, dateswap, null}
var icecream_preview
var roadblock_preview

func pos_to_float_coord(pos):
    return pos / G.tile_dim

func random_passable_coord():
    return passable_coords[randi() % len(passable_coords)]

func random_coord():
    return Vector2(randi() % G.grid_dim, randi() % G.grid_dim)

func tile_at_coord(coord):
    if coord.y >= len(tiles):
        return null
    elif coord.x >= len(tiles[coord.y]):
        return null
    return tiles[coord.y][coord.x]

func add_coords(c0, c1):
    var c_new = c0 + c1
    c_new.x = posmod(c_new.x, G.grid_dim)
    c_new.y = posmod(c_new.y, G.grid_dim)
    return c_new

func has_unpassable_neighborhood(coord):
    for d in G.dirs8:
        if add_coords(coord, d) in passable_coords:
            return false
    return true
    
func has_passable_neighbor(coord):
    for d in G.dirs4:
        if add_coords(coord, d) in passable_coords:
            return true
    return false

func may_become_passable(coord):
    # Cannot become passable twice (this also stops too many crossroads)
    if coord in passable_coords:
        return false
    # Do not allow 2x2 squares
    else:
        for tiles_3 in G.round_corners:
            var total = 0
            for tile in tiles_3:
                if add_coords(coord, tile) in passable_coords:
                    total += 1
            if total == 3:
                return false
    return true

func generate_street():
    # For fixed number of iterations, pick unpassable tile
    # and try to extend street segment to existing passable.
    # Guarantees connectedness of the final street grid.
    for _generate_try in range(100):
        # Pick unpassable coordinate to start from
        var start_coord = null
        for _try_unpassable in range(10):
            start_coord = random_coord()
            if not has_unpassable_neighborhood(start_coord):
                continue
        if start_coord == null or not has_unpassable_neighborhood(start_coord):
            continue
        # Generate segment from here, in both directions
        var dir = G.random_dir()
        var total_segment = []
        for _both_dirs in range(2):
            var segment = [start_coord]
            dir = -dir
            var this_coord = add_coords(start_coord, dir)
            for _tile_idx in range(street_len_min + randi() % (street_len_max - street_len_min)):
                segment.append(this_coord)
                if has_passable_neighbor(this_coord):
                    # Reached the street network!
                    if may_become_passable(this_coord):
                        # Only add this segment if the connection is good
                        add_street_segment(segment)
                        total_segment.append_array(segment)
                    break
                else:
                    this_coord = add_coords(this_coord, dir)
            if passable_coords.empty():
                # The first segment does not need to connect to the network
                total_segment.append_array(segment)
        add_street_segment(total_segment)
        return total_segment
    return null

func add_street_segment(segment):
    for coord in segment:
        tile_at_coord(coord).set_passable(true)
        passable_coords.append(coord)

func generate_streets(n_tries):
    for _add_street_iter in range(n_tries):
        generate_street()

func reset_city():
    var child_containers = [$Tiles, $Icecreams, $Roadblocks, $Guys]
    for child_container in child_containers:
        for child in child_container.get_children():
           child.queue_free()
    tiles = []
    passable_coords = []
    date_coords = []
    spawn_coords = []
    generate_timeout = generate_timeout_max
    turn_processed = true
    level_lost = false

func generate_city(level_nr):
    reset_city()
    seed(G.levels[level_nr - 1].seed)
    for row in range(G.grid_dim):
        var new_row = []
        for col in range(G.grid_dim):
            var new_tile = TileScene.instance().init(Vector2(col, row))
            new_row.append(new_tile)
        tiles.append(new_row)
    generate_streets(G.levels[level_nr - 1].streets)
    # Actually add tiles
    for row in tiles:
        for tile in row:
            $Tiles.add_child(tile)
            tile.update_sprite()
    connect("city_turn_processed", get_node("/root/Game"), "city_turn_processed")
    add_guys(G.levels[level_nr - 1].guys)
    

func get_unvisited_neighs(tile):
    var unvisited = []
    for dir in G.dirs4:
        var neigh_coord = add_coords(tile.coord, dir)
        var neigh = tile_at_coord(neigh_coord)
        if neigh.passable and neigh.visited_from == null:
            unvisited.append(neigh)
    return unvisited

func reset_path_search():
    for row in tiles:
        for tile in row:
            tile.visited_from = null
            tile.path_length = null

func shortest_path(c0, c1, max_length=INF, find_icecream=false):
    # If c0 is a Vector2D:
    #   Returns the shortest path between c0 and c1 as a list of coordinates including c0 and c1.
    #   Returns an empty path if c0 == c1
    # If c0 is an array of Vector2D:
    #   Returns the shortest path from any node on c0 to c1, starting from c0[0].
    #   Returns an empty path if c1 is on c0
    # Returns null if no path of length < max_length is possible
    # or c0 or c1 is null and find_icecream is false
    
    if c0 == c1:
        return []
    elif c0 == null or (c1 == null and not find_icecream):
        return null
    reset_path_search()
    # Start search
    var queue = []
    if typeof(c0) == TYPE_VECTOR2:
        var tile0 = tile_at_coord(c0)
        tile0.path_length = 0
        tile0.visited_from = tile0
        queue = [c0]
    elif typeof(c0) == TYPE_ARRAY:
        for c in c0:
            var t = tile_at_coord(c)
            t.path_length = 0
            t.visited_from = t
            queue.append(c)
    var add_count = 0
    while len(queue) > 0:
        var popped_coord = queue.pop_front()
        var popped_tile = tile_at_coord(popped_coord)
        if (c1 != null and popped_coord == c1) or \
            (find_icecream and popped_tile.icecream != null):
            var path = [popped_coord]
            var prev = popped_tile.visited_from
            while true:
                path.append(prev.coord)
                if prev.path_length == 0:
                    path.invert()
                    if typeof(c0) == TYPE_ARRAY:
                        # Add prefix of c0 until the start of the shortest path.
                        var branch_off_idx = c0.find(prev.coord)
                        if branch_off_idx > 0:
                            var prefix = c0.slice(0, branch_off_idx - 1)
                            prefix.append_array(path)
                            path = prefix
                    return path
                if prev == prev.visited_from:
                    assert(false)
                prev = prev.visited_from
        if popped_tile.path_length < max_length:
            for unvisited in get_unvisited_neighs(popped_tile):
                unvisited.visited_from = popped_tile
                unvisited.path_length = popped_tile.path_length + 1
                add_count += 1
                if add_count == 500:
                    assert(false)
                queue.append(unvisited.coord)
    return null

func shortest_path_without_coord(c0, c1, c_block):
    var block_tile = tiles[c_block.y][c_block.x]
    assert(block_tile.passable)
    block_tile.passable = false
    var new_shortest = shortest_path(c0, c1)
    block_tile.passable = true
    return new_shortest

func unblockable_paths(block_coord):
    # Returns the current shortest paths for which there would not be an
    # alternative when coord would be blocked
    var must_paths = []
    for guy in $Guys.get_children():
        if not guy.love_found:
            var alternative_path = shortest_path_without_coord(guy.coord, guy.date.coord, block_coord)
            if alternative_path == null:
                var current_path = shortest_path(guy.coord, guy.date.coord)
                must_paths.append(current_path)
    return must_paths

func random_passable():
    var coord = passable_coords[randi() % len(passable_coords)]
    var safety = 100
    while coord in date_coords or coord in spawn_coords:
        coord = passable_coords[randi() % len(passable_coords)]
        safety -= 1
        if safety == 0:
            return null
    return coord

func add_guys(n_guys):
    for guy_idx in n_guys:
        var date_coord
        var spawn_coord
        for _try_different in range(4):
            date_coord = random_passable()
            spawn_coord = random_passable()
            if date_coord != null and spawn_coord != null and (date_coord != spawn_coord):
                break 
        date_coords.append(date_coord)
        spawn_coords.append(spawn_coord)
        # init adds date to tile
        var date = HeartScene.instance().init(date_coord, self)
        date.set_guy_type(G.guy_types[guy_idx])
        $Dates.add_child(date)
        # init adds guy to tile
        var guy = GuyScene.instance().init(spawn_coord, self, date, G.guy_types[guy_idx])
        $Guys.add_child(guy)


func end_turn():
    turn_processed = false
    for guy in $Guys.get_children():
        guy.do_turn()

func tile_at_pos(mouse_pos):
    var coord_vec = mouse_pos / G.tile_dim
    coord_vec = coord_vec.floor()
    return tile_at_coord(coord_vec)

func passable_under_mouse():
    var mouse_pos = get_viewport().get_mouse_position()
    var hovered_tile = tile_at_pos(mouse_pos)
    if hovered_tile != null and hovered_tile.coord in passable_coords:
        return hovered_tile
    else:
        return null

func set_mode(new_mode):
    icecream_preview.visible = false
    roadblock_preview.visible = false
    if new_mode == "icecream":
        icecream_preview.visible = true
    elif new_mode == "roadblock":
        roadblock_preview.visible = true
    click_mode = new_mode

func _ready():
    icecream_preview = $Preview/Icecream
    roadblock_preview = $Preview/Roadblock

func _process(_delta):
    if not turn_processed:
        turn_processed = true
        var guys = $Guys.get_children()
        if len(guys) == 0:
            turn_processed = false
            if level_lost == false:
                level_lost = true
                emit_signal("lose_level")
        else:
            for guy in $Guys.get_children():
                if not guy.turn_processed or guy.love_found:
                    turn_processed = false
                    break
        if turn_processed:
            for icecream in $Icecreams.get_children():
                var icecream_tile = tile_at_coord(icecream.coord)
                if len(icecream_tile.guys) > 0:
                    icecream_tile.icecream = null
                    icecream.queue_free()
            for guy in $Guys.get_children():
                guy.update_path()
                guy.show_path_preview()
            emit_signal("city_turn_processed")
    
    var hovered_tile = passable_under_mouse()
    if click_mode == "icecream" and hovered_tile != null:
        icecream_preview.position = hovered_tile.position
        icecream_preview.visible = true
    else:
        icecream_preview.visible = false
    if click_mode == "roadblock" and hovered_tile != null:
        roadblock_preview.position = hovered_tile.position
        roadblock_preview.visible = true
    else:
        roadblock_preview.visible = false
        
#    generate_timeout -= delta
#    if generate_timeout < 0:
#        print("generating")
#        generate_timeout += generate_timeout_max
#        generate_street()

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        var hovered_tile = passable_under_mouse()
        if hovered_tile != null:
            if click_mode == "icecream":
                if hovered_tile.can_icecream():
                    var new_icecream = IcecreamScene.instance()
                    new_icecream.set_coord(hovered_tile.coord)
                    $Icecreams.add_child(new_icecream)
                    hovered_tile.set_icecream(new_icecream)
            elif click_mode == "roadblock":
                if hovered_tile.can_roadblock():
                    var prevent_paths = unblockable_paths(hovered_tile.coord)
                    if len(prevent_paths) > 0:
                        return
                    else:
                        var new_roadblock = RoadblockScene.instance()
                        new_roadblock.set_coord(hovered_tile.coord)
                        $Roadblocks.add_child(new_roadblock)
                        hovered_tile.set_roadblock(new_roadblock)
