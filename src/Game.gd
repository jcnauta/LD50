extends Node2D

var turn_processed = true

func end_turn():
    print("Game End try turn")
    # Prevent player from ending the turn before the previous one is over
    if turn_processed:
        print("Game last turn was processed so let's go!")
        turn_processed = false
        $City.end_turn()

func city_turn_processed():
    turn_processed = true
