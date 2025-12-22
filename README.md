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

  - `beta25` で動作確認済み．

##  導入方法

`RadRotDirBlur_S.anm2` ファイルに対して，以下のいずれかの操作をしてください．

1.  AviUtl2 のプレビュー画面にドラッグ&ドロップ．

1.  以下のフォルダのいずれかにコピー．

    1.  スクリプトフォルダ
        - AviUtl2 のメニューの「その他」 :arrow_right: 「アプリケーションデータ」 :arrow_right: 「スクリプトフォルダ」で表示されます．
    1.  (1) のフォルダにある任意の名前のフォルダ

初期状態だと「フィルタ効果を追加」メニューの「ぼかし」に RadRotDirBlur_S が追加されています．
- 「オブジェクト追加メニューの設定」の「ラベル」項目で分類を変更できます．

##  パラメタの説明

### 移動X, 移動Y

方向ブラーの移動方向・長さを指定します．

プレビュー編集画面のアンカー操作でも指定できます．
- [「中心」](#中心) もアンカーがありますが，オブジェクト中心からラインが *伸びている* ほうが「移動X」と「移動Y」です．

ピクセル単位で，初期値は両方とも 0.

### 拡大率

放射ブラーの拡大率を指定します．

% 単位で最小値は 1, 最大値は 1000, 初期値は 100.

### 回転角

回転ブラーの回転角度を指定します．

単位は度数法で最小値は -720, 最大値は 720, 初期値は 0.

### 中心

放射ブラーと回転ブラーの中心を，`X座標 , Y座標` の形で指定します．

プレビュー編集画面のアンカー操作でも指定できます．
- [「移動X」と「移動Y」](#移動x-移動y) もアンカーがありますが，オブジェクト中心からラインが *伸びていない* ほうが「中心」です．

ピクセル単位で，初期値は `0,0`.

### 強さ

[「拡大率」](#拡大率), [「回転角」](#回転角), [「移動X」, 「移動Y」](#移動x-移動y) を一律に強めたり弱めたりします．負の方向にすると，拡大が縮小になったり，回転方向や移動方向が逆になります．

% 単位で最小値は -200, 最大値は 200, 初期値は 100.

### 相対位置

ぼかしが広がる範囲の起点を指定します．

0 で前後に同じ量だけ広がります．+100 で前方向にだけ広がります．-100 で後ろ方向にだけ広がります．

最小値は -100, 最大値は 100, 初期値は 0.

### 色収差, 色収差強さ

RGB の各成分ごとにぼかしの移動量を減退させて，色収差の効果を与えます．

1.  「色収差」 は 6 項目から選びます．

    | 色収差 | 説明 |
    |:---:|:---|
    | `赤青A` | 赤 :arrow_right: 緑 :arrow_right: 青の順．アルファ値は 3 チャンネルの平均． |
    | `赤緑A` | 赤 :arrow_right: 青 :arrow_right: 緑の順．アルファ値は 3 チャンネルの平均． |
    | `緑青A` | 緑 :arrow_right: 赤 :arrow_right: 青の順．アルファ値は 3 チャンネルの平均． |
    | `赤青B` | 赤 :arrow_right: 緑 :arrow_right: 青の順．アルファ値は 3 チャンネルの最大． |
    | `赤緑B` | 赤 :arrow_right: 青 :arrow_right: 緑の順．アルファ値は 3 チャンネルの最大． |
    | `緑青B` | 緑 :arrow_right: 赤 :arrow_right: 青の順．アルファ値は 3 チャンネルの最大． |

    - `A` と `B` だと `A` は不透明度が低くなる傾向が，`B` は色が暗くなる傾向があります．

1.  「色収差強さ」 を負にすると，色の並び順が逆転します．

「色収差」の初期値は `赤青A`. 「色収差強さ」の最小値は -100, 最大値は 100, 初期値は 0.

- 使用しない場合，`色収差強さ` を `0.00` に指定したほうが高速です．

### サイズ固定

ぼかし効果で画像サイズが拡大するかどうかを指定します．初期値はチェックなし．

- フィルタオブジェクトとして使用している場合は，この設定は無視されます (常に ON に相当).

### 精度

ぼかし計算処理の繰り返し回数を指定します．大きいほど計算精度が高くなりますが，処理が重くなります．拡大・回転・移動方向によるピクセル移動量を超えた値を指定しても，最終結果の精度にはあまり影響がありません．

最小値は 2, 最大値は 4096, 初期値は 512.

### PI

パラメタインジェクション (parameter injection) です．初期値は空欄. テーブル型の中身として解釈され，各種パラメタの代替値として使用されます．また，任意のスクリプトコードを実行する記述領域にもなります．

```lua
{
  dir = { x, y },    -- table 型で "移動X", "移動Y" の項目を上書き，または nil.
  rad = num,         -- number 型で "拡大率" の項目を上書き，または nil.
  rot = num,         -- number 型で "回転角" の項目を上書き，または nil.
  center = { x, y }, -- table 型で "中心" の項目を上書き，または nil.
  amount = num,      -- number 型で "強さ" の項目を上書き，または nil.
  rel_pos = num,     -- number 型で "相対位置" の項目を上書き，または nil.
  chroma = str,      -- string 型で "色収差" の項目を上書き，または nil.
  chrm_abrr = str,   -- number 型で "色収差強さ" の項目を上書き，または nil.
  keep_size = num,   -- boolean, "サイズ固定" の項目を上書き，または nil. 0 を false, 0 以外を true 扱いとして number 型も可能．
  quality = num,     -- number 型で "精度" の項目を上書き，または nil.
}
```
- テキストボックスには冒頭末尾の波括弧 (`{}`) を省略して記述してください．

####  PI の `chroma`

指定できる string は以下の通りです:

```lua
"赤青A", "赤緑A", "緑青A", "赤青B", "赤緑B", "緑青B"
```

- number 型で `0`, `1`, `2`, `3`, `4`, `5` の指定も受け付けますが，互換性のためだけに残しています．string 型での指定を推奨します．

##  TIPS

1.  [「拡大率」](#拡大率) と [「回転角」](#拡大率) を同時に指定すると螺旋ブラーになります．

1.  「特定の1ピクセルが影響を及ぼす範囲」は概ね次の式で表される軌跡をたどった部分になります ([「相対位置」](#相対位置) が 0 の場合):

$$
\left[-\tfrac{1}{2}, +\tfrac{1}{2}\right] \ni t \mapsto r^t
\begin{pmatrix} \cos t\theta & -\sin t\theta \\
\sin t\theta & \cos t\theta \end{pmatrix}
p + t d \in \mathbb{R}^2
$$

ここに  $p$ は「特定の1ピクセル」の位置， $r$ は [「拡大率」](#拡大率) で指定した拡大率， $\theta$ は[「回転角」](#回転角) で指定した角度， $d$ は [「移動X」と「移動Y」](#移動x-移動y) で指定した方向．


## 改版履歴

- **v1.05 (for beta25)** (2025-12-22)

  - フィルタオブジェクトとして使用できるように設定．
  - `beta25` での動作確認．

- **v1.04 (for beta22a)** (2025-12-06)

  - パラメタをグループ化して整理．
  - パラメタインジェクションでの「色収差」に string 型を受け付けるように．
  - `beta22a` での動作確認．

- **v1.03 (for beta20)** (2025-11-17)

  - HLSL の Sampler の設定を明示的に指定するように変更．
  - `beta20` での動作確認．

- **v1.02 (for beta3)** (2025-07-24)

  - `リサイズ` など一部フィルタ効果の直後に適用した場合，`サイズ固定` が OFF でもオブジェクト外周が透明にならずに塗りつぶしされていたのを修正．
    - HLSL の Sampler の設定が一部フィルタ効果によって変更されるのが原因？

- **v1.01 (for beta3)** (2025-07-20)

  - `拡大率` と `色収差強さ` の精度を 1 桁追加．
  - `AviUtl ExEdit2 beta3` での動作確認．

- **v1.00 (for beta2)** (2025-07-19)

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
