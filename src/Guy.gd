extends Node2D

var coord = null
var dest_coord = null
var speed = 10
var pixel_speed = speed * G.tile_dim
var timeout = 0.05
var city
var path = null
var walk_prev_idx = null
var walk_next_idx = null
var animate_to_destination = true
var active_sprite = null

func init(coord, city):
    self.city = city
    set_coord(coord)
    active_sprite = $SpriteNW
    return self

func set_destination(coord):
    if dest_coord != coord:
        dest_coord = coord
        update_path()
        walk_prev_idx = 0
        walk_next_idx = 1

func update_path():
    if dest_coord != null:
        self.path = city.shortest_path(self.coord, dest_coord)
        for p in self.path:
            var tile = city.tile_at_coord(p)
            tile.modulate = Color.green
    else:
        self.path = []

func shift_walk():
    if walk_next_idx < len(path) - 1:
        walk_prev_idx += 1
        walk_next_idx += 1
    else:
        # We reached the destination
        walk_prev_idx = null
        walk_prev_idx = null
        path = null
        print("REACHED DESTINATION")

func _physics_process(delta):
    if Input.is_physical_key_pressed(KEY_SPACE) and dest_coord == null:
        print("Set coord")
        set_destination(city.random_passable_coord())
    if animate_to_destination:
        if (path != null) and (walk_next_idx != null) and (walk_prev_idx != null):
            var walk_pixels = pixel_speed * delta
            while walk_pixels > 0:
                var walk_next = path[walk_next_idx]
                var walk_prev = path[walk_prev_idx]
                var walk_dir = path[walk_next_idx] - path[walk_prev_idx]
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
                    print(pixels_left_after_corner)
                    self.position = walk_next * G.tile_dim
                    walk_pixels -= pixels_to_corner
                    shift_walk()
                    if path == null:
                        walk_pixels = 0
                        break
                else:
                    self.position = Vector2(
                        wrapf(self.position.x + pixels_straight_vec.x, 0.0, G.tile_dim * G.grid_dim),
                        wrapf(self.position.y + pixels_straight_vec.y, 0.0, G.tile_dim * G.grid_dim)
                        )
                    walk_pixels = 0

func set_coord(new_coord):
    self.coord = new_coord
    self.position = new_coord * G.tile_dim
