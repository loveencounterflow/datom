

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/TESTS/BASICS'
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


#-----------------------------------------------------------------------------------------------------------
@[ "fresh_datom" ] = ( T, done ) ->
  DATOM = require '../..'
  probes_and_matchers = [
    [ [ '^foo' ], { '$fresh': true, '$key': '^foo' }, null ]
    [ [ '^foo', { foo: 'bar' } ], { foo: 'bar', '$fresh': true, '$key': '^foo' }, null ]
    [ [ '^foo', 42 ], { '$value': 42, '$fresh': true, '$key': '^foo' }, null ]
    [ [ '^foo', 42, { '$fresh': false } ], { '$value': 42, '$fresh': true, '$key': '^foo' }, null ]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      resolve DATOM.fresh_datom probe...
      return null
  done()
  return null




############################################################################################################
if require.main is module then do =>
  # test @
  test @[ "fresh_datom" ]
  # test @[ "wrap_datom" ]
  # test @[ "new_datom complains when value has `$key`" ]
  # test @[ "selector keypatterns" ]
  # test @[ "select 2" ]
  # test @[ "new_datom (default settings)" ]
  # debug new_datom '^helo', 42



