# godot_sprite2d_ext
A prototype like Scratch3, godot sprite2D extension

私のScratch3愛をGodotに注入したいと思いまして、この試作品を作りました。
試作品なので多くを期待しないでください。

## Godot version
- Godot 4.5

# sample

Sprite2DExtである「カニ」「ニワトリ」を使用しています。

「カニ」はマウスドラッグで位置を変えることができます。

![demo](https://raw.githubusercontent.com/wiki/amami-harhid/godot_sprite2d_ext/images/img_3021.gif)

最初に衝突を検出した場所に 〇を表示させています

サンプルは FPS=30 で動かしています。

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
    await self.sleep(1)       # 1秒待つ
```

## ずっとブロック風の表現に挑戦

「ずっと繰り返す」を while を使って書いてみました。

```:gdscript
func _loop() -> void:
    while true:
        await self.sleep(0.5)       # 0.5秒待つ
        self.next_svg_tex()         # 次のコスチュームにする
        await signal_process_loop   # Processループタイミングに合わせる
```

## bitmap collision
画素がある部分が当たることで衝突判定を行う仕組みを用意しました。

```:gdscript
func _loop() -> void:
	var target:Sprite2DExt = $"/root/Node2D/Niwatori" # ニワトリのノード
	while true:
		if self._is_pixel_touched(target) :         # 相手に触ったかの判定
			self.modulate = Color(0.5, 0.5, 0.5)    # やや暗くする
		else:
			self.modulate = Color(1, 1, 1)          # 元の色に変える
		await signal_process_loop                   # Processループタイミングに合わせる
```

### TODO

Scratch3のクローン的なことをしたときでも、うまく動作するようにしてみたいです。

