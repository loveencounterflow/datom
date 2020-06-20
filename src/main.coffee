
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
{ Cupofjoe }              = require 'cupofjoe'


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
  validate.datom_key $key
  return @_new_datom $key, $value, other...

#-----------------------------------------------------------------------------------------------------------
@_new_datom = ( $key, $value, other... ) ->
  if $value?
    $value  = { $value, } if ( not @settings.merge_values ) or ( not isa.object $value )
    throw new Error "µ55632 value must not have attribute '$key'" if '$key' in Object.keys $value
    R       = assign {}, $value,  other..., { $key, }
  else
    R       = assign {},          other..., { $key, }
  while ( isa.object R.$ ) and ( isa.object R.$.$ ) then R.$ = copy R.$.$
  return @freeze R

#-----------------------------------------------------------------------------------------------------------
@fresh_datom = ( P... ) -> @new_datom P..., { $fresh: true, }

#-----------------------------------------------------------------------------------------------------------
@wrap_datom = ( $key, $value ) ->
  ### TAINT code duplication ###
  validate.datom_key    $key
  validate.datom_datom  $value
  R = assign {}, { $key, $value, }
  while ( isa.object R.$ ) and ( isa.object R.$.$ ) then R.$ = copy R.$.$
  return @freeze R

#-----------------------------------------------------------------------------------------------------------
@new_single_datom = ( name, P... ) -> validate.datom_name name; @_new_datom "^#{name}",  P...
@new_open_datom   = ( name, P... ) -> validate.datom_name name; @new_datom  "<#{name}",  P...
@new_close_datom  = ( name, P... ) -> validate.datom_name name; @new_datom  ">#{name}",  P...
@new_system_datom = ( name, P... ) -> validate.datom_name name; @new_datom  "~#{name}",  P...
@new_text_datom   = (       P... ) -> @new_single_datom  'text', P...
@new_end_datom    =                -> @new_system_datom  'end'
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
#
#-----------------------------------------------------------------------------------------------------------
class @Cupofdatom extends Cupofjoe
  _defaults: { flatten: true, DATOM: null, }

  #---------------------------------------------------------------------------------------------------------
  constructor: ( settings ) ->
    super settings
    @settings         = Object.assign @_defaults, @settings
    @DATOM            = @settings.DATOM ?= module.exports
    delete @settings.DATOM

  #---------------------------------------------------------------------------------------------------------
  _analyze: ( name, tail ) ->
    ### NOTE to be overriden by derivatives as seen necessary ###
    attributes  = []
    content     = []
    for part, idx in tail
      switch type = type_of part
        when 'object'   then  attributes.push part
        when 'function' then  content.push part ### NOTE always leave as-is, expanded by Cupofjoe ###
        when 'text'     then  content.push @DATOM.new_single_datom 'text',  { text: part,   $: '^ð1^', }
        else                  content.push @DATOM.new_single_datom 'value', { $value: part, $: '^ð2^', }
    return { name, attributes, content, }

  #---------------------------------------------------------------------------------------------------------
  _cram: ( P... ) -> super.cram P...

  #---------------------------------------------------------------------------------------------------------
  cram: ( name, tail... ) ->
    # XXX_SUPER = @Cupofjoe.
    { name, attributes, content, } = @_analyze name, tail
    has_attributes = false
    #.......................................................................................................
    if attributes? and attributes.length > 0
      has_attributes  = true
      attributes      = Object.assign {}, attributes...
    #.......................................................................................................
    if has_attributes and name is null
      v = rpr { name, attributes, content, }
      throw new Error "^datom/cupofjoe@3498^ cannot have attributes without name, got #{v}"
    #.......................................................................................................
    if content? and content.length > 0
      return super content... if name is null
      if has_attributes
        d1 = @DATOM.new_open_datom   name, attributes, { $: '^ð3^', }
        d2 = @DATOM.new_close_datom  name, attributes, { $: '^ð4^', }
      else
        d1 = @DATOM.new_open_datom   name, { $: '^ð5^', }
        d2 = @DATOM.new_close_datom  name, { $: '^ð6^', }
      return super d1, content..., d2
    #.......................................................................................................
    if has_attributes
      return super @DATOM.new_single_datom name, attributes, { $: '^ð7^', }
    return super @DATOM.new_single_datom name, { $: '^ð8^', } if name isnt null
    return null


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
    @VNR      = require './vnr'
    @Datom    = Datom
    return @

module.exports = new Datom()




