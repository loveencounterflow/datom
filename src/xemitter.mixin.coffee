
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

  #---------------------------------------------------------------------------------------------------------
  @_mark_as_primary = ( x ) -> DATOM.wrap_datom '~XEMITTER-preferred', { $key: '~wrapper', $value: x, }
  @_filter_primary  = ( x ) -> DATOM.select x,  '~XEMITTER-preferred'

  #---------------------------------------------------------------------------------------------------------
  @_get_primary = ( values ) ->
    primary_responses = values.filter @_filter_primary
    return misfit unless primary_responses.length > 0
    return primary_responses[ 0 ]?.$value.$value

  #---------------------------------------------------------------------------------------------------------
  @_get_ksl = ( key, self, listener ) ->
    switch arity = arguments.length
      when 2 then [ key, self, listener, ] = [ key, null, self,       ]
      when 3 then [ key, self, listener, ] = [ key, self,  listener,  ]
      else throw new Error "µ67348 expected 2 or 3 arguments, got #{arity}"
    validate.nonempty_text key
    return [ key, self, listener, ]

  #---------------------------------------------------------------------------------------------------------
  @_get_sl = ( self, listener ) ->
    switch arity = arguments.length
      when 1 then [ self, listener, ] = [ null, self,       ]
      when 2 then [ self, listener, ] = [ self,  listener,  ]
      else throw new Error "µ68252 expected 1 or 2 arguments, got #{arity}"
    return [ self, listener, ]

  #---------------------------------------------------------------------------------------------------------
  @_get_kd = ( key, d ) ->
    org_key = key
    org_d   = d
    switch arity = arguments.length
      when 1
        if isa.text key
          [ key, d, ] = [ key, key, ]
        else
          unless DATOM.is_datom key
            throw new Error "µ44422 expected a text or a datom got a #{type_of key}"
          [ key, d, ] = [ key.$key, key, ]
      when 2 then null
      else throw new Error "µ69156 expected 1 or 2 arguments, got #{arity}"
    throw new Error "µ69608 expected a key, got #{rpr key} from #{rpr org_key}, #{rpr org_d}" unless key?
    return [ key, d, ]


  #=========================================================================================================
  # API / RECEIVING
  #---------------------------------------------------------------------------------------------------------
  @contract = ( key, self, listener ) ->
    [ key, self, listener, ]  = @_get_ksl arguments...
    throw new Error "µ68704 key #{rpr key} already has a primary listener" if @_has_contractors[ key ]
    @_has_contractors[ key ]  = yes
    return @_emitter.on key, ( d ) => @_mark_as_primary await listener.call self, d

  #---------------------------------------------------------------------------------------------------------
  @listen_to = ( key, self, listener ) ->
    [ key, self, listener, ]  = @_get_ksl arguments...
    return @_emitter.on key, ( d ) -> await listener.call self, d

  #---------------------------------------------------------------------------------------------------------
  @listen_to_all = ( self, listener ) ->
    [ self, listener, ]       = @_get_sl arguments...
    return @_emitter.onAny ( key, d ) -> await listener.call self, key, d

  #=========================================================================================================
  # API / SENDING
  #---------------------------------------------------------------------------------------------------------
  @emit = ( key, d ) -> await @_emitter.emit ( @_get_kd arguments... )...

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

