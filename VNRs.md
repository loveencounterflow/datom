<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Vectorial NumbeRs (VNRs)](#vectorial-numbers-vnrs)
  - [The Problem](#the-problem)
  - [Vectors of Numbers](#vectors-of-numbers)
  - [VNRs with Infinity](#vnrs-with-infinity)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Vectorial NumbeRs (VNRs)

## The Problem

<!--
Suppose we wanted to publish a Chinese-English dictionary with the most common characters, ordered
alphabetically by their respected reading. In order to be able to uniquely identify each character in the
Dictionary, we give it a sequential number starting with 1; in this way, we might end up with a dictionary
similar to [*Mathews' Chinese–English
Dictionary*](https://en.wikipedia.org/wiki/Mathews%27_Chinese–English_Dictionary) ([preview
here](https://books.google.de/books?id=Pj_e2d3eHTQC&printsec=frontcover&dq=Mathew%27s+Chinese–English+Dictionary&hl=en&sa=X&ved=0ahUKEwid45mx-dDoAhXT8aYKHZjqAKEQ6AEIKjAA#v=onepage&q=Mathew's%20Chinese–English%20Dictionary&f=false))
where `U+963f 阿 a¹` is identified as *№&nbsp;1*, up to `U+8580 薀 yun¹, yun⁴` which is identified as
*№&nbsp;7773*, with 7771 characters in between. So far so good.

* `U+6e24 渤 po², po⁵` *№&nbsp;4985*
* `U+64d8 擘 po⁴, po⁵, pai¹` *№&nbsp;4985a*
* `U+62cd 拍 p'eh⁴, p'eh⁵, p'ai¹` *№&nbsp;4986*

* At least one added character with a numerical suffix: `U+752d 甭 pëng²` "不用 need not" *№&nbsp;5047½*
  (listed in Unihan as `5047.5`)

006c2f:氯 *№&nbsp;4194½*

Now suppose for the upcoming edition, we would like to include a hundred or so new characters that we have found
are too important to be skipped over. We then face the question: how can we keep the numbering scheme and still
insert new characters?
-->

When dealing with streams of data the relative order in which items appear is frequently of importance. This
ordering may be implicit in the data stream (e.g. when each item represents one line as read from a file) or
made explicit (when recording line numbers along with the text). Now suppose one wanted to parse several
fields from each line and make each field a seperate datom while keeping the original lines with their line
numbers:

```
# https://www.unicode.org/Public/14.0.0/ucd/UnicodeData-14.0.0d1.txt
linenr  text
90      0059;LATIN CAPITAL LETTER Y;Lu;0;L;;;;;N;;;;0079;
91      005A;LATIN CAPITAL LETTER Z;Lu;0;L;;;;;N;;;;007A;
92      005B;LEFT SQUARE BRACKET;Ps;0;ON;;;;;Y;OPENING SQUARE BRACKET;;;;
93      005C;REVERSE SOLIDUS;Po;0;ON;;;;;N;BACKSLASH;;;;
94      005D;RIGHT SQUARE BRACKET;Pe;0;ON;;;;;Y;CLOSING SQUARE BRACKET;;;;
95      005E;CIRCUMFLEX ACCENT;Sk;0;ON;;;;;N;SPACING CIRCUMFLEX;;;;
96      005F;LOW LINE;Pc;0;ON;;;;;N;SPACING UNDERSCORE;;;;
97      0060;GRAVE ACCENT;Sk;0;ON;;;;;N;SPACING GRAVE;;;;
98      0061;LATIN SMALL LETTER A;Ll;0;L;;;;;N;;;0041;;0041
99      0062;LATIN SMALL LETTER B;Ll;0;L;;;;;N;;;0042;;0042
```


; how could an explicit order

> Closely related is the problem of how to represent arbitrary trees in RDBMSs that can handle insertions
> and deletions without renumbering; see e.g. [*Static Trees and Binary Fractions in PostgreSQL* by M.
> Glaesemann](https://seespotcode.net/2016/04/30/static-trees/) and [*Integer Labeling in Nested Intervals
> Model* by V. Tropashko](http://www.dbazine.com/oracle/or_articles/tropashko6/index.html); also see [Farey
> Fractions](https://en.wikipedia.org/wiki/Farey_sequence#Examples).

## Vectors of Numbers


Sortierkriterium mit dem es möglich ist durch rein *lokale* Modifikationen unendlich viele neue Elemente
*sowohl vor als auch nach* jedem gegebenen Element einzufügen; diese Einfügungen behalten in ihrem
Sortierkriterium (der VNR) jeweils den Bezug zu dem Element, relativ zu dem sie eingefügt wurden (dies
könnte zB eine Zeilennummer in einem Datenquellfile sein, wo aus jeder Zeile im Laufe der Verarbeitung eine
gewisse Zahl von Einzeldaten durch fortschreitende Analyse erzeugt wird). VNRs eignen sich daher für linear
geordnete, stabil indizierte aber gleichwohl lokal modifizierbare und erweiterbare Datenströme. 'Stabilität'
bedeutet in diesem Zusammenhang, dass das Einfügen neuer Elemente niemals eine neue Durchnummerierung
aller oder auch nur einiger Elemente erfordert.

<!-- `$vnr`—'vectorial datom number', an array of positive integers that imposes a total ordering on datoms by
which I mean to say that given any two datoms `a`, `b` that are piped through the same stream either
`a.$vnr < b.$vnr` or `a.$vnr > b.$vnr` will always hold, and `a.$vnr == b[ '$vnr' ] <=> a is b`. "the
variable-length Vectorial Number VNR (which starts with the line number of the respective source file and
has additional positions added wherever a processing step inserted material)"
 -->



* submodule `vnr`, available as `DATOM.VNR`
* lists of numbers; most frequently positive integers, but negative integers, fractional numbers and
  infinity may also be used
* used to order datoms, standard property name is `$vnr`
* ordering done per position in a lexicographic fashion, so
  * `[ 1, 2, ]` comes after `[ 1, 1, ]` and before `[ 1, 3, ]` (`[ 1, 2, ] ≺ [ 1, 1, ] ≺ [ 1, 3, ]`)
  * can extend to insert arbitrary number of elements in between any two given ones, e.g.
    `[ 1, 2, 0, ]`, `[ 1, 2, 1, ]`, `[ 1, 2, 2, ]` all come after `[ 1, 2, ]` but before `[ 1, 3, ]`
  * this is embodied in the `VNR.cmp a, b` method
* VNRs like `[ -Infinity, ]` and `[ Infinity, ]` may be used to anchor elements at the beginning or the end
  of a sequence of arbitrary length

## VNRs with Infinity

Observe that while arbitrary amounts may be subtracted from or added to infinity without decreasing or
increasing it (that is, `∞ = ∞ - 1`. `∞ = ∞ + 1`, which entails that the sorting order of two elements `{
id: 'A', nr: Infinity, }`, `{ id: 'B', nr: Infinity + 1, }` is undefined with respect to `nr`).

However, with vectorial numbers, elements *can* be ordered both before and behind negative and positive
infinity.

This means that `{ id: 'A', $vnr: [ Infinity, ], }` will be sorted before `{ id: 'B', $vnr: [ Infinity, 1,
], }`, so in a sense there are vectorial numbers 'greater than infinity' when `[ Infinity, ] ≺ [ Infinity,
1, ]` (with `≺` 'precedes') is interpreted as `[ Infinity, ] < [ Infinity, 1, ]` (with `<` 'less than').

The practical utility for using `Infinity` as a VNR element lies in the ability to unambiguously anchor
datoms to the beginning or the end of a given sequence.


**`### TAINT reformulate: ###`**

* When we agree that all VNRs `[ a0, a1, a2, ... an, ]` with `an != 0` are implicitly equivalent to all VNRs
  with the same sequence of elements, but followed by an arbitrary number of `0`s, then VNRs share the trait
  with rational numbers that, although there are only countably many of them, there are still arbitrarily
  many of them between any two distinct points.

* VNRs may also be used in the form `[ linenr, colnr, ]` where the first two numbers identify the location
  of the origin of some piece of data in a data source file.

-----------------------------------------------------------------

* **`cmp_total = ( 𝖆, 𝖇 ) ->`**

  Given two VNRs `𝖆` and `𝖇`, return `-1` if `𝖆` comes lexicographically before `𝖇`, `+1` if `𝖆` comes after
  `𝖇` and `0` if `𝖆` equals `𝖇`. This works by comparing all integers in `𝖆` and `𝖇` in a pairwise fashion
  and stopping at the first difference; if no difference is found, then either `𝖆` equals `𝖇` or else `𝖆` is
  the prefix of `𝖇` (so `𝖆` comes before `𝖇`) or vice versa. Because this method provides a *total* ordering
  over all VNRs—that is, any two VNRs are either identical (`𝖆 ≍ 𝖇 ⇔ 𝖆 = 𝖇`) or else the one comes before
  the other—it is called `cmp_total`.

-----------------------------------------------------------------

* **`cmp_partial = ( 𝖆, 𝖇 ) ->`**

  Like `cmp_total()`, but returns `0` in case either VNR is a prefix of the other, that is to say, e.g. `[
  4, 7, ]` is equivalent to `[ 4, 7, 0, ]`, `[ 4, 7, 0, 0, ]` and so on. This is not a total ordering
  because `[ 4, 7, ]` is clearly not equal to `[ 4, 7, 0, ]` and so on, yet is considered to be equivalent
  (in the same position).

-----------------------------------------------------------------

* **`cmp_fair = ( 𝖆, 𝖇 ) ->`**

  Like `cmp_total()`, except for two unequal VNRs where one is the prefix of the other; in that case,
  the *longer* VNR is considered the *smaller* one if and only if its first non-zero element after the
  prefix is negative. For example, `cmp_fair [ 3, 5, 8, ], [ 3, 5, 8, 0, -11, ]` returns `+1` because
  the second VNR's first non-zero element after the common prefix `3, 5, 8` is `-11 < 0`.

`cmp_fair()` is the default ordering method for VNRs because it allows to add arbitrary numbers of
items in a sequence before or after a given position (the reference) *without having to modify any
existing item*, only by knowing the reference's VNR. This is because `[ x, -1, ] ≺ ( [ x, ] ≍ [ x, ] )
≺ [ x, +1, ]` in fair ordering.

> **NB**
> > "Previously, V8 used an unstable QuickSort for arrays with more than 10 elements. As of V8 v7.0 / Chrome
> > 70, [it] use[s] the stable TimSort algorithm."—[*Array.prototype.sort
> > stability*](https://mathiasbynens.be/demo/sort-stability)
>
> NodeJS started using V8 v7 with version 11.0.0, so *the following only applies to users running NodeJS
> older than version 11.0.0.*
>
> Sorting VNRs with a partial ordering will work with any version of NodeJS. An unstable sort, however, may
> occsasionally cause unpredictable behavior to occur when
> * sequences of more than 10 datoms
> * that contain repeated and/or equivalent but nonequal VNRs (such as `[ 1, ]` and `[ 1, 0, ]`)
> * are sorted according to their respective VNRs.
>
> In such cases, any seemingly unrelated change such as swapping out some VNRs or insertion or omission of
> any number of datoms may cause datoms with equal or equivalent VNRs to change places. Such changes would
> be reproducible but not predicatable (without intimate knowledge of the sorting algorithm's implementation
> details) and thus could conceivably lead to rare and hard-to-track Heisenbugs.
>
> Note that using VNRs such as `[ 1, ]` and `[ 1, 0, ]` in a single stream is discouraged because they
> should be considered alternative representation of the same value, in the same way that `0.99999...` is an
> alternative way to write `1`. Users should settle for the one or the other way and stick to it.

With total lexicographical ordering,

```
𝖆           𝖇             cmp_total( 𝖆, 𝖇 )
—————————————————————————————
[ 1, ],     [ 1, -1, ]    -1
[ 1, ],     [ 1,  0, ]    -1
[ 1, ],     [ 1, +1, ]    -1
—————————————————————————————
[ 1, 0, ],  [ 1, -1, ]    +1                  [ 1, 0, ] ≻ [ 1, -1, ]
[ 1, 0, ],  [ 1,  0, ]     0                  [ 1, 0, ] ≍ [ 1,  0, ]
[ 1, 0, ],  [ 1, +1, ]    -1                  [ 1, 0, ] ≺ [ 1, +1, ]
```

With partial lexicographical ordering,

```
𝖆           𝖇             cmp_partial( 𝖆, 𝖇 )
—————————————————————————————
[ 1, ],     [ 1, -1, ]    +1
[ 1, ],     [ 1,  0, ]     0
[ 1, ],     [ 1, +1, ]    -1
—————————————————————————————
[ 1, 0, ],  [ 1, -1, ]    +1
[ 1, 0, ],  [ 1,  0, ]     0
[ 1, 0, ],  [ 1, +1, ]    -1
```

With fair ordering,

```
𝖆           𝖇             cmp_fair( 𝖆, 𝖇 )
—————————————————————————————
[ 1, ],     [ 1, -1, ]    +1
[ 1, ],     [ 1,  0, ]    -1
[ 1, ],     [ 1, +1, ]    -1
—————————————————————————————
[ 1, 0, ],  [ 1, -1, ]    +1
[ 1, 0, ],  [ 1,  0, ]     0
[ 1, 0, ],  [ 1, +1, ]    -1
```


```
 𝖆         𝖇         ║      total                 ║       partial               ║      fair
═════════════════════╬════╪═══════════════════════╬════╪════════════════════════╬════╪════════════════════════
[ 1, ]    [ 1, -1, ] ║ -1 │  [ 1, ] ≺ [ 1, -1, ]  ║ +1 │  [ 1, ] ≻ [ 1, -1, ]  ║ +1 │  [ 1, ] ≻ [ 1, -1, ]
[ 1, ]    [ 1,  0, ] ║ -1 │  [ 1, ] ≺ [ 1,  0, ]  ║  0 │  [ 1, ] ≍ [ 1,  0, ]  ║ -1 │  [ 1, ] ≺ [ 1,  0, ]
[ 1, ]    [ 1, +1, ] ║ -1 │  [ 1, ] ≺ [ 1, +1, ]  ║ -1 │  [ 1, ] ≺ [ 1, +1, ]  ║ -1 │  [ 1, ] ≺ [ 1, +1, ]


—————————————————————————————
[ 1, 0, ],  [ 1, -1, ]    +1    [ 1, 0, ] ≻ [ 1, -1, ]
[ 1, 0, ],  [ 1,  0, ]     0    [ 1, 0, ] ≍ [ 1,  0, ]
[ 1, 0, ],  [ 1, +1, ]    -1    [ 1, 0, ] ≺ [ 1, +1, ]
```

<table>
<tr><th>𝖆</th><th>total</th><th>partial</th><th>fair</th> <th>𝖇</th></tr>
<tr><td><code>[ 1, ]</code></td> <td><code>-1  ≺ </code></td> <td><code>+1  ≻ </code></td><td><code>+1  ≻ </code></td>  <td><code>[ 1, -1, ]</code></td></tr>
<tr><td><code>[ 1, ]</code></td> <td><code>-1  ≺ </code></td> <td><code> 0  ≍ </code></td><td><code>-1  ≺ </code></td>  <td><code>[ 1,  0, ]</code></td></tr>
<tr><td><code>[ 1, ]</code></td> <td><code>-1  ≺ </code></td> <td><code>-1  ≺ </code></td><td><code>-1  ≺ </code></td>  <td><code>[ 1, +1, ]</code></td></tr>
</table>







-----------------------------------------------------------------


<!-- ≺≍≻⊁⊀≿≾≽≼ -->

```
[ 1, 3, ] ≍ [ 1, 3, 0, ] ≍ [ 1, 3, 0, 0, ]
...
[ 1, 3, ] ≺ [ 1, 4, ]
[ 1, 3, 0, ] ≺ [ 1, 3, 1, ] ≺ [ 1, 4, ]
```

------------------------------------------------------------------------
