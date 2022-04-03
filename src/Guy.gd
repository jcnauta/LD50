extends Node2D

var coord = null
var dest_coord = null
var move_coord = null
var tile_speed = 10
var animate_speed = 20
var pixel_speed = animate_speed * G.tile_dim
var timeout = 0.05
var city
var full_path = null  # full path to destination
var move_path = null  # partial path only for the next move
var walk_prev_idx = null
var walk_next_idx = null
var animate_to_move_coord = false
var turn_processed = false
var date = null
var love_found = false

func init(coord, city, date):
    self.city = city
    set_date(date)
    set_coord(coord)
    return self

func set_coord(new_coord):
    self.coord = new_coord
    self.position = new_coord * G.tile_dim
    if self.coord == date.coord:
        self.found_love()

func found_love():
    if love_found:
        return
    love_found = true
    date.found_love()
    $Tween.interpolate_property($Sprite, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.1,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.connect("tween_all_completed", self, "queue_free")
    $Tween.start()

func set_destination(coord):
    if dest_coord != coord:
        dest_coord = coord
        
func set_date(date):
    self.date = date
    set_destination(date.coord)

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
            turn_processed = true
    else:
        full_path = []
        move_path = []
        walk_prev_idx = null
        walk_next_idx = null
        turn_processed = true

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
    if animate_to_move_coord:
        if (move_path != null) and (walk_next_idx != null) and (walk_prev_idx != null):
            var walk_pixels = pixel_speed * delta
            while walk_pixels > 0:
                var walk_next = move_path[walk_next_idx]
                var walk_prev = move_path[walk_prev_idx]
                var walk_dir = walk_next - walk_prev
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
                var walk_to_corner = walk_next - city.pos_to_float_coord(position)
                var pixels_to_corner = G.tile_dim * walk_to_corner.length()
                var pixels_left_after_corner = walk_pixels - pixels_to_corner
                if pixels_left_after_corner >= 0:
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
                    var pixels_straight_vec = walk_pixels * walk_dir
                    self.position = Vector2(
                        wrapf(self.position.x + pixels_straight_vec.x, 0.0, G.tile_dim * G.grid_dim),
                        wrapf(self.position.y + pixels_straight_vec.y, 0.0, G.tile_dim * G.grid_dim)
                        )
                    walk_pixels = 0
