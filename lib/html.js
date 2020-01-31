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
  this._escape_text = function(x) {
    var R;
    R = x;
    R = R.replace(/&/g, '&amp;');
    R = R.replace(/</g, '&lt;');
    R = R.replace(/>/g, '&gt;');
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._as_attribute_literal = function(x) {
    var R, must_quote;
    R = isa.text(x) ? x : JSON.stringify(x);
    must_quote = !this.isa._datom_html_naked_attribute_text(R);
    R = this._escape_text(R);
    R = R.replace(/'/g, '&#39;');
    R = R.replace(/\n/g, '&#10;');
    if (must_quote) {
      R = "'" + R + "'";
    }
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.cast.html = (d) => {
    var atxt, i, key, len, ref, ref1, sigil, slash, src, tagname, value;
    validate.datom_datom(d);
    atxt = '';
    sigil = d.$key[0];
    tagname = d.$key.slice(1);
    //.........................................................................................................
    /* TAINT simplistic solution; namespace might already be taken? */
    switch (sigil) {
      case '[':
        [sigil, tagname] = ['<', `sys:${tagname}`];
        break;
      case '~':
        [sigil, tagname] = ['^', `sys:${tagname}`];
        break;
      case ']':
        [sigil, tagname] = ['>', `sys:${tagname}`];
    }
    if ((sigil === '^') && (tagname === 'text')) {
      //.........................................................................................................
      return this._escape_text((ref = d.text) != null ? ref : '');
    }
    if (sigil === '>') {
      return `</${tagname}>`;
    }
    //.........................................................................................................
    /* NOTE sorting atxt by keys to make result predictable: */
    if (this.isa.object(d.$value)) {
      src = d.$value;
    } else {
      src = d;
    }
    ref1 = (Object.keys(src)).sort();
    for (i = 0, len = ref1.length; i < len; i++) {
      key = ref1[i];
      if (key.startsWith('$')) {
        continue;
      }
      if ((value = src[key]) === true) {
        atxt += ` ${key}`;
      } else {
        atxt += ` ${key}=${this._as_attribute_literal(value)}`;
      }
    }
    //.........................................................................................................
    slash = sigil === '<' ? '' : '/';
    if (atxt === '') {
      return `<${tagname}${slash}>`;
    }
    return `<${tagname}${atxt}${slash}>`;
  };

  //###########################################################################################################
  if (module === require.main) {
    (() => { // await do =>
      return help('ok');
    })();
  }

}).call(this);
