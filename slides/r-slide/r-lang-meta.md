---
title: "第3部 R言語のメタプログラミング"
author: wass80
date: 2017-03-10
autosize: true
output:
  revealjs::revealjs_presentation:
    pandoc_args: [
  '--from', 'markdown+autolink_bare_uris+tex_math_single_backslash-implicit_figures'
]
    self_contained: false
    reveal_options:
      slideNumber: true
    theme: night
    highlight: "zenburn"
---

メタプログラミングとは
---

プログラムでプログラムを扱うこと

例:

* Cのプリプロセッサ
* C++のtemplate
* LispのS式
* Rubyの動的なメソッド, クラス


<style>
.reveal code {
font-size: 150%;
}
</style>


DSL (ドメイン固有言語)
---

* メタプログラミングの目的として, DSLがある
* 特定目的のための固有の言語
* Rubyでよくあるやつ
* 出来ることを減らしその分簡単に書きたいという思い

Rのメタプログラミング
---

* HaddlyのライブラリはDSLの一例
    * dplyrもggplotも独特な書き方を提供している
    * 特に`%>%`はメタプログラミングの力を借りていることがわかりやすい

参考本
---

* R言語徹底解説
* Hadley神の本
* [これもネットで読める](http://adv-r.had.co.nz/)

メタプログラミングの仕組み
---

* Rの関数の挙動が関わってくる
* 変数名の解決
* 関数の構成要素
    * 引数リスト (formals)
    * 関数本体 (body)
    * 関数定義元の環境 (environment)

変数名の解決
---
変数を評価するとコピーが得られる


```r
x <- 1:3
y <- x # Copy x 
x[2] <- 9
x
```

```
[1] 1 9 3
```

```r
y
```

```
[1] 1 2 3
```

関数でも
---

```r
touch <- function(x) x[1] <- 8 # Copied x
a <- c(10, 11)
touch(a)
a
```

```
[1] 10 11
```

毎回コピーするとめっちゃ遅いんでは
---

* 遅い
* R 2.xでは実際にコピーしていた
* R 3.xではCopy on Modifyを採用している
     * すぐにコピーはせず, 変更するまでコピーしない
     * このため少しマシ

環境
---

* 関数の外側の環境の変数を見つけるための仕組み
* Listのようなもの


```r
i <- "before"
return_i <- function() i
return_i()
```

```
[1] "before"
```

```r
i <- "after"
return_i()
```

```
[1] "after"
```

関数の環境
---


* 関数は自分の環境と親の環境を持っている


```r
global <- 1
print_env<- function(){
  outer  <- 2
  list(here = ls(), # 自分の環境の名前
      parent = ls(envir = parent.frame())) # 親環境の名前
}
print_list(print_env())
```

```
$here: outer; $parent: c("global", "print_env", "print_list")
```

クロージャ
---

* 外側の関数の環境も見つける
* 自分の環境にない場合, 親の環境で探す

```r
i = "global"
const <- function(){
  i <- "outer" # Found
  function() i
}
f <- const()
f()
```

```
[1] "outer"
```

外側の環境の変更
---

* `<<-`大域束縛で外側の変数を書き換える

```r
counter <- function(i = 1){
  function() {i <<- i + 1; i} # Change Outer i
}
f <- counter()
c(f(), f(), f())
```

```
[1] 2 3 4
```

`<-`の場合
---

* ローカルな変数を作ってしまう

```r
counter <- function(i = 1){
  function() {i <- i + 1; i} # Make Local i
}
f <- counter()
c(f(), f(), f())
```

```
[1] 2 2 2
```

まとめ: 関数の中の変数
---

* 関数は自分の環境と親の環境を持つ
* 自分の環境で名前を探し, なければ親の環境で探す

* むやみに参照透過性を崩すのはやめよう
* `<<-` 大域束縛演算子は挙動を理解して使うべき

関数の構成
---

```r
f <- function(x, y = 2) sqrt(x + y)
formals(f) # 引数リスト
```

```
$x


$y
[1] 2
```

```r
body(f) # 関数本体
```

```
sqrt(x + y)
```

```r
environment(f) # 定義元環境
```

```
<environment: R_GlobalEnv>
```

関数の定義を見る
---

* 名前だけ書くと関数定義を見れる
* `.Primitive()`はRで以外で定義された関数

```r
f
```

```
function(x, y = 2) sqrt(x + y)
```

```r
sum
```

```
function (..., na.rm = FALSE)  .Primitive("sum")
```

全ては関数
---

演算子はバッククオートで関数に

```r
1 + 3
```

```
[1] 4
```

```r
`+`(1, 3)
```

```
[1] 4
```

`if`も関数
---

制御構造も関数に

```r
if(1 == 2) "T" else "F"
```

```
[1] "F"
```

```r
`if`(1 == 2, "T", "F")
```

```
[1] "F"
```

構造も関数に
---
<div style="column-count: 2">
中括弧も関数 (逐次評価, 最後の引数を返す)

```r
{a <- 1; a + a}
```

```
[1] 2
```

```r
`{`(a <- 2, a + a)
```

```
[1] 4
```

括弧も関数 (恒等関数)

```r
(1 + 2)
```

```
[1] 3
```

```r
`(`(1 + 2)
```

```
[1] 3
```
</div>

`if`が関数で大丈夫なの?
---

実はRは引数を**遅延評価**する

```r
do_nothing <- function(x) message("ok ?") # xを評価していない
do_nothing(message("args")) # 引数は評価されない

eval_x <- function(x) {x; message("ok ?")}
eval_x(message("args"))
```

このため, `if`が関数でも問題ない

遅延評価でないときの`if`
---

もし, ifが引数をすべて評価する場合, どちらの`messasge`も起きてしまう


```r
if (1 == 2) message("T") else message("F")
```

しかし, Rでは引数は必要になるまで評価されない

条件に応じてどちらかが評価される

ほんとに関数?
---

* 極端な例として`(`を上書きする

```r
`(` <- function(x) x + 1
c(3, (3), (1 + 2) * 3) 
```

```
[1]  3  4 12
```

* ヤバイので消す

```r
rm("(")
```

まとめ: 関数の正体
---

* 演算子や制御構造など, すべてが関数で処理されている

Rの引数渡し
---

* Rは関数を呼ぶとき, 引数をどのように渡しているだろう

* 参照の値渡し
    * Ruby, Python, Java, JSなど多くの言語
* 参照渡し, 値のコピー渡しなどを選べる
    * C++, C#, Rustなど参照の概念のある言語

* Rはどちらでもない

表現式と環境渡し
---
 
* `substitute`で引数の表現式が見れる
* 引数ではこれとプロミスは表現式と元環境

```r
s <- function(x) substitute(x)
s(1 + noname)
```

```
1 + noname
```

```r
s(sqrt(5 * (1 + 3)))
```

```
sqrt(5 * (1 + 3))
```

表現式を文字列に変換
---

* `library(dplyr)`などはこれを利用している

```r
s <- function(x) deparse(substitute(x))
s(1 + 5)
```

```
[1] "1 + 5"
```

```r
s(library(dplyr))
```

```
[1] "library(dplyr)"
```

`quote`と`eval`
---
* `quote` 表現式を返す
* `eval` 表現式を評価

```r
x <- 1
quote(1 + 2)
```

```
1 + 2
```

```r
quote(x + 1)
```

```
x + 1
```

```r
eval(quote(x + 1))
```

```
[1] 2
```

`quote`と`substitute`の違い
---
* `substitute`はローカルな変数を置き換える
* `quote`はそのまま

```r
f <- function(x = 1) {
  y <- 2
  c(quote(x + y + z),
    substitute(x + y + z))
}
f()
```

```
[[1]]
x + y + z

[[2]]
1 + 2 + z
```

環境指定した`eval`
---

* 空の環境は`new.env()`で作れる
* 環境はリストと似た操作ができる


```r
e <- new.env()
e$x <- 5
x <- 10 # Globalの環境
eval(quote(x), e)
```

```
[1] 5
```

```r
eval(quote(x), globalenv())
```

```
[1] 10
```

実はリストも`eval`の環境にできる
---

```r
eval(quote(x), list(x=5))
```

```
[1] 5
```

```r
acc <- function(x, key) eval(substitute(key), x)
acc(list(z=1), z)
```

```
[1] 1
```

`filter`はこの機能を利用している















```
processing file: r-lang-meta.Rpres
ok ?
args
ok ?
F
Quitting from lines 363-364 (r-lang-meta.Rpres) 
 filter(iris, Sepal.Length > 7.7) でエラー: 
   オブジェクト 'Sepal.Length' がありません 
 呼び出し:  knit ... withCallingHandlers -> withVisible -> eval -> eval -> filter
 実行が停止されました
```
