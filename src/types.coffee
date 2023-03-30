

'use strict'


############################################################################################################
GUY                       = require 'guy'
# { alert
#   debug
#   help
#   info
#   plain
#   praise
#   urge
#   warn
#   whisper }               = GUY.trm.get_loggers 'DATOM/TYPES'
{ debug }                 = GUY.trm.get_loggers 'DATOM/TYPES'
{ rpr
  inspect
  echo
  log     }               = GUY.trm
{ Intertype }             = require 'intertype'
base_types                = null
misfit                    = Symbol 'misfit'


#-----------------------------------------------------------------------------------------------------------
get_base_types = ->
  return base_types if base_types?
  #.........................................................................................................
  base_types                = new Intertype()
  { declare }               = base_types
  #.........................................................................................................
  declare.datom_constructor_cfg
    fields:
      merge_values:         'boolean'
      freeze:               'boolean'
      dirty:                'boolean' ### TAINT ??? to be removed ??? ###
    default:
      merge_values:         true
      freeze:               true
      dirty:                false ### TAINT ??? to be removed ??? ###
  #.........................................................................................................
  declare.datom_key ( x ) ->
    return ( @isa.text x ) and ( x.length > 0 )
  #.........................................................................................................
  declare.datom_name 'nonempty.text'
  #.........................................................................................................
  declare.datom_vnr ( x ) ->
    return true unless x?
    return false unless @isa.list x
    return false unless x.length > 0
    return x.every ( n ) => @isa.positive0.integer n
  #.........................................................................................................
  declare.datom_datom
    fields:
      $key:               'datom_key'
      $stamped:           'optional.boolean'
      $dirty:             'optional.boolean'
      $fresh:             'optional.boolean'
      $vnr:               'optional.datom_vnr'
    default:
      $key:               null
      $stamped:           null
      $dirty:             null
      $fresh:             null
  #.........................................................................................................
  return base_types

#===========================================================================================================
module.exports = { misfit, get_base_types, }

