


# Datom &#x269b;


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Export Bound Methods](#export-bound-methods)
- [Creation of Bespoke Library Instances](#creation-of-bespoke-library-instances)
- [Configuration Parameters](#configuration-parameters)
- [Methods](#methods)
  - [Freezing & Thawing](#freezing--thawing)
  - [Stamping](#stamping)
  - [Type Testing](#type-testing)
  - [Value Creation](#value-creation)
  - [Selecting](#selecting)
- [System Properties](#system-properties)
- [WIP](#wip)
  - [PipeDreams Datoms (Data Events)](#pipedreams-datoms-data-events)
  - [`select = ( d, selector ) ->`](#select---d-selector---)
  - [The XEmitter (XE) Sub-Module](#the-xemitter-xe-sub-module)
    - [XE Sending API](#xe-sending-api)
    - [XE Receiving API](#xe-receiving-api)
    - [Sample](#sample)
    - [Managing Scope](#managing-scope)
- [Vectorial NumbeRs (VNRs)](#vectorial-numbers-vnrs)
- [To Do](#to-do)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


standardized immutable objects in the spirit of datomic, especially suited for use in data pipelines


**NOTE: Documentation is still fragmentary. WIP.**

# Export Bound Methods

If you plan on using methods like `new_datom()` or `select()` a lot, consider using `.export()`:

```coffee
DATOM         = require 'datom'
{ new_datom
  select }    = DATOM.export()
```

Now `new_datom()` and `select()` are methods bound to `DATOM`. (Observe that because of the JavaScript
'tear-off' effect, when you do `method = DATOM.method`, then `method()` will likely fail as its reference to
`this` has been lost.)

# Creation of Bespoke Library Instances

In order to configure a copy of the library, pass in a settings object:

```coffee
_DATOM        = require 'datom'
settings      = { merge_values: false, }
DATOM         = new _DATOM.Datom settings
{ new_datom
  select }    = DATOM.export()
```

Or, mode idiomatically:

```coffee
DATOM         = new ( require 'datom' ).Datom { merge_values: false, }
{ new_datom
  select }    = DATOM.export()
```

The second form also helps to avoid accidental usage of the result of `require 'datom'`, which is of
course the same library with a different configuration.

# Configuration Parameters

* **`merge_values`** (boolean, default: `true`)—Whether to merge attributes of the second argument to
  `new_datom()` into the resulting value. When set to `false`, `new_datom '^somekey', somevalue` will always
  result in a datom `{ $key: '^somekey', $value: somevalue, }`; when left to the default, and if `somevalue`
  is an object, then its attributes will become attributes of the datom, which may result in name clashes in
  case any attribute name should start with a `$` (dollar sign).

* **`freeze`** (boolean, default: `true`)—Whether to freeze datoms. When set to `false`, no freezing will
  be performed, which may entail slightly improved performance.

* **`dirty`** (boolean, default: `true`)—Whether to automatically set `{ $dirty: true, }` when the copy
  of a datom has been treated with `lets()` and a modifyer function.


# Methods

## Freezing & Thawing

* **`@freeze = ( d ) ->`**
* **`@thaw   = ( d ) ->`**
* **`@lets = ( original, modifier ) ->`**
* **`@set = ( d, k, P... ) ->`**
* **`@unset = ( d, k ) ->`**

## Stamping

* **`@stamp = ( d, P... ) ->`**
* **`@unstamp = ( d ) ->`**

## Type Testing

* **`@is_system = ( d ) ->`**
* **`@is_stamped = ( d ) ->`**
* **`@is_fresh   = ( d ) ->`**
* **`@is_dirty   = ( d ) ->`**

## Value Creation

* **`@new_datom = ( $key, $value, other... ) ->`**
* **`@new_single_datom = ( $key, $value, other... ) ->`**
* **`@new_open_datom   = ( $key, $value, other... ) ->`**
* **`@new_close_datom  = ( $key, $value, other... ) ->`**
* **`@new_system_datom = ( $key, $value, other... ) ->`**
* **`@new_text_datom   = (       $value, other... ) ->`**
* **`@new_end_datom    =                            ->`**
* **`@new_warning = ( ref, message, d, other...  ) ->`**

## Selecting

* **`@select = ( d, selector ) ->`**

# System Properties

* **`d.$key`**—key (i.e., type) of a datom.
* **`d.$value`**—'the' proper value of a datom. This is always used in case `new_datom()` was called with a
  non-object in the value slot (as in `new_datom '^mykey', 123`), or when the library was configured with `{
  merge_values: false, }`.—In case there is no `d.$value`, the datom's proper value is the object that would
  result from deleting all properties whose names start with a `$` (dollar sign).
* **`d.$dirty`**—whether the object has been (thawed, then) changed (and then frozen again) since its
  `$dirty` property was last cleared or set to `false`.
* **`d.$stamped`**—whether the object has been marked as 'stamped' (i.e., processed).

-------------------------------------------------------------------------------

# WIP

**The below copied from PipeDreams docs, to be updated**

## PipeDreams Datoms (Data Events)

Data streams—of which [pull-streams](https://pull-stream.github.io/),
[PipeStreams](https://github.com/loveencounterflow/pipestreams), and [NodeJS
Streams](https://nodejs.org/api/stream.html) are examples—do their work by
sending pieces of data (that originate from a data source) through a number of
transforms (to finally end up in a data sink).<sup>*note*</sup>

> (*note*) I will ignore here alternative ways of dealing with streams, especially
> the [`EventEmitter` way of dealing with streamed
> data](https://nodejs.org/api/stream.html#stream_api_for_stream_consumers).
> When I say 'streams', I also implicitly mean 'pipelines'; when I say
> 'pipelines', I also implicitly mean 'pipelines to stream data' and 'streams'
> in general.

When NodeJS streams started out, the thinking about those streams was pretty
much confined to saying that ['a stream is a series of
bytes'](http://dominictarr.com/post/145135293917/history-of-streams). Already back then,
an alternative view took hold (I'm slightly paraphrasing here):

> The core interpretation was that stream could be buffers or strings - but the
> userland interpretation was that a stream could be anything that is
> serializeable [...] it was a sequence of buffers, bytes, strings or objects.
> Why not use the same api?

I will no repeat here [what I've written about perceived shortcomings of NodeJS
streams](https://github.com/loveencounterflow/pipestreams/blob/master/pipestreams-manual/chapter-00-comparison.md);
instead, let me iterate a few observations:

* In streaming, data is just data. There's no need for having [a separate
  'Object Mode'](https://nodejs.org/api/stream.html#stream_object_mode) or
  somesuch.

* There's a single exception to the above rule, and that is when the data item
  being sent down the line is `null`. This has historically—by both NodeJS
  streams and pull-streams—been interpreted as a termination signal, and I'm not
  going to change that (although at some point I might as well).

* When starting out with streams and building fairly simple-minded pipelines,
  sending down either raw pieces of business data or else `null` to indicate
  termination is enough to satisfy most needs. However, when one transitions to
  more complex environments, raw data is not sufficient any more: When
  processing text from one format to another, how could a downstream transform
  tell whether a given piece of text is raw data or the output of an upstream
  transform?

  Another case where raw data becomes insufficient are circular
  pipelines—pipelines that re-compute (some or all) output values in a recursive
  manner. An example which outputs the integer sequences of the [Collatz
  Conjecture](https://en.wikipedia.org/wiki/Collatz_conjecture) is [in the tests
  folder](https://github.com/loveencounterflow/pipedreams/blob/master/src/tests/circular-pipelines.test.coffee#L36).
  There, whenever we see an even number `n`, we send down that even number `n`
  alongside with half its value, `n/2`; whenever we see an odd number `n`, we
  send it on, followed by its value tripled plus one, `3*n+1`. No matter whether
  you put the transform for even numbers in front of that for odd numbers or the
  other way round, there will be numbers that come out at the bottom that need
  to be re-input into the top of the pipeline, and since there's no telling in
  advance how long a Collatz sequence will be for a given integer, it is, in the
  general case, insufficient to build a pipeline made from a (necessarily
  finite) repetitive sequence of copies of those individual transforms. Thus,
  classical streams cannot easily model this kind of processing.

The idea of **datoms**—short for *data atoms*, a term borrowed from [Rich
Hickey's Datomic](https://www.infoq.com/articles/Datomic-Information-Model)—is
to simply to wrap each piece of raw data in a higher-level structure. This is of
course an old idea, but not one that is very prevalent in NodeJS streams, the
fundamental assumption (of classical stream processing) being that all stream
transforms get to process each piece of data, and that all pieces of data are of
equal status (with the exception of `null`).

The PipeDreams sample implementation of Collatz Sequences uses datoms to (1)
wrap the numerical pieces of data, which allows to mark data as processed
(a.k.a. 'stamped'), to (2) mark data as 'to be recycled', and to (3) inject
system-level `sync`hronization signals into the data stream to make sure that
recycled data gets processed before new data is allowed into the stream.

In PipeDreams datoms, **each piece of data is explicitly labelled for its
type**; **each datom may have a different status**: there are **system-level
datoms that serve to orchestrate the flow of data within the pipeline**; there
are **user-level datoms which originate from the application**; there are
**datoms to indicate the opening and closing of regions (phases) in the data
stream**; there are **stream transforms that listen to and act on specific
system-level events**.

Datoms are JS objects that must minimally have a `key` property, a string that
specifies the datom's category, namespace and name; in addition, they may have a
`value` property with the payload (where desired), and any number of other
attributes. The property `$` is used to carry metadata (e.g. from which line in
a source file a given datom was generated from). Thus, we may give the outline
of a datom as (in a rather informal notation) `d := { $key, ?$value, ?$stamped,...,
?$, }`.

The `key` of a datom must be a string that consists of at least two parts, the
`sigil` and the `name`. The `sigil`, a single punctuation character, indicates
the 'category' of each datom; there are two levels and three elementary
categories, giving six types of datoms:

* Application level:
  * `^` for **data datoms** (a.k.a. 'singletons'),
  * `<` for **start-of-region datoms**,
  * `>` for **end-of-region datoms**.

* System level:
  * `~` for **data datoms**,
  * `[` for **start-of-region datoms**,
  * `]` for **end-of-region datoms**.

<!-- System-level events, in particular those without further payload data, are also
called 'signals'; thus, `~collect` is a 'collect signal', and `[data` is a
'start-of-data signal'. Aggregate transforms such as `$collect()`, `$sort()` and
so on listen to the signals of the same name, `~collect` and `~sort`: In the
case of `$collect()`, a collect signal will trigger the sending of the
collection as it looks at that point in time; likewise, `$sort()` will react to
a sort signal by sending all buffered events in the configured ordering.
 -->

Normally, one will probably want to send around business data inside (the
`value` property of) application-level data datoms (hence their name, also
shortened to D-datoms); however, one can also set other properties of datom
objects, or send data around using properties of start- or end-of-region datoms.

Region events are intended to be used e.g. when parsing text with markup; say
you want to turn a snippet of HTML like this:

```
<document><div>Helo <em>world!</em></div></document>
```

into another textual representation, you may want to turn that into a sequence
of datoms similar to these, in the order of sending and regions symbolized by
boxes:<sup>*note*</sup>

```
--------------------------------------------------------+
  { key: '<document',                   }   # d1        |
------------------------------------------------------+ |
  { key: '<div',                        }   # d2      | |
  { key: '^text',     value: "Helo ",   }   # d3      | |
----------------------------------------------------+ | |
  { key: '<em',                         }   # d4    | | |
  { key: '^text'      value: "world!",  }   # d5    | | |
  { key: '>em',                         }   # d6    | | |
----------------------------------------------------+ | |
  { key: '>div',                        }   # d7      | |
------------------------------------------------------+ |
  { key: '>document',                   }   # d8        |
--------------------------------------------------------+
```

> *note* by 'in the order of sending' I mean you'd have to send datom `d1`
> first, then `d2` and so on. Trivial until you imagine you write a pipeline and
> then picture how the events will travel down that pipeline:
>
> `pipeline.push $do_this()             # s1, might be processing d3 right now`<br>
> `pipeline.push $do_that()             # s2, might be processing d2 right now`<br>
> `pipeline.push $do_something_else()   # s3, might be processing d1 right now`<br>
>
> Although there's really no telling whether step `s3` will really process datom
> `d1` at the 'same point in time' that step `s2` processes datom `d2` and so on
> (in the strict sense, this is hardly possible in a single-threaded language
> anyway), the visualization still holds a grain of truth: stream transforms
> that come 'later' (further down) in the pipeline will see events near the top
> of your to-do list first, and vice versa. This can be mildly confusing.


## `select = ( d, selector ) ->`

The `select` method can be used to determine whether a given event `d` matches a
set of conditions; typically, one will want to use `select d, selector` to decide
whether a given event is suitable for processing by the stream transform at
hand, or whether it should be passed on unchanged.

The current implementation of `select()` is much dumber and faster than its predecessors; where previously,
it was possible to match datoms with multiple selectors that contained multiple sigils and so forth, the new
version does little more than check wheter the single selector allowed equals the given datom's `key`
value—that's about it, except that one can still `select d, '^somekey#stamped'` to match both unstamped and
stamped datoms.



## The XEmitter (XE) Sub-Module

### XE Sending API

* **`XE.emit = ( key, d ) ->`** emit (a.k.a. 'publish', 'send to whom it may concern') an event. To
  be called either as `XE.emit '^mykey', 'myvalue'` or as `XE.emit PD.new_event '^mykey', 'myvalue'` (in
  which latter case the datom's key will become the channel key). When called with await as in
  `return_values = await XE.emit '^foo', ...`, `return_values` will be a list with all values returned by
  all listeners that got called for this event.

* **`XE.delegate = ( key, d ) ->`** like `XE.emit()` but will pick out and unwrap the event value
  from the event contractor (see below). If no event contractor was listening, an error will be raised.

### XE Receiving API

* **`XE.listen_to_all = ( listener ) ->`** Register a listener for all events.

* **`XE.listen_to_unheard = ( listener ) ->`** Register a listener for all events that do not have a
  listener or a contractor.

* **`XE.listen_to     = ( key, listener ) ->`** Register a listener for events that match `key`. No
  pattern matching is implemented atm, so you can only listen to all keys or a single key.

* **`XE.contract      = ( key, listener ) ->`** Register a contractor (a.k.a. 'result producer') for
  events that match `key`.

<!-- The above methods—`XE.listen_to_all()`, `XE.listen_to()` and `XE.contract()`—will return an `unsubscribe()`
function that, when called once, will unsubscribe the event listener from the event.
 -->

### Sample

```coffee
PD                        = require 'pipedreams'
defer                     = setImmediate
XE                        = PD.XE.new_scope()

#-----------------------------------------------------------------------------------------------------------
### Register a 'contractor' (a.k.a. 'result producer') for `^plus-async` events; observe that asynchronous
contractors should return a promise: ###
XE.contract '^plus-async', ( d ) =>
  return new Promise ( resolve, reject ) =>
    defer => resolve d.value.a + d.value.b

############################################################################################################
do =>
  info 'µ28823-5', await XE.emit PD.new_event '^plus-async', { a: 42, b: 108, }
  # in case other listeners were registered that returned values like `'listener #1'` and so on, the
  # returned list of values might look like:
  # -> [ 'listener #4', { key: '~xemitter-preferred', value: 150 }, 'listener #1', 'listener #2' ]

  ### When using `delegate()` instead of `emit()`, the preferred value (a.k.a. '*the* event result')
  will be picked out of the list and unwrapped for you: ###
  info 'µ28823-6', await XE.delegate PD.new_event '^plus-async', { a: 42, b: 108, }
  # -> 150

```

For a demo with more coverage, have a look at
[experiments/demo-xemitter.coffee](https://github.com/loveencounterflow/pipedreams/blob/master/blob/master/src/experiments/demo-xemitter.coffee).

### Managing Scope

Typically, you'll start using XEmitter with `XE = PD.XE.new_scope()`; this creates a new 'scope' for events.
Only methods that emit and listen to the same scope can exchange messages. When used within an application,
you will want to publish that scope to all participating modules; one way to do so is to write a dedicated
module with a single line in it, `module.exports = ( require 'pipedreams' ).XE.new_scope()`.

# Vectorial NumbeRs (VNRs)

Where a consistent relative ordering of streams of datoms is needed, especially if any number of datoms may
get deleted and inserted at some mid-stream point, [Vectorial Numbers (VNRs)](./VNRs.md), which
are implemented as lists of integers, can be used to avoid a re-numbering of elements and still be able to
insert arbitrarily many new elements between any two given elements.


# To Do

* [ ] implement piecemeal structural validation such that on repeated calls to a validator instance's
  `validate()` method an error will be thrown as soon as unbalanced regions (delimeted by `{ $key: '<token',
  ..., }` and `{ $key: '>token', ..., }`) are encountered.

* [X] implement Vectorial NumbeRs (VNRs)
* [ ] document Vectorial NumbeRs (VNRs)
* [ ] implement & document standard attributes, `$`-prefixed and otherwise (?), such as
  * [ ] `^text`—key for 'text datoms'
  * [ ] `text`—the underlying source text where code, data is parsed
  * [ ] `$`—'produced by'
  * [ ] `$ref`—do we still use this? See DataMill
  * [ ] `$pos`? `$range`? for `[ start, stop, ]` pairs, indices into a source; use inclusive or exclusive
    upper bound?
  * [ ] `$loc`? for `[ line_nr, col_nr, ]` pairs; NB might also want to use stop position of ranges
* [X] make `{ dirty: false, }` the default setting (i.e. not marking changed datoms)





