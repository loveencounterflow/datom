
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'DATOM/HTML'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
{ jr, }                   = CND
#...........................................................................................................
@types                    = require './types'
{ isa
  validate
  cast
  declare
  declare_cast
  check
  sad
  is_sad
  is_happy
  type_of }               = @types
#...........................................................................................................
@isa                      = isa
@validate                 = validate
@check                    = check
@cast                     = cast


#-----------------------------------------------------------------------------------------------------------
@_escape_text = ( x ) ->
  R           = x
  R           = R.replace /&/g,   '&amp;'
  R           = R.replace /</g,   '&lt;'
  R           = R.replace />/g,   '&gt;'
  return R

#-----------------------------------------------------------------------------------------------------------
@_as_attribute_literal = ( x ) ->
  R           = if isa.text x then x else JSON.stringify x
  must_quote  = not @isa._datom_html_naked_attribute_text R
  R           = @_escape_text R
  R           = R.replace /'/g,   '&#39;'
  R           = R.replace /\n/g,  '&#10;'
  R           = "'" + R + "'" if must_quote
  return R

#-----------------------------------------------------------------------------------------------------------
@cast.html = ( d ) =>
  validate.datom_datom d
  atxt        = ''
  sigil       = d.$key[ 0 ]
  tagname     = d.$key[ 1 .. ]
  #.........................................................................................................
  switch sigil
    when '[' then [ sigil, tagname, ] = [ '<', "sys:#{tagname}", ]
    when '~' then [ sigil, tagname, ] = [ '^', "sys:#{tagname}", ]
    when ']' then [ sigil, tagname, ] = [ '>', "sys:#{tagname}", ]
  #.........................................................................................................
  return ( @_escape_text d.text ? '' )    if ( sigil is '^' ) and ( tagname is 'text' )
  return "</#{tagname}>"                  if sigil is '>'
  #.........................................................................................................
  ### NOTE sorting atxt by keys to make result predictable: ###
  if @isa.object d.$value then  src = d.$value
  else                          src = d
  for key in ( Object.keys src ).sort()
    continue if key.startsWith '$'
    if ( value = src[ key ] ) is true then  atxt += " #{key}"
    else                                    atxt += " #{key}=#{@_as_attribute_literal value}"
  #.........................................................................................................
  slash = if sigil is '<' then '' else '/'
  return "<#{tagname}#{slash}>" if atxt is ''
  return "<#{tagname}#{atxt}#{slash}>"




############################################################################################################
if module is require.main then do => # await do =>
  help 'ok'

