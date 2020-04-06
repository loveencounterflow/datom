

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/VNR'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
{ jr
  assign }                = CND
#...........................................................................................................
types                     = require './types'
{ isa
  defaults
  validate }              = types
Multimix                  = require 'multimix'
LFT                       = require 'letsfreezethat'

#-----------------------------------------------------------------------------------------------------------
@new_vnr = ( source = null ) ->
  if source? then validate.vnr source else source = [ 0, ]
  return assign [], source

#-----------------------------------------------------------------------------------------------------------
@deepen = ( d, nr = 0 ) ->
  ### Given a vectorial line number `vnr`, return a copy of `vnr`, call it
  `vnr0`, which has an index of `0` appended, thus representing the pre-first `vnr` for a level of lines
  derived from the one that the original `vnr` pointed to. ###
  validate.vnr d if @settings.validate
  return [ d..., nr, ]

#-----------------------------------------------------------------------------------------------------------
@advance      = ( d ) -> @_advance_or_recede d, +1
@recede       = ( d ) -> @_advance_or_recede d, -1

# #-----------------------------------------------------------------------------------------------------------
# @_lower_bound = ( vnr ) ->
#   ### Return a new VNR `z` such that `( as_hollerith vnr ) > ( as_hollerith z )` holds; this is needed to
#   iterate over all rows within a given limit. ###
#   validate.vnr vnr
#   return [ vnr[ 0 ] - 1 ]

# #-----------------------------------------------------------------------------------------------------------
# @_upper_bound = ( vnr ) ->
#   ### Return a new VNR `z` such that `( as_hollerith vnr ) < ( as_hollerith z )` holds; this is needed to
#   iterate over all rows within a given limit. ###
#   validate.vnr vnr
#   return [ vnr[ 0 ] + 1 ]

#-----------------------------------------------------------------------------------------------------------
@_advance_or_recede = ( d, delta ) ->
  ### Given a vectorial line number `vnr`, return a copy of `vnr`, call it
  `vnr0`, which has its last index incremented by `1`, thus representing the vectorial line number of the
  next line in the same level that is derived from the same line as its predecessor. ###
  validate.vnr d if @settings.validate
  R                   = assign [], d
  R[ d.length - 1 ]  += delta
  return R

#-----------------------------------------------------------------------------------------------------------
@cmp_total = ( a, b ) ->
  ### Given two VNRs `𝖆` and `𝖇`, return `-1` if `𝖆` comes lexicographically before `𝖇`, `+1` if `𝖆` comes
  after `𝖇` and `0` if `𝖆` equals `𝖇`. This works by comparing all integers in `𝖆` and `𝖇` in a pairwise
  fashion and stopping at the first difference; if no difference is found, then either `𝖆` equals `𝖇` or
  else `𝖆` is the prefix of `𝖇` (so `𝖆` comes before `𝖇`) or vice versa. Because this method provides a
  *total* ordering over all VNRs—that is, any two VNRs are either identical (`𝖆 ≍ 𝖇 ⇔ 𝖆 = 𝖇`) or else the
  one comes before the other—it is called `cmp_total`. ###
  if @settings.validate
    validate.vnr a
    validate.vnr b
  min_idx = ( Math.min a.length, b.length ) - 1
  for idx in [ 0 .. min_idx ]
    ai = a[ idx ]
    bi = b[ idx ]
    return -1 if ai < bi
    return +1 if ai > bi
  return -1 if a.length < b.length
  return +1 if a.length > b.length
  return  0

#-----------------------------------------------------------------------------------------------------------
@cmp_partial = ( a, b ) ->
  # ≺≍≻
  ###

  XXX Like `cmp_total()`, but returns `0` in case either VNR is a prefix of the other, that is to say, e.g.
  `[ 4, 7, ]` is equivalent to `[ 4, 7, 0, ]`, `[ 4, 7, 0, 0, ]` and so on. This is not a total ordering
  because `[ 4, 7, ]` is clearly not equal to `[ 4, 7, 0, ]` and so on, yet is considered to be in the same
  position; therefore, the relative ordering of these two VNRs is undefined. Since such an ordering is
  called partial this method has been called `cmp_partial`.

  `cmp_partial()` is the default ordering method for VNRs because it allows to add arbitrary numbers of
  items in a sequence before or after a given position (the reference) *without having to modify any
  existing item*, only by knowing the reference's VNR. This is because `[ x, -1, ] ≺ ( [ x, 0, ] ≍ [ x, ] )
  ≺ [ x, +1, ]` in partial ordering ###

  if @settings.validate
    validate.vnr a
    validate.vnr b
  max_idx = ( Math.max a.length, b.length ) - 1
  for idx in [ 0 .. max_idx ]
    ai = a[ idx ] ? 0
    bi = b[ idx ] ? 0
    return -1 if ai < bi
    return +1 if ai > bi
  return  0

#-----------------------------------------------------------------------------------------------------------
@_cmp = null
@sort = ( vnrs ) ->
  ### Given a list of VNRs, return a copy of the list with the VNRs lexicographically sorted. ###
  validate.list vnrs if @settings.validate
  return ( assign [], vnrs ).sort @_cmp ?= @cmp2.bind @


#===========================================================================================================
# EXPORT
#-----------------------------------------------------------------------------------------------------------
MAIN = @
class Vnr extends Multimix
  @include MAIN, { overwrite: false, }

  #---------------------------------------------------------------------------------------------------------
  constructor: ( settings = null ) ->
    super()
    validate.datom_vnr_settings settings = { defaults.vnr_settings..., settings..., }
    @settings = LFT.freeze settings
    @Vnr      = Vnr
    return @

module.exports = new Vnr()


