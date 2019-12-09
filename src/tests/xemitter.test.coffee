

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
  arity_of
  type_of }               = types

#-----------------------------------------------------------------------------------------------------------
@[ "_" ] = ( T, done ) ->
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
@[ "public API shape" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    new_xemitter
    select }                = DATOM.export()
  #.........................................................................................................
  XE = new_xemitter()
  T.ok isa.asyncfunction  XE.emit
  T.ok isa.asyncfunction  XE.delegate
  T.ok isa.function       XE.contract
  T.ok isa.function       XE.listen_to
  T.ok isa.function       XE.listen_to_all
  T.eq XE.emit.length,              2
  T.eq XE.delegate.length,          2
  T.eq XE.contract.length,          2
  T.eq XE.listen_to.length,         2
  T.eq XE.listen_to_all.length,     1
  T.eq XE.listen_to_unheard.length, 1
  known_keys = [ 'emit', 'delegate', 'contract', 'listen_to', 'listen_to_all', 'listen_to_unheard', ]
  T.eq ( k for k of XE when ( not k.startsWith '_' ) and ( k not in known_keys ) ), []
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "emit equivalently accepts key, value or datom" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    new_xemitter
    select }                = DATOM.export()
  #.........................................................................................................
  count = 0
  XE    = new_xemitter()
  XE.listen_to '^mykey', ( d ) ->
    count++
    T.eq d, { $key: '^mykey', $value: 42, }
  await XE.emit '^mykey', 42
  await XE.emit new_datom '^mykey', 42
  await XE.emit new_datom '^notmykey', 42
  T.eq count, 2
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "throws when more than one contractor is added for given event key" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    new_xemitter
    select }                = DATOM.export()
  XE                        = new_xemitter()
  #.........................................................................................................
  XE.contract '^mykey', ( d ) ->
  XE.contract '^otherkey', ( d ) ->
  T.throws /already has a primary listener/, ( -> XE.contract '^otherkey', ( d ) -> )
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "can listen to events that have no specific listener" ] = ( T, done ) ->
  DATOM                     = require '../..'
  { new_datom
    new_xemitter
    select }                = DATOM.export()
  XE                        = new_xemitter()
  #.........................................................................................................
  keys =
    listen:     []
    contract:   []
    all:        []
    unheard:    []
  XE.listen_to          '^mykey',     ( d       ) ->  keys.listen   .push d.$key
  XE.contract           '^otherkey',  ( d       ) ->  keys.contract .push d.$key
  XE.listen_to_all                    ( key, d  ) ->  keys.all      .push d.$key
  XE.listen_to_unheard                ( key, d  ) ->  keys.unheard  .push d.$key
  await XE.emit '^mykey'
  await XE.emit '^otherkey'
  await XE.emit '^thirdkey'
  # debug keys
  T.eq keys, {
    listen:   [ '^mykey',                           ],
    contract: [ '^otherkey',                        ],
    all:      [ '^mykey', '^otherkey', '^thirdkey', ],
    unheard:  [ '^thirdkey',                        ], }
  done()
  return null





############################################################################################################
if require.main is module then do =>
  test @
  # test @[ "public API shape" ]



