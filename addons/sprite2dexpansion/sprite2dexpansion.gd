@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

# 型をSprite2DExtに変更したときに、アイコンを切り替えたいために
# add_custom_type を実行する
func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var svg_2d_icon = null
	if ResourceLoader.exists("res://addons/sprite2dexpansion/sprite2d/svg_2d.png"):
		svg_2d_icon = load("res://addons/sprite2dexpansion/sprite2d/svg_2d.png")
	add_custom_type("Sprite2DExt", "Sprite2D", preload("./sprite2d/sprite_2d_ext.gd"), svg_2d_icon)
	pass


func _exit_tree() -> void:
	remove_custom_type("Sprite2DExt")
	pass
