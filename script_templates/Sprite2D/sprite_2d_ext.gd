# Sprite2DExt
# ・Sprite2DSvgを継承
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.costumes.svg_file_path_setting([
		# "res://assets/xxxxx.svg",
	])
	position.x = 0
	position.y = 0
	costumes.current_svg_tex()
