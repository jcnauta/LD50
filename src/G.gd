extends Node

const grid_dim = 25
const tile_dim = 36

const max_icecream_path_length = 5
const guy_types = ["lion", "frog", "robot", "penguin"]
const guy_colors = {
    "lion": Color.brown,
    "frog": Color.forestgreen,
    "robot": Color.webpurple,
    "penguin": Color.darkblue
   }

const gpo = 6
const guy_path_offset = {
    "lion": Vector2(gpo, gpo),
    "frog": Vector2(gpo, -gpo),
    "robot": Vector2(-gpo, -gpo),
    "penguin": Vector2(-gpo, gpo),
   }

var levels = [
    {"seed": 1, "streets": 70, "guys": 4}, # 1
    {"seed": 2, "streets": 40, "guys": 2},
#    {"seed": 3, "streets": 100, "guys": 2},
#    {"seed": 4, "streets": 70, "guys": 3},
#    {"seed": 5, "streets": 70, "guys": 3}, # 5
#    {"seed": 6, "streets": 70, "guys": 4},
#    {"seed": 7, "streets": 70, "guys": 5},
#    {"seed": 8, "streets": 70, "guys": 5},
#    {"seed": 9, "streets": 70, "guys": 6}, # 9
   ]

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
