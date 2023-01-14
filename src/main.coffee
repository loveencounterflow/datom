


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



#===========================================================================================================
# SELECT
#-----------------------------------------------------------------------------------------------------------
p1 = /// # `\x23` used instead of `\#` which causes syntax error (???)
  ^
    (?<skey>
      (?<sigil>            [  < ^ > \[ ~ \] \x23 ]  )
      (?<key>              [^ < ^ > \[ ~ \] \x23 ]* )
    )
  $ ///u
p2 = /// # `\x23` used instead of `\#` which causes syntax error (???)
  ^
    (?<skey>
      (?<sigil>            [  < ^ > \[ ~ \] \x23 ]  )
      (?<key>              [^ < ^ > \[ ~ \] \x23 ]* )
    ) \x23
    (?<attribute>        [^ < ^ > \[ ~ \] \x23 ]+ ) :
    (?<value>            [^ < ^ > \[ ~ \] \x23 ]+ )
  $ ///u





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
    ### Set the `$stamped` attribute on datom to sigil it as processed. Stamped datoms will not be selected
    by the `select` method unless tag '#stamped' is used. ###
    return @lets d, ( d ) -> assign d, P..., { $stamped: true, }

  #---------------------------------------------------------------------------------------------------------
  unstamp: ( d ) =>
    return d unless d.$stamped
    return @lets d, ( d ) -> delete d.$stamped

  #---------------------------------------------------------------------------------------------------------
  is_system: ( d ) =>
    ### Return whether datom is a system datom (i.e. whether its `sigil` equals `'~'`). ###
    return d.$key.match /^[~\[\]]/

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
  fresh_datom: ( P... ) => @new_datom P..., { $fresh: true, }

  #---------------------------------------------------------------------------------------------------------
  wrap_datom: ( $key, $value ) =>
    @types.validate.datom_key    $key
    @types.validate.datom_datom  $value
    return @freeze { $key, $value, }

  #---------------------------------------------------------------------------------------------------------
  new_single_datom: ( name, P... ) => @types.validate.datom_name name; @_new_datom "^#{name}",  P...
  new_open_datom:   ( name, P... ) => @types.validate.datom_name name; @new_datom  "<#{name}",  P...
  new_close_datom:  ( name, P... ) => @types.validate.datom_name name; @new_datom  ">#{name}",  P...
  new_system_datom: ( name, P... ) => @types.validate.datom_name name; @new_datom  "~#{name}",  P...
  new_text_datom:   (       P... ) => @new_single_datom  'text', P...
  new_end_datom:                   -> @new_system_datom  'end'
  # @new_flush_datom    =                           -> @new_system_datom  'flush'

  #---------------------------------------------------------------------------------------------------------
  new_warning: ( ref, message, d, other...  ) =>
    @new_system_datom 'warning', d, { ref, message, }, other...


  #=========================================================================================================
  #
  #---------------------------------------------------------------------------------------------------------
  ### TAINT likely to be removed ###
  new_xemitter: ( P... ) => new ( require './xemitter' ).Xemitter P...


  #=========================================================================================================
  #
  #---------------------------------------------------------------------------------------------------------
  select: ( d, selector ) =>
    throw new Error "µ86606 expected a selector, got none" unless selector?
    return false unless ( ( @types.isa.object d ) and ( d.$key? ) )
    #.......................................................................................................
    unless ( match = ( selector.match p2 ) ? ( selector.match p1 ) )?
      throw new Error "µ37799 illegal selector #{rpr selector}"
    g       = {}
    g[ k ]  = v for k, v of match.groups when v isnt ''
    if g.attribute? and ( g.attribute isnt 'stamped' )
      throw new Error "µ77764 unknown attribute name #{rpr g.attribute}"
    switch g.value
      when undefined      then stamped_values = [       false, ]
      when '*'            then stamped_values = [ true, false, ]
      when 'true'         then stamped_values = [ true,        ]
      when 'false'        then stamped_values = [       false, ]
      else throw new Error "µ33366 illegal attribute or value in selector #{rpr selector}"
    #.......................................................................................................
    return false if ( d.$stamped ? false ) not in stamped_values
    return ( d.$key is g.skey ) if g.key?
    return false unless d.$key.startsWith g.sigil
    return true


#===========================================================================================================
module.exports = { Datom, DATOM: new Datom(), }




