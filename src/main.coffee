


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
minimatch                 = require 'minimatch'
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
  new_datom: ( $key, $value, other... ) =>
    ### When `other` contains a key `$`, it is treated as a hint to copy
    system-level attributes; if the value of key `$` is a POD that has itself a
    key `$`, then a copy of that value is used. This allows to write `new_datom
    ..., $: d` to copy system-level attributes such as source locations to a new
    datom. ###
    @types.validate.datom_key $key
    return @_new_datom $key, $value, other...

  #---------------------------------------------------------------------------------------------------------
  _new_datom: ( $key, $value, other... ) =>
    if $value?
      $value  = { $value, } if ( not @cfg.merge_values ) or ( not @types.isa.object $value )
      throw new Error "µ55632 value must not have attribute '$key'" if '$key' in Object.keys $value
      R       = assign {}, $value,  other..., { $key, }
    else
      R       = assign {},          other..., { $key, }
    while ( @types.isa.object R.$ ) and ( @types.isa.object R.$.$ ) then R.$ = @LFT._deep_copy R.$.$
    return @freeze R

  #---------------------------------------------------------------------------------------------------------
  new_fresh_datom: ( P... ) => @new_datom P..., { $fresh: true, }


  #=========================================================================================================
  #
  #---------------------------------------------------------------------------------------------------------
  _get_matchers: ( selectors ) -> ( @_get_matcher selector for selector in selectors )

  #---------------------------------------------------------------------------------------------------------
  _get_matcher: ( selector ) ->
    ### TAINT might make this method part of API ###
    return R if ( R = matcher_cache.get selector )?
    cfg =
      nocomment:                true
      preserveMultipleSlashes:  true
    re  = new RegExp ( minimatch.makeRe selector, cfg ).source, 'u'
    R   = ( x ) -> re.test x
    matcher_cache.set selector, R
    return R

  #---------------------------------------------------------------------------------------------------------
  select: ( d, selectors... ) =>
    throw new Error "µ86606 expected a selector, got none" unless selectors.length > 0
    return false unless ( ( @types.isa.object d ) and ( d.$key? ) )
    return false if ( d.$stamped ? false )
    # return ( @_get_matcher selector ) d.$key
    for matcher in @_get_matchers selectors
      return true if matcher d.$key
    return false


#===========================================================================================================
module.exports = { Datom, DATOM: new Datom(), }




