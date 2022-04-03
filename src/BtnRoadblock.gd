extends TextureButton

func update():
    $TextureButton/MarginContainer2/Charges.bbcode_text = "x" + str(G.roadblocks)
    if G.roadblocks == 0:
        self.disabled = true
    else:
        self.disabled = false
