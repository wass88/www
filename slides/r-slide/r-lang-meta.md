---
title: "��3�� R����̃��^�v���O���~���O"
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

���^�v���O���~���O�Ƃ�
---

�v���O�����Ńv���O��������������

��:

* C�̃v���v���Z�b�T
* C++��template
* Lisp��S��
* Ruby�̓��I�ȃ��\�b�h, �N���X


<style>
.reveal code {
font-size: 150%;
}
</style>


DSL (�h���C���ŗL����)
---

* ���^�v���O���~���O�̖ړI�Ƃ���, DSL������
* ����ړI�̂��߂̌ŗL�̌���
* Ruby�ł悭������
* �o���邱�Ƃ����炵���̕��ȒP�ɏ��������Ƃ����v��

R�̃��^�v���O���~���O
---

* Haddly�̃��C�u������DSL�̈��
    * dplyr��ggplot���Ɠ��ȏ�������񋟂��Ă���
    * ����`%>%`�̓��^�v���O���~���O�̗͂��؂�Ă��邱�Ƃ��킩��₷��

�Q�l�{
---

* R����O����
* Hadley�_�̖{
* [������l�b�g�œǂ߂�](http://adv-r.had.co.nz/)

���^�v���O���~���O�̎d�g��
---

* R�̊֐��̋������ւ���Ă���
* �ϐ����̉���
* �֐��̍\���v�f
    * �������X�g (formals)
    * �֐��{�� (body)
    * �֐���`���̊� (environment)

�ϐ����̉���
---
�ϐ���]������ƃR�s�[��������


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

�֐��ł�
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

����R�s�[����Ƃ߂�����x����ł�
---

* �x��
* R 2.x�ł͎��ۂɃR�s�[���Ă���
* R 3.x�ł�Copy on Modify���̗p���Ă���
     * �����ɃR�s�[�͂���, �ύX����܂ŃR�s�[���Ȃ�
     * ���̂��ߏ����}�V

��
---

* �֐��̊O���̊��̕ϐ��������邽�߂̎d�g��
* List�̂悤�Ȃ���


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

�֐��̊�
---


* �֐��͎����̊��Ɛe�̊��������Ă���


```r
global <- 1
print_env<- function(){
  outer  <- 2
  list(here = ls(), # �����̊��̖��O
      parent = ls(envir = parent.frame())) # �e���̖��O
}
print_list(print_env())
```

```
$here: outer; $parent: c("global", "print_env", "print_list")
```

�N���[�W��
---

* �O���̊֐��̊���������
* �����̊��ɂȂ��ꍇ, �e�̊��ŒT��

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

�O���̊��̕ύX
---

* `<<-`��摩���ŊO���̕ϐ�������������

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

`<-`�̏ꍇ
---

* ���[�J���ȕϐ�������Ă��܂�

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

�܂Ƃ�: �֐��̒��̕ϐ�
---

* �֐��͎����̊��Ɛe�̊�������
* �����̊��Ŗ��O��T��, �Ȃ���ΐe�̊��ŒT��

* �ނ�݂ɎQ�Ɠ��ߐ�������̂͂�߂悤
* `<<-` ��摩�����Z�q�͋����𗝉����Ďg���ׂ�

�֐��̍\��
---

```r
f <- function(x, y = 2) sqrt(x + y)
formals(f) # �������X�g
```

```
$x


$y
[1] 2
```

```r
body(f) # �֐��{��
```

```
sqrt(x + y)
```

```r
environment(f) # ��`����
```

```
<environment: R_GlobalEnv>
```

�֐��̒�`������
---

* ���O���������Ɗ֐���`�������
* `.Primitive()`��R�ňȊO�Œ�`���ꂽ�֐�

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

�S�Ă͊֐�
---

���Z�q�̓o�b�N�N�I�[�g�Ŋ֐���

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

`if`���֐�
---

����\�����֐���

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

�\�����֐���
---
<div style="column-count: 2">
�����ʂ��֐� (�����]��, �Ō�̈�����Ԃ�)

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

���ʂ��֐� (�P���֐�)

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

`if`���֐��ő��v�Ȃ�?
---

����R�͈�����**�x���]��**����

```r
do_nothing <- function(x) message("ok ?") # x��]�����Ă��Ȃ�
do_nothing(message("args")) # �����͕]������Ȃ�

eval_x <- function(x) {x; message("ok ?")}
eval_x(message("args"))
```

���̂���, `if`���֐��ł����Ȃ�

�x���]���łȂ��Ƃ���`if`
---

����, if�����������ׂĕ]������ꍇ, �ǂ����`messasge`���N���Ă��܂�


```r
if (1 == 2) message("T") else message("F")
```

������, R�ł͈����͕K�v�ɂȂ�܂ŕ]������Ȃ�

�����ɉ����Ăǂ��炩���]�������

�ق�ƂɊ֐�?
---

* �ɒ[�ȗ�Ƃ���`(`���㏑������

```r
`(` <- function(x) x + 1
c(3, (3), (1 + 2) * 3) 
```

```
[1]  3  4 12
```

* ���o�C�̂ŏ���

```r
rm("(")
```

�܂Ƃ�: �֐��̐���
---

* ���Z�q�␧��\���Ȃ�, ���ׂĂ��֐��ŏ�������Ă���

R�̈����n��
---

* R�͊֐����ĂԂƂ�, �������ǂ̂悤�ɓn���Ă��邾�낤

* �Q�Ƃ̒l�n��
    * Ruby, Python, Java, JS�ȂǑ����̌���
* �Q�Ɠn��, �l�̃R�s�[�n���Ȃǂ�I�ׂ�
    * C++, C#, Rust�ȂǎQ�Ƃ̊T�O�̂��錾��

* R�͂ǂ���ł��Ȃ�

�\�����Ɗ��n��
---
 
* `substitute`�ň����̕\�����������
* �����ł͂���ƃv���~�X�͕\�����ƌ���

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

�\�����𕶎���ɕϊ�
---

* `library(dplyr)`�Ȃǂ͂���𗘗p���Ă���

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

`quote`��`eval`
---
* `quote` �\������Ԃ�
* `eval` �\������]��

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

`quote`��`substitute`�̈Ⴂ
---
* `substitute`�̓��[�J���ȕϐ���u��������
* `quote`�͂��̂܂�

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

���w�肵��`eval`
---

* ��̊���`new.env()`�ō���
* ���̓��X�g�Ǝ������삪�ł���


```r
e <- new.env()
e$x <- 5
x <- 10 # Global�̊�
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

���̓��X�g��`eval`�̊��ɂł���
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

`filter`�͂��̋@�\�𗘗p���Ă���















```
processing file: r-lang-meta.Rpres
ok ?
args
ok ?
F
Quitting from lines 363-364 (r-lang-meta.Rpres) 
 filter(iris, Sepal.Length > 7.7) �ŃG���[: 
   �I�u�W�F�N�g 'Sepal.Length' ������܂��� 
 �Ăяo��:  knit ... withCallingHandlers -> withVisible -> eval -> eval -> filter
 ���s����~����܂���
```
