


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
  whisper }               = GUY.trm.get_loggers 'DATOM/XEMITTER'
{ rpr
  inspect
  echo
  log     }               = GUY.trm
#...........................................................................................................
Emittery                  = require '../deps/emittery.js'
{ DATOM }                 = require './main'
{ misfit
  get_base_types
  get_xemitter_types }    = require './types'


#===========================================================================================================
class Xemitter

  #---------------------------------------------------------------------------------------------------------
  constructor: ->
    @types            = get_xemitter_types()
    @_emitter         = new Emittery()
    @_has_contractors = {}
    @_has_listener    = {}
    return undefined

  #---------------------------------------------------------------------------------------------------------
  _mark_as_primary: ( x ) => DATOM.wrap_datom '~XEMITTER-preferred', { $key: '~wrapper', $value: x, }
  _filter_primary:  ( x ) => DATOM.select x,  '~XEMITTER-preferred'

  #---------------------------------------------------------------------------------------------------------
  _get_primary: ( values ) =>
    primary_responses = values.filter @_filter_primary
    return misfit unless primary_responses.length > 0
    return primary_responses[ 0 ]?.$value.$value

  #---------------------------------------------------------------------------------------------------------
  _datom_from_emit_arguments: ( P... ) =>
    unless ( arity = P.length ) > 0
      throw new Error "µ44422 expected one or more arguments, got none"
    return DATOM.new_datom P[ 0 ], P[ 1 .. ]... if @types.isa.text P[ 0 ]
    unless ( arity = P.length ) is 1
      throw new Error "µ44422 expected single argument unless first is key, got #{arity}"
    unless DATOM.is_datom d = P[ 0 ]
      throw new Error "µ44422 expected a text or a datom got a #{@types.type_of d}"
    return d


  #=========================================================================================================
  # API / RECEIVING
  #---------------------------------------------------------------------------------------------------------
  contract: ( key, listener ) =>
    @types.validate.datom_key  key
    @types.validate.callable   listener
    throw new Error "µ68704 key #{rpr key} already has a primary listener" if @_has_contractors[ key ]
    @_has_contractors[ key ]  = true
    @_has_listener[ key ]     = true
    return @_emitter.on key, ( d ) => @_mark_as_primary await listener d

  #---------------------------------------------------------------------------------------------------------
  listen_to: ( key, listener ) =>
    @types.validate.datom_key  key
    @types.validate.callable   listener
    @_has_listener[ key ] = true
    return @_emitter.on key, ( d ) => await listener d

  #---------------------------------------------------------------------------------------------------------
  listen_to_all: ( listener ) =>
    @types.validate.callable   listener
    return @_emitter.onAny ( key, d ) => await listener key, d

  #---------------------------------------------------------------------------------------------------------
  listen_to_unheard: ( listener ) =>
    @types.validate.callable   listener
    return @_emitter.onAny ( key, d ) => await listener key, d unless @_has_listener[ key ]


  #=========================================================================================================
  # API / SENDING
  #---------------------------------------------------------------------------------------------------------
  emit: ( key, d ) =>
    d = @_datom_from_emit_arguments arguments...
    return await @_emitter.emit d.$key, d

  #---------------------------------------------------------------------------------------------------------
  delegate: ( key, d ) =>
    if ( R = @_get_primary await @emit arguments... ) is misfit
      throw new Error "µ83733 no results for #{rpr key.$key ? key}"
    return R



module.exports = { Xemitter, XEMITTER: new Xemitter(), }
