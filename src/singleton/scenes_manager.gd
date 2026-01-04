# プロジェクト設定の「自動読み込み」に追加した
# スクリプトを登録済である
# 名称：ScenesManager
extends Node

# 画面のロード
var scene_main: PackedScene = preload("res://scenes/main.tscn")
var scene_01: PackedScene = preload("res://scenes/scene_01.tscn")
var scene_02: PackedScene = preload("res://scenes/scene_02.tscn")

# Scene01に切り替え
func load_scene_main() -> void:
	get_tree().change_scene_to_packed(scene_main)

# Scene01に切り替え
func load_scene01() -> void:
	get_tree().change_scene_to_packed(scene_01)

# Scene02 に切り替え
func load_scene02() -> void:
	get_tree().change_scene_to_packed(scene_02)
