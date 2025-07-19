# RadRotDirBlur_S AviUtl ExEdit2 スクリプト

放射ブラー (radial blur), 回転ブラー (rotation blur), 方向ブラー (directional blur) の 3 つを複合したぼかし効果を適用する AviUtl ExEdit 2 用のスクリプトです．

[ダウンロードはこちら．](https://github.com/sigma-axis/aviutl2_script_RadRotDirBlur_S/releases) [紹介動画．](https://www.nicovideo.jp/watch/sm45201781)

![放射ブラーと回転ブラー，方向ブラー](https://github.com/user-attachments/assets/471485a6-92a2-4f0b-a71c-381577beef54)

![組み合わせてできたブラー効果](https://github.com/user-attachments/assets/9172eeb8-2e64-413d-87a3-b805c704adcd)

- 元画像: https://www.pexels.com/photo/green-leafed-tree-beside-body-of-water-during-daytime-158063

パラメタの組み合わせによっては螺旋ブラーなど，既存のブラー効果を組み合わせるだけではできない効果も可能です．色収差の効果も付けられます．

##  動作要件

- AviUtl ExEdit2

  http://spring-fragrance.mints.ne.jp/aviutl

  - `beta2` で動作確認済み．

##  導入方法

`%ProgramData%` 内の `aviutl2/Script` フォルダ (通常は `C:/ProgramData/aviutl2/Script` フォルダ) に `RadRotDirBlur_S.anm2` をコピーしてください．

初期状態だと「フィルタ効果を追加」メニューの「ぼかし」に RadRotDirBlur_S が追加されています．
- 「オブジェクト追加メニューの設定」の「ラベル」項目で分類を変更できます．

##  パラメタの説明

![スクリプトの GUI](https://github.com/user-attachments/assets/eb8609c9-7b8c-4508-8045-e1d67d3eb3da)

### `移動X`, `移動Y`

方向ブラーの移動方向・長さを指定します．

プレビュー編集画面のアンカー操作でも指定できます．
- [`中心`](#中心) もアンカーがありますが，オブジェクト中心からラインが *伸びている* ほうが `移動X` と `移動Y` です．

ピクセル単位で，初期値は両方とも `0.00`.

### `拡大率`

放射ブラーの拡大率を指定します．

% 単位で最小値は `1.00`, 最大値は `1000.00`, 初期値は `100.00`.

### `回転角`

回転ブラーの回転角度を指定します．

単位は度数法で最小値は `-720.00`, 最大値は `720.00`, 初期値は `0.00`.

### `中心`

放射ブラーと回転ブラーの中心を，`X座標 , Y座標` の形で指定します．

プレビュー編集画面のアンカー操作でも指定できます．
- [`移動X` と `移動Y`](#移動x-移動y) もアンカーがありますが，オブジェクト中心からラインが *伸びていない* ほうが `中心` です．

ピクセル単位で，初期値は `0,0`.

### `強さ`

[`拡大率`](#拡大率), [`回転角`](#回転角), [`移動X`, `移動Y`](#移動x-移動y) を一律に強めたり弱めたりします．負の方向にすると，拡大が縮小になったり，回転方向や移動方向が逆になります．

% 単位で最小値は `-200.00`, 最大値は `200.00`, 初期値は `100.00`.

### `相対位置`

ぼかしが広がる範囲の起点を指定します．

`0.00` で前後に同じ量だけ広がります．`+100.00` で前方向にだけ広がります．`-100.00` で後ろ方向にだけ広がります．

最小値は `-100.00`, 最大値は `100.00`, 初期値は `0.00`.

### `色収差`, `色収差強さ`

RGB の各成分ごとにぼかしの移動量を減退させて，色収差の効果を与えます．

1.  `色収差` からは 6 項目を選びます．

    ![色収差の選択肢](https://github.com/user-attachments/assets/769ff39f-f508-4fbe-8bdf-524b717824d9)

    - `A` と `B` の項目がありますが，`A` は不透明度が低くなる傾向が，`B` は色が暗くなる傾向があります．

1.  `色収差強さ` を負にすると，色の並び順が逆転します．

`色収差` の初期値は `赤青A`. `色収差強さ` の最小値は `-100.00`, 最大値は `100.00`, 初期値は `0.00`.

- 使用しない場合，`色収差強さ` を `0.00` に指定したほうが高速です．
- [PI](#PI) で指定する際，数値との対応は以下の通りです:

  |数値|指定|
  |:---:|:---:|
  |`0`|赤青A|
  |`1`|赤緑A|
  |`2`|緑青A|
  |`3`|赤青B|
  |`4`|赤緑B|
  |`5`|緑青B|

### `サイズ固定`

ぼかし効果で画像サイズが拡大するかどうかを指定します．初期値はチェックなし．

### `精度`

ぼかし計算処理の繰り返し回数を指定します．大きいほど計算精度が高くなりますが，処理が重くなります．拡大・回転・移動方向によるピクセル移動量を超えた値を指定しても，最終結果の精度にはあまり影響がありません．

最小値は `2`, 最大値は `4096` 初期値は `512`.

### `PI`

パラメタインジェクション (parameter injection) です．初期値は空欄. テーブル型の中身として解釈され，各種パラメタの代替値として使用されます．また，任意のスクリプトコードを実行する記述領域にもなります．

```lua
{
  dir = { dx, dy }, -- table 型で "移動X", "移動Y" の項目を上書き，または nil.
  rad = rad, -- number 型で "拡大率" の項目を上書き，または nil.
  rot = rot, -- number 型で "回転角" の項目を上書き，または nil.
  center = { cx, cy }, -- table 型で "中心" の項目を上書き，または nil.
  amount = amout, -- number 型で "強さ" の項目を上書き，または nil.
  rel_pos = rel_pos, -- number 型で "相対位置" の項目を上書き，または nil.
  chroma = chrm_abrr_type, -- number 型で "色収差" の項目を上書き，または nil.
  chrm_abrr = chrm_abrr_amount, -- number 型で "色収差強さ" の項目を上書き，または nil.
  keep_size = keep_size, -- boolean, "サイズ固定" の項目を上書き，または nil. 0 を false, 0 以外を true 扱いとして number 型も可能．
  quality = quality, -- number 型で "精度" の項目を上書き，または nil.
}
```
- テキストボックスには冒頭末尾の波括弧 (`{}`) を省略して記述してください．


##  TIPS

1.  [`拡大率`](#拡大率) と [`回転角`](#拡大率) を同時に指定すると螺旋ブラーになります．

1.  「特定の1ピクセルが影響を及ぼす範囲」は概ね次の式で表される軌跡をたどった部分になります ([`相対位置`](#相対位置) が `0` の場合):

$$
\left[-\tfrac{1}{2}, +\tfrac{1}{2}\right] \ni t \mapsto r^t
\begin{pmatrix} \cos t\theta & -\sin t\theta \\
\sin t\theta & \cos t\theta \end{pmatrix}
p + t d \in \mathbb{R}^2
$$

ここに  $p$ は「特定の1ピクセル」の位置， $r$ は [`拡大率`](#拡大率) で指定した拡大率， $\theta$ は[`回転角`](#回転角) で指定した角度， $d$ は [`移動X` と `移動Y`](#移動x-移動y) で指定した方向．


## 改版履歴

- **v1.00 (for beta2)** (2025-04-13)

  - 初版．
  - [拡張編集 0.92 版](https://github.com/sigma-axis/aviutl_script_RadRotDirBlur_S) から移植．
  - 色収差の機能を追加．


## ライセンス

このプログラムの利用・改変・再頒布等に関しては MIT ライセンスに従うものとします．

---

The MIT License (MIT)

Copyright (C) 2025 sigma-axis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

https://mit-license.org/


#  連絡・バグ報告

- GitHub: https://github.com/sigma-axis
- Twitter: https://x.com/sigma_axis
- nicovideo: https://www.nicovideo.jp/user/51492481
- Misskey.io: https://misskey.io/@sigma_axis
- Bluesky: https://bsky.app/profile/sigma-axis.bsky.social
