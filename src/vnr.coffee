

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


