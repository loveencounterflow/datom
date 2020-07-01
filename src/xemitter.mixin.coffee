
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/XEMITTER'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
#...........................................................................................................
misfit                    = Symbol 'misfit'
types                     = require './types'
{ isa
  validate
  cast
  type_of }               = types

#-----------------------------------------------------------------------------------------------------------
### rewrite using MultiMix` ###
provide_library = ->

  #=========================================================================================================
  ### https://github.com/sindresorhus/emittery ###
  Emittery                  = require 'emittery'
  DATOM                     = require '..'

  #=========================================================================================================
  # IMPLEMENTATION DETAILS
  #---------------------------------------------------------------------------------------------------------
  @_emitter         = new Emittery()
  @_has_contractors = {}
  @_has_listener    = {}

  #---------------------------------------------------------------------------------------------------------
  @_mark_as_primary = ( x ) -> DATOM.wrap_datom '~XEMITTER-preferred', { $key: '~wrapper', $value: x, }
  @_filter_primary  = ( x ) -> DATOM.select x,  '~XEMITTER-preferred'

  #---------------------------------------------------------------------------------------------------------
  @_get_primary = ( values ) ->
    primary_responses = values.filter @_filter_primary
    return misfit unless primary_responses.length > 0
    return primary_responses[ 0 ]?.$value.$value

  #---------------------------------------------------------------------------------------------------------
  @_datom_from_emit_arguments = ( P... ) ->
    unless ( arity = P.length ) > 0
      throw new Error "µ44422 expected one or more arguments, got none"
    return DATOM.new_datom P[ 0 ], P[ 1 .. ]... if isa.text P[ 0 ]
    unless ( arity = P.length ) is 1
      throw new Error "µ44422 expected single argument unless first is key, got #{arity}"
    unless DATOM.is_datom d = P[ 0 ]
      throw new Error "µ44422 expected a text or a datom got a #{type_of d}"
    return d


  #=========================================================================================================
  # API / RECEIVING
  #---------------------------------------------------------------------------------------------------------
  @contract = ( key, listener ) ->
    validate.datom_key  key
    validate.callable   listener
    throw new Error "µ68704 key #{rpr key} already has a primary listener" if @_has_contractors[ key ]
    @_has_contractors[ key ]  = true
    @_has_listener[ key ]     = true
    return @_emitter.on key, ( d ) => @_mark_as_primary await listener d

  #---------------------------------------------------------------------------------------------------------
  @listen_to = ( key, listener ) ->
    validate.datom_key  key
    validate.callable   listener
    @_has_listener[ key ] = true
    return @_emitter.on key, ( d ) => await listener d

  #---------------------------------------------------------------------------------------------------------
  @listen_to_all = ( listener ) ->
    validate.callable   listener
    return @_emitter.onAny ( key, d ) => await listener key, d

  #---------------------------------------------------------------------------------------------------------
  @listen_to_unheard = ( listener ) ->
    validate.callable   listener
    return @_emitter.onAny ( key, d ) => await listener key, d unless @_has_listener[ key ]


  #=========================================================================================================
  # API / SENDING
  #---------------------------------------------------------------------------------------------------------
  @emit = ( key, d ) ->
    d = @_datom_from_emit_arguments arguments...
    return await @_emitter.emit d.$key, d

  #---------------------------------------------------------------------------------------------------------
  @delegate = ( key, d ) ->
    if ( R = @_get_primary await @emit arguments... ) is misfit
      throw new Error "µ83733 no results for #{rpr key.$key ? key}"
    return R


  #=========================================================================================================
  #
  #---------------------------------------------------------------------------------------------------------
  for name, value of L = @
    continue unless isa.function value.bind
    L[ name ] = value.bind L


############################################################################################################
@new_xemitter = ->
  provide_library.apply R = {}
  return R

