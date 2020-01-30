(function() {
  'use strict';
  var CND, alert, badge, cast, check, debug, declare, declare_cast, echo, help, info, is_happy, is_sad, isa, jr, log, rpr, sad, type_of, urge, validate, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/HTML';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  ({jr} = CND);

  //...........................................................................................................
  this.types = require('./types');

  ({isa, validate, cast, declare, declare_cast, check, sad, is_sad, is_happy, type_of} = this.types);

  //...........................................................................................................
  this.isa = isa;

  this.validate = validate;

  this.check = check;

  this.cast = cast;

  //-----------------------------------------------------------------------------------------------------------
  this._as_attribute_literal = function(x) {
    var R, must_quote;
    R = isa.text(x) ? x : JSON.stringify(x);
    must_quote = !this.isa._datom_html_naked_attribute_text(R);
    R = R.replace(/&/g, '&amp;');
    R = R.replace(/</g, '&lt;');
    R = R.replace(/>/g, '&gt;');
    R = R.replace(/'/g, '&#39;');
    R = R.replace(/\n/g, '&#10;');
    if (must_quote) {
      R = "'" + R + "'";
    }
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.cast.html = (d) => {
    var attributes, i, key, len, ref, sigil, slash, value;
    validate.datom_datom(d);
    attributes = '';
    if ((sigil = d.$key[0]) === '>') {
      return `</${d.$key.slice(1)}>`;
    }
    ref = (Object.keys(d)).sort();
    /* NOTE sorting attributes by keys to make result predictable: */
    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];
      if (key === '$key' || key === '$value') {
        continue;
      }
      if ((value = d[key]) === true) {
        attributes += ` ${key}`;
      } else {
        attributes += ` ${key}=${this._as_attribute_literal(value)}`;
      }
    }
    slash = sigil === '<' ? '' : '/';
    if (attributes === '') {
      return `<${d.$key.slice(1)}${slash}>`;
    }
    return `<${d.$key.slice(1)}${attributes}${slash}>`;
  };

  //###########################################################################################################
  if (module === require.main) {
    (() => { // await do =>
      return help('ok');
    })();
  }

}).call(this);
