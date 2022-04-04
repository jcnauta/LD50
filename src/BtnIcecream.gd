extends TextureButton

func update():
    $TextureButton/Charges.bbcode_text = "x" + str(G.icecreams)
    if G.icecreams == 0:
        self.disabled = true
        self.modulate = Color(0.5, 0.5, 0.8, 0.8)
    else:
        self.disabled = false
        if G.click_mode == "icecream":
            self.modulate = Color(1, 1, 1, 1)
        else:
            self.modulate = Color(0.9, 0.85, 0.9, 0.9)
