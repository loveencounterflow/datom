<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Vectorial NumbeRs (VNRs)](#vectorial-numbers-vnrs)
  - [The Problem](#the-problem)
  - [Vectors of Numbers](#vectors-of-numbers)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Vectorial NumbeRs (VNRs)

## The Problem

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


Now suppose for the upcoming edition, we would like to include a hundred or so new characters that we have found
are too important to be skipped over. We then face the question: how can we keep the numbering scheme and still
insert new characters?

> Closely related is the problem of how to represent arbitrary trees in RDBMSs that can handle insertions
> and deletions without renumbering; see e.g. [*Static Trees and Binary Fractions in PostgreSQL* by M.
> Glaesemann](https://seespotcode.net/2016/04/30/static-trees/) and [*Integer Labeling in Nested Intervals
> Model* by V. Tropashko](http://www.dbazine.com/oracle/or_articles/tropashko6/index.html); also see [Farey
> Fractions](https://en.wikipedia.org/wiki/Farey_sequence#Examples).

## Vectors of Numbers


**To Be Written**

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
* lists of integers
* used to order datoms, standard property name is `$vnr`
* ordering done per position in a lexicographic fashion, so
  * `[ 1, 2, ]` comes after `[ 1, 1, ]` and before `[ 1, 3, ]` (`[ 1, 2, ] ≺ [ 1, 1, ] ≺ [ 1, 3, ]`)
  * can extend to insert arbitrary number of elements in between any two given ones, e.g.
    `[ 1, 2, 0, ]`, `[ 1, 2, 1, ]`, `[ 1, 2, 2, ]` all come after `[ 1, 2, ]` but before `[ 1, 3, ]`
  * this is embodied in the `VNR.cmp a, b` method

**`### TAINT reformulate: ###`**

* When we agree that all VNRs `[ a0, a1, a2, ... an, ]` with `an != 0` are implicitly equivalent to all VNRs
  with the same sequence of elements, but followed by an arbitrary number of `0`s, then VNRs share the trait
  with rational numbers that, although there are only countably many of them, there are still arbitrarily
  many of them between any two distinct points.

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
  because `[ 4, 7, ]` is clearly not equal to `[ 4, 7, 0, ]` and so on, yet is considered to be in the same
  position; therefore, the relative ordering of these two VNRs is undefined. Since such an ordering is
  called partial this method has been called `cmp_partial`.

`cmp_partial()` is the default ordering method for VNRs because it allows to add arbitrary numbers of
items in a sequence before or after a given position (the reference) *without having to modify any
existing item*, only by knowing the reference's VNR. This is because `[ x, -1, ] ≺ ( [ x, 0, ] ≍ [ x, ] )
≺ [ x, +1, ]` in partial ordering ###

-----------------------------------------------------------------


<!-- ≺≍≻⊁⊀≿≾≽≼ -->

```
[ 1, 3, ] ≍ [ 1, 3, 0, ] ≍ [ 1, 3, 0, 0, ]
...
[ 1, 3, ] ≺ [ 1, 4, ]
[ 1, 3, 0, ] ≺ [ 1, 3, 1, ] ≺ [ 1, 4, ]
```

------------------------------------------------------------------------
