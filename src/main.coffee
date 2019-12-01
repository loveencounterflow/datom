
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/MAIN'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
{ assign
  copy
  jr }                    = CND
#...........................................................................................................
Multimix                  = require 'multimix'
@types                    = require './types'
{ isa
  validate
  defaults
  type_of }               = @types
LFT                       = require 'letsfreezethat'
LFT_nofreeze              = LFT.nofreeze
@_copy                    = LFT_nofreeze._copy.bind LFT

#-----------------------------------------------------------------------------------------------------------
@freeze = ( d ) -> if @settings.freeze then LFT.freeze d else LFT_nofreeze.freeze d
@thaw   = ( d ) -> if @settings.freeze then LFT.thaw   d else LFT_nofreeze.thaw   d

#-----------------------------------------------------------------------------------------------------------
@lets = ( original, modifier ) ->
  unless @settings.freeze
    draft = @_copy original
    if modifier?
      modifier draft
      ### TAINT simplify logic by rewriting as single term without double negatives ###
      if @settings.dirty
        draft.$dirty = true unless draft.$dirty isnt original.dirty
    return draft
  #.........................................................................................................
  draft = @thaw original
  if modifier?
    modifier draft
    ### TAINT simplify logic by rewriting as single term without double negatives ###
    if @settings.dirty
      draft.$dirty = true unless draft.$dirty isnt original.dirty
  return @freeze draft

#-----------------------------------------------------------------------------------------------------------
@set = ( d, k, P... ) ->
  if isa.text k
    throw new Error "µ67663 expected 1 value got #{count}" unless ( count = P.length ) is 1
    return @lets d, ( d ) -> d[ k ] = P[ 0 ]
  return @lets d, ( d ) -> d[ k ]  = v for k, v of assign {}, k, P...

#-----------------------------------------------------------------------------------------------------------
@unset = ( d, k ) -> @lets d, ( d ) -> delete d[ k ]

#-----------------------------------------------------------------------------------------------------------
@stamp = ( d, P... ) ->
  ### Set the `$stamped` attribute on datom to sigil it as processed. Stamped datoms will not be selected
  by the `select` method unless tag '#stamped' is used. ###
  return @lets d, ( d ) -> assign d, P..., { $stamped: true, }

#-----------------------------------------------------------------------------------------------------------
@unstamp = ( d ) ->
  return d unless d.$stamped
  return @lets d, ( d ) -> delete d.$stamped

#-----------------------------------------------------------------------------------------------------------
@is_system = ( d ) ->
  ### Return whether datom is a system datom (i.e. whether its `sigil` equals `'~'`). ###
  return d.$key.match /^[~\[\]]/

#-----------------------------------------------------------------------------------------------------------
@is_stamped = ( d ) -> d.$stamped ? false ### i.e. already processed? ###
@is_fresh   = ( d ) -> d.$fresh   ? false ### i.e. created within stream? ###
@is_dirty   = ( d ) -> d.$dirty   ? false ### i.e. modified? ###
@is_datom   = ( x ) -> isa.datom_datom x

#-----------------------------------------------------------------------------------------------------------
@new_datom = ( $key, $value, other... ) ->
  ### When `other` contains a key `$`, it is treated as a hint to copy
  system-level attributes; if the value of key `$` is a POD that has itself a
  key `$`, then a copy of that value is used. This allows to write `new_datom
  ..., $: d` to copy system-level attributes such as source locations to a new
  datom. ###
  validate.datom_key    $key
  if $value?
    $value  = { $value, } if ( not @settings.merge_values ) or ( not isa.object $value )
    throw new Error "µ55632 value must not have attribute '$key'" if '$key' in Object.keys $value
    R       = assign {}, $value,  other..., { $key, }
  else
    R       = assign {},          other..., { $key, }
  while ( isa.object R.$ ) and ( isa.object R.$.$ ) then R.$ = copy R.$.$
  return @freeze R

#-----------------------------------------------------------------------------------------------------------
@wrap_datom = ( $key, $value ) ->
  ### TAINT code duplication ###
  validate.datom_key    $key
  validate.datom_datom  $value
  R = assign {}, { $key, $value, }
  while ( isa.object R.$ ) and ( isa.object R.$.$ ) then R.$ = copy R.$.$
  return @freeze R

#-----------------------------------------------------------------------------------------------------------
@new_single_datom = ( $key, $value, other... ) -> @new_datom         "^#{$key}",  $value, other...
@new_open_datom   = ( $key, $value, other... ) -> @new_datom         "<#{$key}",  $value, other...
@new_close_datom  = ( $key, $value, other... ) -> @new_datom         ">#{$key}",  $value, other...
@new_system_datom = ( $key, $value, other... ) -> @new_datom         "~#{$key}",  $value, other...
@new_text_datom   = (       $value, other... ) -> @new_single_datom  'text',      $value, other...
@new_end_datom    =                            -> @new_system_datom  'end'
# @new_flush_datom    =                           -> @new_system_datom  'flush'

#-----------------------------------------------------------------------------------------------------------
@new_warning = ( ref, message, d, other...  ) ->
  @new_system_datom 'warning', d, { ref, message, }, other...


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

#-----------------------------------------------------------------------------------------------------------
@select = ( d, selector ) ->
  throw new Error "µ86606 expected a selector, got none" unless selector?
  return false unless ( ( isa.object d ) and ( d.$key? ) )
  #.........................................................................................................
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
  #.........................................................................................................
  return false if ( d.$stamped ? false ) not in stamped_values
  return ( d.$key is g.skey ) if g.key?
  return false unless d.$key.startsWith g.sigil
  return true


#===========================================================================================================
# EXPORT
#-----------------------------------------------------------------------------------------------------------
MAIN = @
class Datom extends Multimix
  @include MAIN,                              { overwrite: false, }
  @include ( require './xemitter.mixin' ),    { overwrite: false, }
  # @include ( require './cachewalker.mixin' ), { overwrite: false, }
  # @include ( require './_temp_svgttf' ),      { overwrite: false, } ### !!!!!!!!!!!!!!!!!!!!!!!!!!! ###
  # @extend MAIN, { overwrite: false, }

  #---------------------------------------------------------------------------------------------------------
  constructor: ( settings = null ) ->
    super()
    validate.datom_settings settings = { defaults.settings..., settings..., }
    @settings = LFT.freeze settings
    @Datom    = Datom
    return @

module.exports = new Datom()




