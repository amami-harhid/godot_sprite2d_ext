# godot_sprite2d_ext
A prototype like Scratch3, godot sprite2D extension

私のScratch3愛をGodotに注入したいと思いまして、この試作品を作りました。
試作品なので多くを期待しないでください。

## Godot version
- Godot 4.5

# sample

Sprite2DExtである「カニ」「ニワトリ」を使用しています。

![demo](https://raw.githubusercontent.com/wiki/amami-harhid/godot_sprite2d_ext/images/scene.png)


「ニワトリ」は右方向へ回転を続けています。
「カニ」はマウスドラッグで位置を変えることができ、近傍判定、衝突判定を行います。

最初に衝突を検出した場所に 〇を表示させています

![demo](https://raw.githubusercontent.com/wiki/amami-harhid/godot_sprite2d_ext/images/img_3022.gif)

サンプルは FPS=30 で動かしています。

# 事前準備

## プラグイン

プロジェクト設定⇒プラグイン⇒Sprite2DExpansion　を有効にしてください
addons/sprite2d : Sprite2dExtクラス


## シングルトンクラス

プロジェクト設定⇒グローバルにて次を有効にしてください。

- ScenesManager  res://src/singleton/scenes_manager.gd
- BitmapUtils  res://src/singleton/bitmap_utils.gd
- SpriteUtils  res://src/singleton/sprite_utils.gd
- ThreadUtils  res://src/singleton/thread_utils.gd


# 注入したScratch3愛

## SVG画像をくっきりと表示
Godot標準では SVG画像をインポートするとイメージ変換されるため、
サイズ拡大するとぼやけてしまいます。
サイズが変更されたときには、SVGからイメージへ再変換することで
くっきりと表示されるように工夫しています。

## コスチューム切り替え
Scratch3風に 「次のコスチューム」みたいなメソッドを用意しました

## 「〇秒待つ」を用意

指定した秒数分、処理を止めるメソッドを用意しました。

```:gdscript
    await ThreadUtils.sleep(1)       # 1秒待つ
```

## ずっとブロック風の表現に挑戦

「ずっと繰り返す」を while を使って書いてみました。

```:gdscript
func _ready() -> void:
	_loop()  # 非同期処理(ずっと繰返し)を開始

func _loop() -> void:
    while true:
        await ThreadUtils.sleep(0.5)    # 0.5秒待つ
        self.costumes.next_svg_tex()    # 次のコスチュームにする
        await ThreadUtils.waitNextFrame # Processループタイミングを合わせる
```

## bitmap collision
画素がある部分が当たることで衝突判定を行う仕組みを用意しました。

```:gdscript
func _ready() -> void:
	_loop()  # 非同期処理(ずっと繰返し)を開始

func _loop() -> void:
	var target:Sprite2DExt = $"/root/Scene01/Niwatori" # ニワトリのノード
	while true:
		var hit:Hit = self.costumes._is_pixel_touched(target)
		if hit.hit :  # 相手に触ったとき
			self.modulate = Color(0.5, 0.5, 0.5)  # やや暗くする
		else:         # 触っていないとき
			self.modulate = Color(1, 1, 1)        # 元の色に変える
		await ThreadUtils.waitNextFrame           # Processループタイミングを合わせる
```

### 今後

Scratch3の「動き」ブロック、「見た目」ブロック、「イベント」ブロックなど
用意してみたいです。

そして、子ども向けプログラミング教材に仕上げてみたいです。

