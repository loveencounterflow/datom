

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
#...........................................................................................................
{ inspect }               = require 'util'
rpr = ( P... ) ->
  return ( \
    ( inspect x, { depth: Infinity, maxArrayLength: Infinity, breakLength: Infinity, compact: true, } ) \
      for x in P ).join ' '


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

#-----------------------------------------------------------------------------------------------------------
@[ "VNR sort 2" ] = ( T, done ) ->
  matchers =
    total:    [
      [ [ 1 ], [ 1, 0 ], [ 1, 0, -1 ], [ 1, 0, 1 ], [ 2 ], [ 2, -1 ], [ 2, 0 ], [ 2, 1, ] ]
      [ [ Infinity ], [ Infinity, -1 ], [ Infinity, 1 ] ]
      [ [ Infinity, -1, ], [ Infinity, 0, ], [ Infinity, 1, ], ]
      ]
    partial:  [
      [ [ 1, 0, -1 ], [ 1 ], [ 1, 0 ], [ 1, 0, 1 ], [ 2, -1 ], [ 2, 0 ], [ 2 ], [ 2, 1 ] ]
      [ [ 1, 0, -1 ], [ 1, 0 ], [ 1 ], [ 1, 0, 1 ], [ 2, -1 ], [ 2 ], [ 2, 0 ], [ 2, 1 ] ]
      [ [ 2, 0 ], [ 2 ], ]
      [ [ 2 ],    [ 2, 0 ], ]
      [ [ Infinity, -1, ], [ Infinity, ], [ Infinity, 1, ], ]
      [ [ Infinity, -1, ], [ Infinity, 0, ], [ Infinity, 1, ], ]
      ]
    fair:  [
      [ [ 1, 0, -1 ], [ 1 ], [ 1, 0 ], [ 1, 0, 1 ], [ 2, -1 ], [ 2 ], [ 2, 0 ], [ 2, 1 ] ]
      [ [ 2 ],    [ 2, 0 ], ]
      [ [ Infinity, -1, ], [ Infinity, ], [ Infinity, 1, ], ]
      [ [ Infinity, -1, ], [ Infinity, 0, ], [ Infinity, 1, ], ]
      [ [ 1, ], ]
      [ [ 1, ], [ 2, ] ]
      ]
  for ordering in [ 'total', 'partial', 'fair', ]
    VNR     = new ( require '../..' ).VNR.Vnr { ordering, }
    # VNR     = new ( require '../..' ).VNR.Vnr { ordering, validate: false, }
    for matcher in matchers[ ordering ]
      probe   = [ matcher..., ]
      await T.perform probe, matcher, null, -> return new Promise ( resolve, reject ) ->
        result  = VNR.sort probe
        T.ok probe isnt matcher
        T.ok probe isnt result
        T.eq result, matcher
        # debug '^334^', rpr result
        resolve result
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "VNR sort 3" ] = ( T, done ) ->
  VNR     = ( require '../..' ).VNR
  info CND.blue   'cmp_total    ', "[ 1, ],     [ 1, -1, ]", VNR.cmp_total   [ 1, ],     [ 1, -1, ]
  info CND.blue   'cmp_total    ', "[ 1, ],     [ 1,  0, ]", VNR.cmp_total   [ 1, ],     [ 1,  0, ]
  info CND.blue   'cmp_total    ', "[ 1, ],     [ 1, +1, ]", VNR.cmp_total   [ 1, ],     [ 1, +1, ]
  info CND.blue   'cmp_total    ', "----------------------"
  info CND.blue   'cmp_total    ', "[ 1, 0, ],  [ 1, -1, ]", VNR.cmp_total   [ 1, 0, ],  [ 1, -1, ]
  info CND.blue   'cmp_total    ', "[ 1, 0, ],  [ 1,  0, ]", VNR.cmp_total   [ 1, 0, ],  [ 1,  0, ]
  info CND.blue   'cmp_total    ', "[ 1, 0, ],  [ 1, +1, ]", VNR.cmp_total   [ 1, 0, ],  [ 1, +1, ]
  info()
  info CND.lime   'cmp_partial  ', "[ 1, ],     [ 1, -1, ]", VNR.cmp_partial [ 1, ],     [ 1, -1, ]
  info CND.lime   'cmp_partial  ', "[ 1, ],     [ 1,  0, ]", VNR.cmp_partial [ 1, ],     [ 1,  0, ]
  info CND.lime   'cmp_partial  ', "[ 1, ],     [ 1, +1, ]", VNR.cmp_partial [ 1, ],     [ 1, +1, ]
  info CND.lime   'cmp_partial  ', "----------------------"
  info CND.lime   'cmp_partial  ', "[ 1, 0, ],  [ 1, -1, ]", VNR.cmp_partial [ 1, 0, ],  [ 1, -1, ]
  info CND.lime   'cmp_partial  ', "[ 1, 0, ],  [ 1,  0, ]", VNR.cmp_partial [ 1, 0, ],  [ 1,  0, ]
  info CND.lime   'cmp_partial  ', "[ 1, 0, ],  [ 1, +1, ]", VNR.cmp_partial [ 1, 0, ],  [ 1, +1, ]
  info()
  info CND.steel  'cmp_fair     ', "[ 1, ],     [ 1, -1, ]", VNR.cmp_fair    [ 1, ],     [ 1, -1, ]
  info CND.steel  'cmp_fair     ', "[ 1, ],     [ 1,  0, ]", VNR.cmp_fair    [ 1, ],     [ 1,  0, ]
  info CND.steel  'cmp_fair     ', "[ 1, ],     [ 1, +1, ]", VNR.cmp_fair    [ 1, ],     [ 1, +1, ]
  info CND.steel  'cmp_fair     ', "----------------------"
  info CND.steel  'cmp_fair     ', "[ 1, 0, ],  [ 1, -1, ]", VNR.cmp_fair    [ 1, 0, ],  [ 1, -1, ]
  info CND.steel  'cmp_fair     ', "[ 1, 0, ],  [ 1,  0, ]", VNR.cmp_fair    [ 1, 0, ],  [ 1,  0, ]
  info CND.steel  'cmp_fair     ', "[ 1, 0, ],  [ 1, +1, ]", VNR.cmp_fair    [ 1, 0, ],  [ 1, +1, ]
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test for stable sort 2" ] = ( T, done ) ->
  n         = 1e4
  m         = Math.floor n / 3
  ds        = ( [ nr, ( CND.random_integer -m, +m ) ] for nr in [ 1 .. n ])
  ds.sort ( a, b ) -> a[ 1 ] - b[ 1 ]
  prv_r     = -Infinity
  prv_nr    = -Infinity
  is_stable = true
  for [ nr, r, ] in ds
    if r is prv_r
      is_stable = is_stable and nr > prv_nr
    prv_r   = r
    prv_nr  = nr
  T.ok is_stable
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "test VNR._first_nonzero_is_negative()" ] = ( T, done ) ->
  VNR                       = require '../vnr'
  #.........................................................................................................
  probes_and_matchers = [
    [[ [3,4,0,0,],        2, ], false, ]
    [[ [3,4,0,-1,],       2, ], true, ]
    [[ [3,4,0,-1,0,0,],   2, ], true, ]
    [[ [3,4,0,1,-1,0,0,], 2, ], false, ]
    [[ [3,4,0,1,-1,0,0,], 0, ], false, ]
    [[ [3,4,0,0,],        3, ], false, ]
    [[ [3,4,0,0,],        4, ], false, ]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ list, first_idx, ] = probe
      resolve VNR._first_nonzero_is_negative list, first_idx
  done()
  return null

############################################################################################################
if require.main is module then do =>
  test @
  # test @[ "VNR sort 2" ]
  # test @[ "VNR sort 3" ]
  # @[ "VNR sort 3" ]()
  # test @[ "test VNR._first_nonzero_is_negative()" ]




