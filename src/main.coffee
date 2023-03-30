


'use strict'


############################################################################################################
GUY                       = require 'guy'
{ alert
  debug
  help
  info
  plain
  praise
  urge
  warn
  whisper }               = GUY.trm.get_loggers 'DATOM'
{ rpr
  inspect
  echo
  log     }               = GUY.trm
{ assign }                = Object
#...........................................................................................................
{ get_base_types }        = require './types'
letsfreezethat            = require 'letsfreezethat'
letsfreezethat_nofreeze   = require 'letsfreezethat/nofreeze'
matcher_cache             = new Map()



#===========================================================================================================
# EXPORT
#-----------------------------------------------------------------------------------------------------------
MAIN = @
class Datom

  #---------------------------------------------------------------------------------------------------------
  constructor: ( cfg = null ) ->
    # super()
    @types    = get_base_types()
    @cfg      = letsfreezethat.freeze @types.create.datom_constructor_cfg cfg
    @LFT      = if @cfg.freeze then letsfreezethat else letsfreezethat_nofreeze
    @freeze   = @LFT.freeze
    @thaw     = @LFT.thaw
    GUY.props.hide @, 'matcher_cache', matcher_cache
    return undefined

  #---------------------------------------------------------------------------------------------------------
  lets: ( original, modifier ) =>
    draft = @thaw original
    if modifier?
      modifier draft
      ### TAINT simplify logic by rewriting as single term without double negatives ###
      if @cfg.dirty
        draft.$dirty = true unless draft.$dirty isnt original.dirty
    return @freeze draft

  #---------------------------------------------------------------------------------------------------------
  set: ( d, k, P... ) =>
    if @types.isa.text k
      throw new Error "µ67663 expected 1 value got #{count}" unless ( count = P.length ) is 1
      return @lets d, ( d ) -> d[ k ] = P[ 0 ]
    return @lets d, ( d ) -> d[ k ]  = v for k, v of assign {}, k, P...

  #---------------------------------------------------------------------------------------------------------
  unset: ( d, k ) => @lets d, ( d ) -> delete d[ k ]

  #---------------------------------------------------------------------------------------------------------
  stamp: ( d, P... ) =>
    ### Set the `$stamped` attribute on datom to mark it as processed. Stamped datoms will not be selected
    by the `select` method unless tag '#stamped' is used. ###
    return @lets d, ( d ) -> assign d, P..., { $stamped: true, }

  #---------------------------------------------------------------------------------------------------------
  unstamp: ( d ) =>
    return d unless d.$stamped
    return @lets d, ( d ) -> delete d.$stamped

  #---------------------------------------------------------------------------------------------------------
  is_stamped: ( d ) => d.$stamped ? false ### i.e. already processed? ###
  is_fresh:   ( d ) => d.$fresh   ? false ### i.e. created within stream? ###
  is_dirty:   ( d ) => d.$dirty   ? false ### i.e. modified? ###
  is_datom:   ( x ) => @types.isa.datom_datom x

  #---------------------------------------------------------------------------------------------------------
  new_datom: ( $key, P... ) =>
    @types.validate.datom_key $key
    return @freeze assign {}, P..., { $key, }

  #---------------------------------------------------------------------------------------------------------
  new_fresh_datom: ( P... ) => @new_datom P..., { $fresh: true, }


  #=========================================================================================================
  #
  #---------------------------------------------------------------------------------------------------------
  _get_matcher: ( selector ) ->
    ### TAINT might make this method part of API ###
    return R if ( R = matcher_cache.get selector )?
    selector  = selector.replace /(?<!\\)\?/g, '.?'
    selector  = selector.replace /(?<!\\)\*/g, '.*'
    selector  = "^(?:#{selector})$"
    re        = new RegExp selector, 'u'
    R         = ( x ) -> re.test x
    matcher_cache.set selector, R
    return R

  #---------------------------------------------------------------------------------------------------------
  select: ( d, selectors... ) =>
    throw new Error "µ86606 expected a selector, got none" unless selectors.length > 0
    return false unless ( ( @types.isa.object d ) and ( d.$key? ) )
    return false if ( d.$stamped ? false )
    #.......................................................................................................
    for selector in selectors
      return true if ( @_get_matcher selector ) d.$key
    return false


#===========================================================================================================
module.exports = { Datom, DATOM: new Datom(), }




