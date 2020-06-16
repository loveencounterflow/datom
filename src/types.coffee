


'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/TYPES'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
jr                        = JSON.stringify
Intertype                 = ( require 'intertype' ).Intertype
intertype                 = new Intertype module.exports

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_settings',
  tests:
    "x is a object":                  ( x ) -> @isa.object x
    "x.merge_values is a ?boolean":   ( x ) -> ( not x.merge_values? ) or @isa.boolean x.merge_values
    "x.freeze is a ?boolean":         ( x ) -> ( not x.freeze?       ) or @isa.boolean x.freeze

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_vnr_settings',
  tests:
    "x is a object":                              ( x ) -> @isa.object x
    "x.ordering is 'fair', 'total' or 'partial":  ( x ) -> x.ordering in [ 'fair', 'total', 'partial', ]
    "x.validate is a ?boolean":                   ( x ) -> ( not x.validate? ) or @isa.boolean x.validate

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_nonempty_list_of_positive_integers', ( x ) ->
  return false unless @isa.nonempty_list x
  return x.every ( xx ) => @isa.positive_integer xx

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_sigil',
  tests:
    "x is a chr":                             ( x ) -> @isa.chr x
    "x has sigil":                            ( x ) -> x in '^<>~[]'

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_key',
  tests:
    "x is a text":                            ( x ) -> @isa.text   x
    "x has at least 2 chrs":                  ( x ) -> x.length > 1
    "x has sigil":                            ( x ) -> @isa.datom_sigil x[ 0 ]

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_name',
  tests:
    "x is a nonempty text":                   ( x ) -> @isa.nonempty_text   x

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_datom',
  tests:
    "x is a object":                          ( x ) -> @isa.object          x
    "x.$key is a datom_key":                  ( x ) -> @isa.datom_key       x.$key
    "x.$stamped is an optional boolean":      ( x ) -> ( not x.$stamped? ) or ( @isa.boolean x.$stamped )
    "x.$dirty is an optional boolean":        ( x ) -> ( not x.$dirty?   ) or ( @isa.boolean x.$dirty   )
    "x.$fresh is an optional boolean":        ( x ) -> ( not x.$fresh?   ) or ( @isa.boolean x.$fresh   )
    #.......................................................................................................
    "x.$vnr is an optional nonempty list of positive integers": ( x ) ->
      ( not x.$vnr? ) or @isa.datom_nonempty_list_of_positive_integers x.$vnr


#===========================================================================================================
# DEFAULTS, CASTS
#-----------------------------------------------------------------------------------------------------------
@defaults =
  settings:
    merge_values: true
    freeze:       true
    dirty:        false
  vnr_settings:
    validate:     true
    ordering:     'fair'


#-----------------------------------------------------------------------------------------------------------
@cast = {}

