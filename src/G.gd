extends Node

var roadblocks
var icecreams
var click_mode  # {icecream, roadblock, null}

const grid_dim = 25
const tile_dim = 36
const total_tiles = grid_dim * grid_dim

const max_icecream_path_length = 5
const guy_types = ["lion", "frog", "robot", "penguin"]
const guy_colors = {
    "lion": Color.brown,
    "frog": Color.forestgreen,
    "robot": Color.webpurple,
    "penguin": Color.darkblue
   }

const money_per_turn = 10
const money_per_guy = 5
const water_fraction = 0.3
const street_core_frac = 0.15

# Set difficulties in [1, 100]
const levels = [
    {"seed": 6, "difficulty": 1},
    {"seed": 2, "difficulty": 100},
    {"seed": 3, "difficulty": 50},
    {"seed": 4, "difficulty": 10},
    {"seed": 5, "difficulty": 20},
    {"seed": 7, "difficulty": 50},
    {"seed": 8, "difficulty": 60},
    {"seed": 9, "difficulty": 70},
    {"seed": 1, "difficulty": 80},
   ]

var level_info

func generate_level_info(level_idx):
    level_info = levels[level_idx]
    var difficulty = level_info.difficulty
#    level_info.streets = 8 + ceil(0.08 * difficulty * sqrt(difficulty))
    level_info.street_fraction = 0.40 * (0.4 + 0.6 * clamp(0.01 * difficulty, 0.0, 1.0))
    level_info.min_street_length = int(4 + floor(0.1 * (100 - difficulty)))
    level_info.max_street_length = int(10 + floor(0.1 * (100 - difficulty)))
    level_info.guys = min(4, 1 + floor(difficulty / 50) + min(2, randi() % int(floor(1 + 0.2 * sqrt(difficulty)))))
    level_info.roadblocks = 1 + randi() % 3
    level_info.icecreams = 2 + randi() % 3
    level_info.balloons = 2 + randi() % 3

const dirs4 = [
    Vector2(-1, 0),
    Vector2(1, 0),
    Vector2(0, -1),
    Vector2(0, 1)
]

const dirs8 = [
    Vector2(-1, 0),
    Vector2(1, 0),
    Vector2(0, -1),
    Vector2(0, 1),
    Vector2(-1, -1),
    Vector2(-1, 1),
    Vector2(1, -1),
    Vector2(1, 1),
   ]

const round_corners = [
    [
        Vector2(-1, 0),
        Vector2(-1, -1),
        Vector2(0, -1)
    ], [
        Vector2(0, -1),
        Vector2(1, -1),
        Vector2(1, 0),
    ],
    [
        Vector2(1, 0),
        Vector2(1, 1),
        Vector2(0, 1),
    ],
    [
        Vector2(0, 1),
        Vector2(-1, 1),
        Vector2(-1, 0),
    ],
   ]

func random_dir():
    return dirs4[randi() % len(dirs4)]
