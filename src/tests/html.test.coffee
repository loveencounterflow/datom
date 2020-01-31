
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/TESTS/HTML'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
{ jr, }                   = CND
#...........................................................................................................
DATOM                     = new ( require '../..' ).Datom { dirty: false, }
{ new_datom
  wrap_datom
  # lets
  select }                = DATOM.export()
#...........................................................................................................
test                      = require 'guy-test'


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "must quote attribute value" ] = ( T, done ) ->
  probes_and_matchers = [
    [ "",           true,   null, ]
    [ "\"",         true,   null, ]
    [ "'",          true,   null, ]
    [ "<",          true,   null, ]
    [ "<>",         true,   null, ]
    [ "foo",        false,  null, ]
    [ "foo bar",    true,   null, ]
    [ "foo\nbar",   true,   null, ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      must_quote = not DATOM.HTML.isa.datom_html_naked_attribute_value probe
      resolve must_quote
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML._as_attribute_literal" ] = ( T, done ) ->
  probes_and_matchers = [
    [ "",           "''",                       null, ]
    [ '"',          '\'"\'',                    null, ]
    [ "'",          "'&#39;'",                  null, ]
    [ "<",          "'&lt;'",                   null, ]
    [ "<>",         "'&lt;&gt;'",               null, ]
    [ "foo",        "foo",                      null, ]
    [ "foo bar",    "'foo bar'",                null, ]
    [ "foo\nbar",   "'foo&#10;bar'",            null, ]
    [ "'<>'",       "'&#39;&lt;&gt;&#39;'",     null, ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      resolve DATOM.HTML._as_attribute_literal probe
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.isa.datom_html_tagname" ] = ( T, done ) ->
  probes_and_matchers = [
    [ "",             false,  null, ]
    [ "\"",           false,  null, ]
    [ "'",            false,  null, ]
    [ "<",            false,  null, ]
    [ "<>",           false,  null, ]
    [ "foo bar",      false,  null, ]
    [ "foo\nbar",     false,  null, ]
    [ "foo",          true,   null, ]
    [ "此は何ですか", true,   null, ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      resolve DATOM.HTML.isa.datom_html_tagname probe
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.cast.html (singular tags)" ] = ( T, done ) ->
  probes_and_matchers = [
    [ [ '^foo', ],                                    "<foo/>",                                       ]
    [ [ '^foo', { height: 42,               }, ],     "<foo height=42/>",                             ]
    [ [ '^foo', { class: 'plain',           }, ],     "<foo class=plain/>",                           ]
    [ [ '^foo', { class: 'plain hilite',    }, ],     "<foo class='plain hilite'/>",                  ]
    [ [ '^foo', { editable: true,           }, ],     "<foo editable/>",                              ]
    [ [ '^foo', { empty: '',                }, ],     "<foo empty=''/>",                              ]
    [ [ '^foo', { specials: '<\n\'"&>',     }, ],     "<foo specials='&lt;&#10;&#39;\"&amp;&gt;'/>",  ]
    [ [ '^something', { one: 1, two: 2,     }, ],     "<something one=1 two=2/>",                     ]
    [ [ '^something', { z: 'Z', a: 'A',     }, ],     "<something a=A z=Z/>",                         ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      d = new_datom probe...
      resolve DATOM.HTML.cast.html d
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.cast.html (closing tags)" ] = ( T, done ) ->
  probes_and_matchers = [
    [ [ '>foo', ],                                    "</foo>",           ]
    [ [ '>foo', { height: 42,               }, ],     "</foo>",           ]
    [ [ '>foo', { class: 'plain',           }, ],     "</foo>",           ]
    [ [ '>foo', { class: 'plain hilite',    }, ],     "</foo>",           ]
    [ [ '>foo', { editable: true,           }, ],     "</foo>",           ]
    [ [ '>foo', { empty: '',                }, ],     "</foo>",           ]
    [ [ '>foo', { specials: '<\n\'"&>',     }, ],     "</foo>",           ]
    [ [ '>something', { one: 1, two: 2,     }, ],     "</something>",     ]
    [ [ '>something', { z: 'Z', a: 'A',     }, ],     "</something>",     ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      d = new_datom probe...
      resolve DATOM.HTML.cast.html d
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.cast.html (opening tags)" ] = ( T, done ) ->
  probes_and_matchers = [
    [ [ '<foo', ],                                    "<foo>",                                        ]
    [ [ '<foo', { height: 42,               }, ],     "<foo height=42>",                              ]
    [ [ '<foo', { class: 'plain',           }, ],     "<foo class=plain>",                            ]
    [ [ '<foo', { class: 'plain hilite',    }, ],     "<foo class='plain hilite'>",                   ]
    [ [ '<foo', { editable: true,           }, ],     "<foo editable>",                               ]
    [ [ '<foo', { empty: '',                }, ],     "<foo empty=''>",                               ]
    [ [ '<foo', { specials: '<\n\'"&>',     }, ],     "<foo specials='&lt;&#10;&#39;\"&amp;&gt;'>",   ]
    [ [ '<something', { one: 1, two: 2,     }, ],     "<something one=1 two=2>",                      ]
    [ [ '<something', { z: 'Z', a: 'A',     }, ],     "<something a=A z=Z>",                          ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      d = new_datom probe...
      resolve DATOM.HTML.cast.html d
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.cast.html (texts)" ] = ( T, done ) ->
  probes_and_matchers = [
    [ [ '^text', ],                                    "",                            ]
    [ [ '^text', { height: 42,               }, ],     "",                            ]
    [ [ '^text', { text: '<me & you>\n',     }, ],     "&lt;me &amp; you&gt;\n",      ]
    [ [ '<text', { z: 'Z', a: 'A',           }, ],     "<text a=A z=Z>",              ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      d = new_datom probe...
      resolve DATOM.HTML.cast.html d
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.cast.html (opening tags w/ $value)" ] = ( T, done ) ->
  probes_and_matchers = [
    [ [ '<foo', ],                                    "<foo>",                                        ]
    [ [ '<foo', { ignored: 'xxx', $value: { height: 42,              }, }, ], "<foo height=42>",                              ]
    [ [ '<foo', { ignored: 'xxx', $value: { class: 'plain',          }, }, ], "<foo class=plain>",                            ]
    [ [ '<foo', { ignored: 'xxx', $value: { class: 'plain hilite',   }, }, ], "<foo class='plain hilite'>",                   ]
    [ [ '<foo', { ignored: 'xxx', $value: { editable: true,          }, }, ], "<foo editable>",                               ]
    [ [ '<foo', { ignored: 'xxx', $value: { empty: '',               }, }, ], "<foo empty=''>",                               ]
    [ [ '<foo', { ignored: 'xxx', $value: { specials: '<\n\'"&>',    }, }, ], "<foo specials='&lt;&#10;&#39;\"&amp;&gt;'>",   ]
    [ [ '<something', { ignored: 'xxx', $value: { one: 1, two: 2,    }, }, ], "<something one=1 two=2>",                      ]
    [ [ '<something', { ignored: 'xxx', $value: { z: 'Z', a: 'A',    }, }, ], "<something a=A z=Z>",                          ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      d = new_datom probe...
      resolve DATOM.HTML.cast.html d
  #.........................................................................................................
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "DATOM.HTML.cast.html (system tags)" ] = ( T, done ) ->
  probes_and_matchers = [
    [ [ '~foo', ],                                    "<sys:foo/>",                                       ]
    [ [ '~foo', { height: 42,               }, ],     "<sys:foo height=42/>",                             ]
    [ [ '[foo', { class: 'plain',           }, ],     "<sys:foo class=plain>",                            ]
    [ [ '[foo', { class: 'plain hilite',    }, ],     "<sys:foo class='plain hilite'>",                   ]
    [ [ ']foo', { editable: true,           }, ],     "</sys:foo>",                                       ]
    [ [ ']foo', { empty: '',                }, ],     "</sys:foo>",                                       ]
    [ [ '~foo', { specials: '<\n\'"&>',     }, ],     "<sys:foo specials='&lt;&#10;&#39;\"&amp;&gt;'/>",  ]
    [ [ '~something', { one: 1, two: 2,     }, ],     "<sys:something one=1 two=2/>",                     ]
    [ [ '~something', { z: 'Z', a: 'A',     }, ],     "<sys:something a=A z=Z/>",                         ]
    ]
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      d = new_datom probe...
      resolve DATOM.HTML.cast.html d
  #.........................................................................................................
  done()
  return null


############################################################################################################
if module is require.main then do => # await do =>
  # await @_demo()
  test @
  help 'ok'

