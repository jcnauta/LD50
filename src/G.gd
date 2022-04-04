extends Node

var showing_menu = false
var just_paused = false
var level_nr = 1
var roadblocks
var icecreams
var click_mode  # {icecream, roadblock, null}
var money = 0
var money_per_level = {
    1: -1,
    2: -1,
    3: -1,
    4: -1,
    5: -1,
    6: -1,
    7: -1,
    8: -1,
    9: -1,
    "special": -1
   }
var special_goal = 150
var special_seed = null
var special_difficulty = null
var best_special_seed = {}

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

const guy_imgs = {
    "lion": preload("res://img/Loewi.png"),
    "frog": preload("res://img/Frog.png"),
    "robot": preload("res://img/friendly_robot_purple.png"),
    "penguin": preload("res://img/Penguin.png"),
   }

const money_per_turn = 0
const money_per_guy = 5
const money_per_balloon = 15
const water_fraction = 0.3
const street_core_frac = 0.15

# Set difficulties in [1, 100]
const levels = {
    1: {"seed": 145, "difficulty": 1, "goal": 45},
    2: {"seed": 234, "difficulty": 100, "goal": 1},
    3: {"seed": 345, "difficulty": 100, "goal": 1},
    4: {"seed": 5, "difficulty": 20, "goal": 75}, #75
    5: {"seed": 7, "difficulty": 50, "goal": 125}, # 115
    6: {"seed": 8, "difficulty": 60, "goal": 135}, # 120
    7: {"seed": 9, "difficulty": 70, "goal": 110}, # 125
    8: {"seed": 1, "difficulty": 80, "goal": 105}, # 
    9: {"seed": 2, "difficulty": 100, "goal": 100},
}

var level_info

func generate_level_info(seed_info):
    seed(seed_info.seed)
    var difficulty = seed_info.difficulty
    level_info = {}
    level_info.seed = seed_info.seed
    level_info.difficulty = difficulty
    level_info.goal = seed_info.goal
    level_info.street_fraction = 0.40 * (0.4 + 0.6 * clamp(0.01 * difficulty, 0.0, 1.0))
    level_info.min_street_length = int(4 + floor(0.1 * (100 - difficulty)))
    level_info.max_street_length = int(10 + floor(0.1 * (100 - difficulty)))
    level_info.guys = min(4, 1 + floor(difficulty / 30) + min(2, randi() % int(floor(1 + 0.2 * sqrt(difficulty)))))
    level_info.roadblocks = 1 + floor(level_info.guys / 2) + randi() % 2
    level_info.icecreams = 1 + floor(level_info.guys / 2) + randi() % 3
    level_info.balloons = 2 + randi() % 4

func encode_special_level(difficulty, the_seed):
    return 1000 * difficulty + the_seed

func decode_special_level(special):
    return {
        "difficulty": floor(special / 1000),
        "seed": special % 1000
    }

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
