

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/TESTS/VNR'
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
# @[ "VNR 1" ] = ( T, done ) ->
#   VNR                       = require '../vnr'
#   DATOM                     = new ( require '../..' ).Datom { merge_values: false, }
#   { new_datom
#     select }                = DATOM.export()
#   #.........................................................................................................
#   probes_and_matchers = [
#     [["^number",null],{"$key":"^number"},null]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, error, ] in probes_and_matchers
#     await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
#       [ key, value, ] = probe
#       debug '^223-1^', d = VNR.new_vnr()
#       debug '^223-2^', d = VNR.new_vnr      [ 4, 6, 5, ]
#       debug '^223-3^', d = VNR.deepen       d
#       debug '^223-4^', d = VNR.deepen       d, 42
#       debug '^223-5^', d = VNR.advance      d
#       debug '^223-6^', d = VNR.recede       d
#       # debug '^223-7^', d = VNR._lower_bound d
#       # debug '^223-8^', d = VNR._upper_bound d
#       resolve new_datom key, value
#   done()
#   return null

#-----------------------------------------------------------------------------------------------------------
test_basics = ( T, VNR ) ->
  T.eq ( d = VNR.new_vnr()                 ), [ 0, ]
  T.eq ( d = VNR.new_vnr      [ 4, 6, 5, ] ), [ 4, 6, 5, ]
  T.eq ( d = VNR.deepen       d            ), [ 4, 6, 5, 0, ]
  T.eq ( d = VNR.deepen       d, 42        ), [ 4, 6, 5, 0, 42, ]
  T.eq ( d = VNR.advance      d            ), [ 4, 6, 5, 0, 43, ]
  T.eq ( d = VNR.recede       d            ), [ 4, 6, 5, 0, 42, ]
  T.ok ( VNR.new_vnr  d ) isnt d
  T.ok ( VNR.deepen   d ) isnt d
  T.ok ( VNR.advance  d ) isnt d
  T.ok ( VNR.recede   d ) isnt d
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "VNR 1" ] = ( T, done ) ->
  test_basics T, require '../vnr'
  test_basics T, ( require '../..' ).VNR
  done()
  return null




############################################################################################################
if require.main is module then do =>
  test @
  # test @[ "wrap_datom" ]




