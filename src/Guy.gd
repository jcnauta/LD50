extends Node2D

signal pickup_balloon
signal path_preview_updated

var coord = null
var dest_coord = null
var move_coord = null
var tile_speed = 6
var tile_speed_increase = 2
var animate_speed = 20
var pixel_speed = animate_speed * G.tile_dim
var timeout = 0.05
var city
var full_path = null  # full path to destination
var move_path = null  # partial path only for the next move
var icecream_path = null
var walk_prev_idx = null
var walk_next_idx = null
var animate_to_move_coord = false
var turn_processed = false
var date = null
var love_found = false
var guy_type
var sprite

const gpo = 4
const path_offset = {
    "lion": Vector2(gpo, gpo),
    "frog": Vector2(gpo, -gpo),
    "robot": Vector2(-gpo, -gpo),
    "penguin": Vector2(-gpo, gpo),
   }
const small_dot = 10
const big_dot = 20

const love_sounds = {
    "lion": preload("res://sounds/find_love_loewi.mp3"),
    "frog": preload("res://sounds/find_love_frog.mp3"),
    "robot": preload("res://sounds/find_love_robot_bzzz.mp3"),
    "penguin": preload("res://sounds/find_love_pingu.mp3"),
   }

func _ready():
    $PathPreview.set_as_toplevel(true)
    $IcecreamPreview.set_as_toplevel(true)

func init(new_coord, new_city, new_date, new_guy_type):
    city = new_city
    set_date(new_date)
    set_coord(new_coord)
    set_guy_type(new_guy_type)
    update_path()
    show_path_preview()
    return self

func set_coord(new_coord):
    if coord != null:
        var old_tile = city.tile_at_coord(coord)
        old_tile.remove_guy(self)
    var new_tile = city.tile_at_coord(new_coord)
    new_tile.add_guy(self)
    self.coord = new_coord
    self.position = new_coord * G.tile_dim
    if self.coord == date.coord:
        self.found_love()

func found_love():
    if love_found:
        return
    love_found = true
    emit_signal("path_preview_updated", self.guy_type, 0)
    $Sounds/FindLove.play()
    date.found_love()
    $Tween.interpolate_property(sprite, "modulate",
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.5,
        Tween.TRANS_LINEAR, Tween.EASE_IN)
    $Tween.connect("tween_all_completed", self, "queue_free")
    $Tween.start()

func set_destination(new_coord):
    if dest_coord != new_coord:
        dest_coord = new_coord
        
func set_date(new_date):
    self.date = new_date
    set_destination(new_date.coord)

func set_guy_type(new_type):
    guy_type = new_type
    $Sounds/FindLove.stream = love_sounds[new_type]
    for spr in $Sprites.get_children():
        spr.visible = false
    if guy_type == "lion":
        sprite = $Sprites/Lion
        sprite.visible = true
    if guy_type == "frog":
        sprite = $Sprites/Frog
        sprite.visible = true
    if guy_type == "robot":
        sprite = $Sprites/Robot
        sprite.visible = true
    if guy_type == "penguin":
        sprite = $Sprites/Penguin
        sprite.visible = true

func update_path():
    full_path = []
    var date_path = city.shortest_path(coord, dest_coord)
    if date_path == null:
        return null
    move_path = date_path.slice(0, min(tile_speed, len(date_path) - 1))
    var move_icecream_path = city.shortest_path(move_path, null, G.max_icecream_path_length, true)
    if move_icecream_path != null:
        full_path.append_array(move_icecream_path)
    if dest_coord != null:
        if len(full_path) == 0:
            full_path.append_array(date_path)
        else:
            var path_from_icecream = city.shortest_path(full_path.back(), dest_coord)
            if path_from_icecream != null:
                full_path.append_array(path_from_icecream.slice(1, len(path_from_icecream)))
        if len(full_path) > 1:
            move_path = full_path.slice(0, min(tile_speed, len(full_path) - 1))
            walk_prev_idx = 0
            walk_next_idx = 1
        else:
            turn_processed = true
    if len(full_path) == 0:
        move_path = []
        walk_prev_idx = null
        walk_next_idx = null
        turn_processed = true

func show_icecream_path_preview(maybe_icecream_coord):
    print("showing")
    icecream_path = city.shortest_path(full_path, maybe_icecream_coord, G.max_icecream_path_length, false)
    for c in $IcecreamPreview.get_children():
        c.queue_free()
    if icecream_path != null:
        for c in icecream_path:
            var path_dot = ColorRect.new()
            path_dot.rect_size = small_dot * Vector2(1, 1)
            path_dot.rect_position = c * G.tile_dim + Vector2(13, 13)
            path_dot.modulate = Color(1, 1, 1, 0.8)
            $IcecreamPreview.add_child(path_dot)

func show_path_preview():
    var turns_left = 1
    for c in $PathPreview.get_children():
        c.queue_free()
    var simulated_speed = tile_speed
    var simulated_steps = 0
    for c in full_path:
        var tile = city.tile_at_coord(c)
        var path_dot = ColorRect.new()
        if simulated_steps == simulated_speed or tile.icecream != null:
            if c != full_path[-1]:
                turns_left += 1
            path_dot.rect_size = big_dot * Vector2(1, 1)
            path_dot.rect_position = c * G.tile_dim + Vector2(13, 13) + path_offset[guy_type]
            path_dot.rect_position -= 0.5 * (big_dot - small_dot) * Vector2(1, 1)
            simulated_steps = 0
            simulated_speed += tile_speed_increase
            path_dot.modulate = Color(1, 1, 1, 0.7)
        else:
            path_dot.rect_size = small_dot * Vector2(1, 1)
            path_dot.rect_position = c * G.tile_dim + Vector2(13, 13) + path_offset[guy_type]
            path_dot.modulate = Color(1, 1, 1, 0.5)
        simulated_steps += 1
        path_dot.color = G.guy_colors[guy_type]
        $PathPreview.add_child(path_dot)
    emit_signal("path_preview_updated", self.guy_type, turns_left)
    
func shift_walk():
    # Pick up balloon
    var coord_here = move_path[walk_next_idx]
    var tile_here = city.tile_at_coord(coord_here)
    if tile_here.balloon != null:
        emit_signal("pickup_balloon", tile_here)
    if walk_next_idx >= len(move_path) - 1:
        # We reached the move destination
        set_coord(move_path[len(move_path) - 1])
        walk_prev_idx = walk_next_idx
        return true
    else:
        walk_prev_idx += 1
        walk_next_idx += 1
        if city.tile_at_coord(move_path[walk_prev_idx]).icecream != null:
            set_coord(move_path[walk_prev_idx])
            return true
        return false

func do_turn():
    turn_processed = false
    update_path()
    animate_to_move_coord = true
    tile_speed += tile_speed_increase
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
