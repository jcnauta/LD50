extends Node2D

var coord = null
var dest_coord = null
var move_coord = null
var tile_speed = 1
var animate_speed = 5
var pixel_speed = animate_speed * G.tile_dim
var timeout = 0.05
var city
var full_path = null  # full path to destination
var move_path = null  # partial path only for the next move
var walk_prev_idx = null
var walk_next_idx = null
var animate_to_move_coord = false
var active_sprite = null
var turn_processed = false
var prev_pos = null

func init(coord, city):
    self.city = city
    set_coord(coord)
    active_sprite = $SpriteNW
    return self

func set_coord(new_coord):
    self.coord = new_coord
    self.position = new_coord * G.tile_dim
    self.prev_pos = position

func set_destination(coord):
    if dest_coord != coord:
        dest_coord = coord

func update_path():
    if dest_coord != null:
        full_path = city.shortest_path(self.coord, dest_coord)
        for p in full_path:
            var tile = city.tile_at_coord(p)
            tile.modulate = Color.green
        if len(full_path) > 1:
            move_path = full_path.slice(0, min(tile_speed, len(full_path) - 1))
            walk_prev_idx = 0
            walk_next_idx = 1
    else:
        full_path = []
        move_path = []
        walk_prev_idx = null
        walk_next_idx = null

func shift_walk():
    if walk_next_idx < len(move_path) - 1:
        walk_prev_idx += 1
        walk_next_idx += 1
        return false
    else:
        # We reached the move destination
        set_coord(move_path[len(move_path) - 1])
        walk_prev_idx = walk_next_idx
        return true


func do_turn():
    turn_processed = false
    update_path()
    animate_to_move_coord = true
    tile_speed += 1
    animate_speed += 1.5

func _process(delta):
    if Input.is_physical_key_pressed(KEY_SPACE) and dest_coord == null:
        set_destination(city.random_passable_coord())
    if animate_to_move_coord:
        if (move_path != null) and (walk_next_idx != null) and (walk_prev_idx != null):
            var walk_pixels = pixel_speed * delta
            while walk_pixels > 0:
                var walk_next = move_path[walk_next_idx]
                var walk_prev = move_path[walk_prev_idx]
                var walk_dir = move_path[walk_next_idx] - move_path[walk_prev_idx]
                walk_dir.round()
                # Fix direction in case of wrap
                if walk_dir.x >= 2:
                    walk_dir.x = -1
                elif walk_dir.x <= -2:
                    walk_dir.x = 1
                if walk_dir.y >= 2:
                    walk_dir.y = -1
                elif walk_dir.y <= -2:
                    walk_dir.y = 1
                var pixels_straight_vec = walk_pixels * walk_dir
                var pixels_straight = pixels_straight_vec.length()
                var walk_to_corner = walk_next - city.pos_to_float_coord(position)
                var pixels_to_corner = G.tile_dim * walk_to_corner.length()
                var pixels_left_after_corner = pixels_straight - pixels_to_corner
                if pixels_left_after_corner > 0:
                    # Pass by the next tile on the move_path
                    self.position = walk_next * G.tile_dim
                    walk_pixels -= pixels_to_corner
                    var walk_done = shift_walk()
                    if walk_done:
                        # Animation is done
                        walk_pixels = 0
                        animate_to_move_coord = false
                        turn_processed = true
                        break
                else:
                    # End of this _process's move
                    self.position = Vector2(
                        wrapf(self.position.x + pixels_straight_vec.x, 0.0, G.tile_dim * G.grid_dim),
                        wrapf(self.position.y + pixels_straight_vec.y, 0.0, G.tile_dim * G.grid_dim)
                        )
                    walk_pixels = 0
#            print("positions")
#            print(position)
#            print(prev_pos)
#            if position == prev_pos:
#                # Not moving means animation (and the turn for this guy) is done
#                animate_to_move_coord = false
#                turn_processed = true
#            prev_pos = position
