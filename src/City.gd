extends Node2D

var TileScene = preload("res://src/Tile.tscn")

const street_len_min = 6
const street_len_max = 12
var tiles = []
var passable_coords = []
const choice_zero = 10

var generate_timeout_max = 0.2
var generate_timeout = generate_timeout_max

func random_coord():
    return Vector2(randi() % G.grid_dim, randi() % G.grid_dim)

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
    # Pick unpassable coordinate to start from
    var start_coord = null
    for try_unpassable in range(10):
        start_coord = random_coord()
        if not has_unpassable_neighborhood(start_coord):
            continue
    if start_coord == null or not has_unpassable_neighborhood(start_coord):
        return null
    # Generate segment from here, in both directions
    var dir = G.random_dir()
    var total_segment = []
    for both_dirs in range(2):
        var segment = [start_coord]
        dir = -dir
        var this_coord = add_coords(start_coord, dir)
        for _tile_idx in range(street_len_min + randi() % (street_len_max - street_len_min)):
            segment.append(this_coord)
            if may_become_passable(this_coord) and has_passable_neighbor(this_coord):
                # Reached the street network!
                add_street_segment(segment)
                break
            elif not may_become_passable(this_coord):
                # We reached the street network in a wonky way. Abort!
                break
            else:
                this_coord = add_coords(this_coord, dir)
        if passable_coords.empty():
            # The first segment does not need to connect to the network
            total_segment.append_array(segment)
    add_street_segment(total_segment)

func add_street_segment(segment):
    for coord in segment:
        tiles[coord.y][coord.x].set_passable(true)
        passable_coords.append(coord)

func generate_streets(n_tries):
    # For fixed number of iterations, pick unpassable tile
    # and try to extend street segment to existing passable.
    # This ensures connectedness of the final street grid.
    for add_street_iter in range(n_tries):
        generate_street()

func generate_city(n_street_attempts = 0, randness = 0):
    seed(randness)
    for row in range(G.grid_dim):
        var new_row = []
        for col in range(G.grid_dim):
            var new_tile = TileScene.instance().init(Vector2(col, row))
            new_row.append(new_tile)
        tiles.append(new_row)
    generate_streets(n_street_attempts)

func _ready():
    generate_city(300, 2)
    for row in tiles:
        for tile in row:
            $Tiles.add_child(tile)

#func _process(delta):
#    generate_timeout -= delta
#    if generate_timeout < 0:
#        print("generating")
#        generate_timeout += generate_timeout_max
#        generate_street()
