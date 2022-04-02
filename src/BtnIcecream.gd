extends TextureButton


func _ready():
    self.connect("button_up", self, "message")
    
func message():
    print("icescream!")
