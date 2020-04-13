

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/TESTS/SELECT'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
jr                        = JSON.stringify
#...........................................................................................................
types                     = require '../types'
{ isa
  validate
  type_of }               = types


# #-----------------------------------------------------------------------------------------------------------
# @[ "selector keypatterns" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["",{"sigils":"","name":""},null]
#     ["^foo",{"sigils":"^","name":"foo"},null]
#     ["<foo",{"sigils":"<","name":"foo"},null]
#     ["  ",null,null]
#     [">foo",{"sigils":">","name":"foo"},null]
#     ["<>foo",{"sigils":"<>","name":"foo"},null]
#     ["<>^foo",{"sigils":"<>^","name":"foo"},null]
#     ["^ foo",null,null]
#     ["^prfx:foo",{"sigils":"^","prefix":"prfx","name":"foo"},null]
#     ["<prfx:foo",{"sigils":"<","prefix":"prfx","name":"foo"},null]
#     [">prfx:foo",{"sigils":">","prefix":"prfx","name":"foo"},null]
#     ["<>prfx:foo",{"sigils":"<>","prefix":"prfx","name":"foo"},null]
#     ["<>^prfx:foo",{"sigils":"<>^","prefix":"prfx","name":"foo"},null]
#     ["^<>",{"sigils":"^<>","name":""},null]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, error, ] in probes_and_matchers
#     await T.perform probe, matcher, error, ->
#       R = ( probe.match DATOM._selector_keypattern )?.groups ? null
#       return null unless R?
#       for key, value of R
#         delete R[ key ] if value is undefined
#       return R
#   done()
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "datom keypatterns" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["text",null,null]
#     ["^text",{"sigil":"^","name":"text"},null]
#     ["<bold",{"sigil":"<","name":"bold"},null]
#     [">bold",{"sigil":">","name":"bold"},null]
#     ["~collect",{"sigil":"~","name":"collect"},null]
#     ["~kwic:collect",{"sigil":"~","prefix":"kwic","name":"collect"},null]
#     ["<kwic:bar",{"sigil":"<","prefix":"kwic","name":"bar"},null]
#     [">kwic:bar",{"sigil":">","prefix":"kwic","name":"bar"},null]
#     [">!kwic:bar",null,null]
#     ["<>kwic:bar",null,null]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, error, ] in probes_and_matchers
#     await T.perform probe, matcher, error, ->
#       R = ( probe.match DATOM._datom_keypattern )?.groups ? null
#       return null unless R?
#       for key, value of R
#         delete R[ key ] if value is undefined
#       return R
#   done()
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "classify_selector" ] = ( T, done ) ->
#   probes_and_matchers = [
#     ["#justatag",["tag","justatag"],'illegal']
#     ["^bar",["keypattern",{"sigils":"^","name":"bar"}],null]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, error, ] in probes_and_matchers
#     await T.perform probe, matcher, error, ->
#       probe = ( -> ) if probe.startsWith '!!!'
#       R     = DATOM._classify_selector probe
#       if R[ 0 ] is 'keypattern'
#         for key, value of R[ 1 ]
#           delete R[ 1 ][ key ] if value is undefined
#       else if R[ 0 ] is 'function'
#         R[ 1 ] = null
#       return R
#   done()
#   return null

