extends TextureButton

func update():
    $TextureButton/Charges.bbcode_text = "x" + str(G.icecreams)
    if G.icecreams == 0:
        self.disabled = true
    else:
        self.disabled = false
