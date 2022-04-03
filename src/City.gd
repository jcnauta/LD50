extends Node2D

signal city_turn_processed
signal lose_level

var TileScene = preload("res://src/Tile.tscn")
var GuyScene = preload("res://src/Guy.tscn")
var HeartScene = preload("res://src/Heart.tscn")

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
var click_mode = "icecream"

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
    for generate_try in range(100):
        # Pick unpassable coordinate to start from
        var start_coord = null
        for try_unpassable in range(10):
            start_coord = random_coord()
            if not has_unpassable_neighborhood(start_coord):
                continue
        if start_coord == null or not has_unpassable_neighborhood(start_coord):
            continue
        # Generate segment from here, in both directions
        var dir = G.random_dir()
        var total_segment = []
        for both_dirs in range(2):
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
    for add_street_iter in range(n_tries):
        generate_street()

func reset_city():
    var child_containers = [$Tiles, $Stuff, $Guys]
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

func shortest_path(c0, c1):
    if c0 == c1:
        return []
    elif c0 == null or c1 == null:
        return null
    # Reset DFS info
    for row in tiles:
        for tile in row:
            tile.visited_from = null
    # Start search
    var queue = [c0]
    var found = false
    while not found and len(queue) > 0:
        var popped_coord = queue.pop_front()
        var popped_tile = tile_at_coord(popped_coord)
        if popped_coord == c1:
            var path = [c1]
            var prev = tile_at_coord(c1).visited_from
            while true:
                path.append(prev.coord)
                if prev.coord == c0:
                    path.invert()
                    return path
                prev = prev.visited_from
        for unvisited in get_unvisited_neighs(popped_tile):
            unvisited.visited_from = popped_tile
            queue.append(unvisited.coord)
    return null

func free_passable():
    var coord = passable_coords[randi() % len(passable_coords)]
    var safety = 100
    while coord in date_coords or coord in spawn_coords:
        coord = passable_coords[randi() % len(passable_coords)]
        print(coord)
        safety -= 1
        if safety == 0:
            return null
    return coord

func add_guys(n_guys):
    for guy_idx in n_guys:
        var date_coord
        var spawn_coord
        for try_different in range(4):
            date_coord = free_passable()
            spawn_coord = free_passable()
            if date_coord != null and spawn_coord != null and (date_coord != spawn_coord):
                break 
        date_coords.append(date_coord)
        spawn_coords.append(spawn_coord)
        var date = HeartScene.instance().init(date_coord)
        $Stuff.add_child(date)
        var guy = GuyScene.instance().init(spawn_coord, self, date)
        $Guys.add_child(guy)

func end_turn():
    turn_processed = false
    for guy in $Guys.get_children():
        guy.do_turn()

func tile_at_pos(mouse_pos):
    var coord_vec = mouse_pos / G.tile_dim
    coord_vec = coord_vec.floor()
    return tile_at_coord(coord_vec)

func _process(delta):
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
            emit_signal("city_turn_processed")
    if click_mode == "icecream":
        var mouse_pos = get_viewport().get_mouse_position()
        var hovered_tile = tile_at_pos(mouse_pos)
        if hovered_tile != null:
            hovered_tile.modulate = Color.black
#    generate_timeout -= delta
#    if generate_timeout < 0:
#        print("generating")
#        generate_timeout += generate_timeout_max
#        generate_street()
