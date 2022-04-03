extends Node

const grid_dim = 25
const tile_dim = 36

var levels = [
    {"seed": 1, "streets": 70, "guys": 1}, # 1
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