#-----------------------------------------------------------------------------------------------------------
@[ "select 2" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [[ {$key:'^number',$value:42,$stamped:true}, '^number#stamped:*'],true]
    [[ {$key:'<italic',$stamped:true}, '<italic#stamped:*'],true]
    [[ {$key:'<italic',$stamped:true}, '<italic#stamped:*'],true]
    [[ {$key:'<italic'}, '<italic#stamped:*'],true]
    [[ {$key:'<italic',$stamped:true}, '>italic#stamped:*'],false]
    [[ {$key:'<italic'}, '>italic#stamped:*'],false]
    [[ {$key:'^number',$value:42,$stamped:true}, '^number'],false]
    [[ {$key:'<italic',$stamped:true}, '<italic'],false]
    [[ {$key:'<italic',$stamped:true}, '>italic'],false]
    [[ {$key:'^number',$value:42}, '^number'],true]
    [[ {$key:'<italic',$stamped:true}, '>italic'],false]
    [[ {$key:"*data"},'*data'],null,'illegal selector']
    [[ {$key:"data>"},'data>'],null,'illegal selector']
    [[ {$key:"%data"},'%data'],null,'illegal selector']
    [[ {$key:"[data"},'[data'],true,null]
    [[ {$key:"data]"},'data]'],null,'illegal selector']
    [[ {$key:"]data"},']data'],true,null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, ->
      [ d, selector, ] = probe
      return select d, selector
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "select ignores values other than PODs" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [[ null, '^number',],false]
    [[ 123, '^number',],false]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ d, selector, ] = probe
      try
        resolve select d, selector
      catch error
        return resolve error.message
      return null
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "new_datom complains when value has `$key`" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [["^number",{"$value":123,}],{"$key":"^number","$value":123},null]
    [["^number",{"$value":123,"$key":"something"}],null,"value must not have attribute '\\$key'"]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ key, value, ] = probe
      resolve new_datom key, value
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "xxx" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [['^foo', { time: 1500000, value: "msg#1", }],{"time":1500000,"value":"msg#1","$key":"^foo"},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ key, value, ] = probe
      resolve new_datom key, value
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "new_datom (default settings)" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [["^number",null],{"$key":"^number"},null]
    [["^number",123],{"$key":"^number","$value":123},null]
    [["^number",{"$value":123,}],{"$key":"^number","$value":123},null]
    [["^number",{"value":123,}],{"$key":"^number","value":123},null]
    [["^number",{"$value":{"$value":123,}}],{"$key":"^number","$value": { "$value": 123, }, },null]
    [["^number",{"value":{"$value":123,}}],{"$key":"^number","value": { "$value": 123, }, },null]
    [["^number",{"$value":{"value":123,}}],{"$key":"^number","$value": { "value": 123, }, },null]
    [["^number",{"value":{"value":123,}}],{"$key":"^number","value": { "value": 123, }, },null]
    [["^value",123],{"$key":"^value","$value":123},null]
    [["<start",123],{"$key":"<start","$value":123},null]
    [[">stop",123],{"$key":">stop","$value":123},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ key, value, ] = probe
      resolve new_datom key, value
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "wrap_datom" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    wrap_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [["^text",'helo'],{"$key":"^wrapper","$value":{"$key":"^text","$value":"helo"}},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ key, value, ] = probe
      d               = new_datom key, value
      resolve wrap_datom '^wrapper', d
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "new_datom (without value merging)" ] = ( T, done ) ->
  DATOM                     = new ( require '../..' ).Datom { merge_values: false, }
  { new_datom
    select }                = DATOM.export()
  #.........................................................................................................
  probes_and_matchers = [
    [["^number",null],{"$key":"^number"},null]
    [["^number",123],{"$key":"^number","$value":123},null]
    [["^number",{"$value":123,}],{"$key":"^number","$value":{"$value":123}},null]
    [["^number",{"value":123,}],{"$key":"^number","$value":{"value":123}},null]
    [["^number",{"$value":{"$value":123,}}],{"$key":"^number","$value":{"$value": { "$value": 123, }, }, },null]
    [["^number",{"value":{"$value":123,}}],{"$key":"^number","$value":{"value": { "$value": 123, }}, },null]
    [["^number",{"$value":{"value":123,}}],{"$key":"^number","$value":{ "$value": { "value": 123, }}, },null]
    [["^number",{"value":{"value":123,}}],{"$key":"^number","$value":{ "value": { "value": 123, }}, },null]
    [["^value",123],{"$key":"^value","$value":123},null]
    [["<start",123],{"$key":"<start","$value":123},null]
    [[">stop",123],{"$key":">stop","$value":123},null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ key, value, ] = probe
      resolve new_datom key, value
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "freezing" ] = ( T, done ) ->
  DATOM_FREEZE                        = new ( require '../..' ).Datom { freeze: true, }
  { new_datom: new_datom_freeze, }    = DATOM_FREEZE.export()
  DATOM_NOFREEZE                      = new ( require '../..' ).Datom { freeze: false, }
  { new_datom: new_datom_nofreeze, }  = DATOM_NOFREEZE.export()
  #.........................................................................................................
  T.ok      Object.isFrozen new_datom_freeze    '^mykey'
  T.ok not  Object.isFrozen new_datom_nofreeze  '^mykey'
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "_regex performance, runaway test" ] = ( T, done ) ->
  ###
  See https://github.com/loveencounterflow/runaway-regex-test
  and select-benchmark in this project
  ###

#-----------------------------------------------------------------------------------------------------------
@[ "dirty" ] = ( T, done ) ->
  DATOM_DIRTY                         = new ( require '../..' ).Datom { dirty: true, }
  DATOM_NODIRTY                       = new ( require '../..' ).Datom { dirty: false, }
  DATOM_DEFAULT                       = new ( require '../..' ).Datom()
  #.........................................................................................................
  d = DATOM_DEFAULT.new_datom '^foo', { x: 42, y: 108, }
  T.eq ( DATOM_DIRTY.lets d,    ( d ) -> delete d.x ), { $key: '^foo', y: 108, $dirty: true,  }
  T.eq ( DATOM_NODIRTY.lets d,  ( d ) -> delete d.x ), { $key: '^foo', y: 108,                }
  T.eq ( DATOM_DEFAULT.lets d,  ( d ) -> delete d.x ), { $key: '^foo', y: 108,                }
  done()
  return null




############################################################################################################
if require.main is module then do =>
  # test @
  test @[ "dirty" ]
  # test @[ "wrap_datom" ]
  # test @[ "new_datom complains when value has `$key`" ]
  # test @[ "selector keypatterns" ]
  # test @[ "select 2" ]
  # test @[ "new_datom (default settings)" ]
  # debug new_datom '^helo', 42



