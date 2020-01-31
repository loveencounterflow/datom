


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
    "x is a nonempty text":                   ( x ) -> @isa.nonempty_text   x
    "x has sigil":                            ( x ) -> @isa.datom_sigil     x[ 0 ]

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
    dirty:        true

#-----------------------------------------------------------------------------------------------------------
@cast = {}


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
### thx to https://www.w3.org/TR/xml ###
tagname_head_pattern = ///
  a-z
  A-Z
  :_
  \xc0-\xd6
  \xd8-\xf6
  \u00f8-\u02ff
  \u0370-\u037d
  \u037f-\u1fff
  \u200c-\u200d
  \u2070-\u218f
  \u2c00-\u2fef
  \u3001-\ud7ff
  \uf900-\ufdcf
  \ufdf0-\ufffd
  \u{10000}-\u{effff} ///u
tagname_tail_pattern = ///
  \.-
  0-9
  \xb7
  \u0300-\u036f
  \u203f-\u2040 ///u
tagname_pattern = /// ^
  [#{tagname_head_pattern.source}]
  [#{tagname_head_pattern.source}#{tagname_tail_pattern.source}]* $ ///u ### must NOT set global flag ###

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_html_tagname',
  tests:
    "x is a text":                    ( x ) -> @isa.text x
    "x matches tagname_pattern":      ( x ) -> tagname_pattern.test x

#-----------------------------------------------------------------------------------------------------------
@declare 'datom_html_naked_attribute_value',
  ### thx to https://raw.githubusercontent.com/mathiasbynens/mothereff.in/master/unquoted-attributes/eff.js
  also see https://mothereff.in/unquoted-attributes,
  https://mathiasbynens.be/notes/unquoted-attribute-values ###
  tests:
    "x is a text":                            ( x ) -> @isa.text x
    "x isa datom_html_naked_attribute_text":  ( x ) -> @isa._datom_html_naked_attribute_text x

#-----------------------------------------------------------------------------------------------------------
@declare '_datom_html_naked_attribute_text', ( x ) -> /^[^ \t\n\f\r"'`=<>]+$/.test x

# #-----------------------------------------------------------------------------------------------------------
# @_CSS_must_quote = ( x ) ->
#   ### NOTE for completeness, from the same source https://mathiasbynens.be/notes/unquoted-attribute-values ###
#   return true if ( x is '' ) or ( x is '-' )
#   ### Escapes are valid, so replace them with a valid non-empty string ###
#   x = ( x.replace /\\([0-9A-Fa-f]{1,6})[ \t\n\f\r]?/g, 'a' ).replace /\\./g, 'a'
#   return not not ( ( /[\0-\x2C\x2E\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x9F]/.test x ) or ( /^-?\d/.test x ) )

