# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	position.x = 1000
	position.y = 500
	costumes.svg_file_path_setting([
		"res://assets/crab-a.svg",
		"res://assets/crab-b.svg",
	])
	costumes.current_svg_tex()

	# 無限ループスレッドを起動（３個）
	_loop01()
	_loop02()
	_loop03()
	_loop04()
	_loop05()

	_viewer_help()

func _loop01() -> void :
	while true:
		#next_svg_tex()
		if Input.is_action_just_pressed("key_escape"):
			break
		if Input.is_action_pressed("key_left"):
			self.position.x -= 0.3
		if Input.is_action_pressed("key_right"):
			self.position.x += 0.3
		#await sleep(0.5)
		await ThreadUtils.waitNextFrame
		
func _loop02() -> void:
	#var counter = 0
	var label:Label = $"/root/Scene01/Label"
	var circle :Sprite2D = $"/root/Scene01/Circle"
	circle.visible = false # 隠す
	#circle.modulate = Color(0, 0, 1) # 青くする
	#circle.position = Vector2(0,0)
	var target:Sprite2DExt = $"/root/Scene01/Niwatori"
	#print("target._original_sprite=", target._original_sprite)
	while true:
		var hitter:Hit = costumes._is_pixel_touched(target)
		if hitter.hit == true:
			self.modulate = Color(0.1, 0.1, 1, 0.5) # 青くする
			circle.position = self.to_global(hitter.position) 
			circle.visible = true
			label.text = "Hit!(当たっている)"
			_rotationer = true
		elif hitter.position.x == INF:
			self.modulate = Color(1, 1, 1, 1)
			label.text = ""
			circle.visible = false
			_rotationer = false
		else:
			label.text = "Neighborhood!(近傍)"
			self.modulate = Color(1, 1, 1, 1)
			circle.visible = false
			_rotationer = false
			
		
		await ThreadUtils.waitNextFrame
	

func _loop03() -> void:
	while draggable:
		self._drag_process()		
		await ThreadUtils.waitNextFrame

func _loop04() -> void :
	while true:
		await ThreadUtils.sleep(0.5)
		self.costumes.next_svg_tex()
		await ThreadUtils.waitNextFrame

var _rotationer: bool = false
func _loop05() -> void :
	while true:
		if _rotationer:
			self.rotation -= PI / 180 * 15
		await ThreadUtils.waitNextFrame

# FOR DEBUG
# Viewerへ外周を描く
func _viewer_help() ->void:
	var rect:Rect2 = self.get_rect()
	var viewer:Sprite2D = $"../../Scene01/Viewer"	
	var image:Image = Image.create(int(rect.size.x), int(rect.size.y), false, Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	
	var _svgObj:SvgObj = self.costumes._get_svg_img_obj()
	var _surrounds = _svgObj.surrounding_point_arr
	for _pos:Vector2 in _svgObj.surrounding_point_arr:
		image.set_pixel(int(_pos.x), int(_pos.y), Color(0,0,0,1))
	var _texture:ImageTexture = ImageTexture.new()
	_texture.set_image(image)
	viewer.texture = _texture

# For Debug
# Viewerノードがツリーに入り、Readyが終わったときに
# _viewer_help() を１回だけ実行する
func _on_viewer_tree_entered() -> void:
	while true:
		if self.costumes:
			_viewer_help()
			break
		await ThreadUtils.waitNextFrame
