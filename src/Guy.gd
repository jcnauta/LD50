extends Node2D

var coord = null
var dest_coord = null
var speed = 1
var pixel_speed = speed * G.tile_dim
var timeout = 0.05
var city
var path = null
var walk_prev_idx = null
var walk_next_idx = null
var animate_to_destination = true

func init(coord, city):
    self.city = city
    set_coord(coord)
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

func _process(delta):
#    timeout -= delta
#    if timeout <= 0:
#        timeout += 0.05
#        if dest_coord == null:
#            dest_coord = city.random_passable_coord()
#            return
#        var path = city.shortest_path(self.coord, dest_coord)
#        if path != null and len(path) >= 1:
#            var path_idx = min(len(path) - 1, speed)
#            self.set_coord(path[path_idx])
#            if path_idx == len(path) - 1:
#                dest_coord = null
#        else:
#            dest_coord = null
    if Input.is_physical_key_pressed(KEY_SPACE) and dest_coord == null:
        print("Set coord")
        set_destination(city.random_passable_coord())
    if animate_to_destination:
        if path != null and walk_next_idx != null and walk_prev_idx != null:
            var walk_pixels = pixel_speed * delta
            while walk_pixels > 0:
                var walk_next = path[walk_next_idx]
                var walk_prev = path[walk_prev_idx]
                var walk_dir = path[walk_next_idx] - path[walk_prev_idx]
                var pixels_straight_vec = walk_pixels * walk_dir
                var pixels_straight = pixels_straight_vec.length()
                var walk_to_corner = walk_next - city.pos_to_float_coord(position)
                var pixels_to_corner = pixel_speed * walk_to_corner.length()
                var pixels_left_to_corner = pixels_to_corner - pixels_straight
                if pixels_left_to_corner > 0:
                    self.position += pixels_straight_vec
                    walk_pixels = 0
                else:
                    self.position += pixels_to_corner * walk_to_corner
                    walk_pixels -= pixels_to_corner
                    shift_walk()

func set_coord(new_coord):
    self.coord = new_coord
    self.position = new_coord * G.tile_dim
