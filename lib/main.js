(function() {
  'use strict';
  var CND, Cupofjoe, Datom, LFT, LFT_nofreeze, MAIN, Multimix, assign, badge, copy, debug, defaults, echo, help, info, isa, jr, p1, p2, rpr, type_of, urge, validate, warn, whisper,
    indexOf = [].indexOf;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/MAIN';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  urge = CND.get_logger('urge', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  ({assign, copy, jr} = CND);

  //...........................................................................................................
  Multimix = require('multimix');

  this.types = require('./types');

  ({isa, validate, defaults, type_of} = this.types);

  LFT = require('letsfreezethat');

  LFT_nofreeze = LFT.nofreeze;

  this._copy = LFT_nofreeze._copy.bind(LFT);

  ({Cupofjoe} = require('cupofjoe'));

  //-----------------------------------------------------------------------------------------------------------
  this.freeze = function(d) {
    if (this.settings.freeze) {
      return LFT.freeze(d);
    } else {
      return LFT_nofreeze.freeze(d);
    }
  };

  this.thaw = function(d) {
    if (this.settings.freeze) {
      return LFT.thaw(d);
    } else {
      return LFT_nofreeze.thaw(d);
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  this.lets = function(original, modifier) {
    var draft;
    if (!this.settings.freeze) {
      draft = this._copy(original);
      if (modifier != null) {
        modifier(draft);
        /* TAINT simplify logic by rewriting as single term without double negatives */
        if (this.settings.dirty) {
          if (draft.$dirty === original.dirty) {
            draft.$dirty = true;
          }
        }
      }
      return draft;
    }
    //.........................................................................................................
    draft = this.thaw(original);
    if (modifier != null) {
      modifier(draft);
      /* TAINT simplify logic by rewriting as single term without double negatives */
      if (this.settings.dirty) {
        if (draft.$dirty === original.dirty) {
          draft.$dirty = true;
        }
      }
    }
    return this.freeze(draft);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.set = function(d, k, ...P) {
    var count;
    if (isa.text(k)) {
      if ((count = P.length) !== 1) {
        throw new Error(`µ67663 expected 1 value got ${count}`);
      }
      return this.lets(d, function(d) {
        return d[k] = P[0];
      });
    }
    return this.lets(d, function(d) {
      var ref1, results, v;
      ref1 = assign({}, k, ...P);
      results = [];
      for (k in ref1) {
        v = ref1[k];
        results.push(d[k] = v);
      }
      return results;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.unset = function(d, k) {
    return this.lets(d, function(d) {
      return delete d[k];
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.stamp = function(d, ...P) {
    /* Set the `$stamped` attribute on datom to sigil it as processed. Stamped datoms will not be selected
     by the `select` method unless tag '#stamped' is used. */
    return this.lets(d, function(d) {
      return assign(d, ...P, {
        $stamped: true
      });
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.unstamp = function(d) {
    if (!d.$stamped) {
      return d;
    }
    return this.lets(d, function(d) {
      return delete d.$stamped;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.is_system = function(d) {
    /* Return whether datom is a system datom (i.e. whether its `sigil` equals `'~'`). */
    return d.$key.match(/^[~\[\]]/);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.is_stamped = function(d) {
    var ref1;
    return (ref1 = d.$stamped) != null ? ref1 : false/* i.e. already processed? */;
  };

  this.is_fresh = function(d) {
    var ref1;
    return (ref1 = d.$fresh) != null ? ref1 : false/* i.e. created within stream? */;
  };

  this.is_dirty = function(d) {
    var ref1;
    return (ref1 = d.$dirty) != null ? ref1 : false/* i.e. modified? */;
  };

  this.is_datom = function(x) {
    return isa.datom_datom(x);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.new_datom = function($key, $value, ...other) {
    var R;
    /* When `other` contains a key `$`, it is treated as a hint to copy
     system-level attributes; if the value of key `$` is a POD that has itself a
     key `$`, then a copy of that value is used. This allows to write `new_datom
     ..., $: d` to copy system-level attributes such as source locations to a new
     datom. */
    validate.datom_key($key);
    if ($value != null) {
      if ((!this.settings.merge_values) || (!isa.object($value))) {
        $value = {$value};
      }
      if (indexOf.call(Object.keys($value), '$key') >= 0) {
        throw new Error("µ55632 value must not have attribute '$key'");
      }
      R = assign({}, $value, ...other, {$key});
    } else {
      R = assign({}, ...other, {$key});
    }
    while ((isa.object(R.$)) && (isa.object(R.$.$))) {
      R.$ = copy(R.$.$);
    }
    return this.freeze(R);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.fresh_datom = function(...P) {
    return this.new_datom(...P, {
      $fresh: true
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  this.wrap_datom = function($key, $value) {
    var R;
    /* TAINT code duplication */
    validate.datom_key($key);
    validate.datom_datom($value);
    R = assign({}, {$key, $value});
    while ((isa.object(R.$)) && (isa.object(R.$.$))) {
      R.$ = copy(R.$.$);
    }
    return this.freeze(R);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.new_single_datom = function($key, $value, ...other) {
    return this.new_datom(`^${$key}`, $value, ...other);
  };

  this.new_open_datom = function($key, $value, ...other) {
    return this.new_datom(`<${$key}`, $value, ...other);
  };

  this.new_close_datom = function($key, $value, ...other) {
    return this.new_datom(`>${$key}`, $value, ...other);
  };

  this.new_system_datom = function($key, $value, ...other) {
    return this.new_datom(`~${$key}`, $value, ...other);
  };

  this.new_text_datom = function($value, ...other) {
    return this.new_single_datom('text', $value, ...other);
  };

  this.new_end_datom = function() {
    return this.new_system_datom('end');
  };

  // @new_flush_datom    =                           -> @new_system_datom  'flush'

  //-----------------------------------------------------------------------------------------------------------
  this.new_warning = function(ref, message, d, ...other) {
    return this.new_system_datom('warning', d, {ref, message}, ...other);
  };

  //===========================================================================================================
  // SELECT
  //-----------------------------------------------------------------------------------------------------------
  p1 = /^(?<skey>(?<sigil>[<^>\[~\]\x23])(?<key>[^<^>\[~\]\x23]*))$/u; // `\x23` used instead of `\#` which causes syntax error (???)

  p2 = /^(?<skey>(?<sigil>[<^>\[~\]\x23])(?<key>[^<^>\[~\]\x23]*))\x23(?<attribute>[^<^>\[~\]\x23]+):(?<value>[^<^>\[~\]\x23]+)$/u; // `\x23` used instead of `\#` which causes syntax error (???)

  //-----------------------------------------------------------------------------------------------------------
  this.select = function(d, selector) {
    var g, k, match, ref1, ref2, ref3, ref4, stamped_values, v;
    if (selector == null) {
      throw new Error("µ86606 expected a selector, got none");
    }
    if (!((isa.object(d)) && (d.$key != null))) {
      return false;
    }
    //.........................................................................................................
    if ((match = (ref1 = selector.match(p2)) != null ? ref1 : selector.match(p1)) == null) {
      throw new Error(`µ37799 illegal selector ${rpr(selector)}`);
    }
    g = {};
    ref2 = match.groups;
    for (k in ref2) {
      v = ref2[k];
      if (v !== '') {
        g[k] = v;
      }
    }
    if ((g.attribute != null) && (g.attribute !== 'stamped')) {
      throw new Error(`µ77764 unknown attribute name ${rpr(g.attribute)}`);
    }
    switch (g.value) {
      case void 0:
        stamped_values = [false];
        break;
      case '*':
        stamped_values = [true, false];
        break;
      case 'true':
        stamped_values = [true];
        break;
      case 'false':
        stamped_values = [false];
        break;
      default:
        throw new Error(`µ33366 illegal attribute or value in selector ${rpr(selector)}`);
    }
    if (ref3 = (ref4 = d.$stamped) != null ? ref4 : false, indexOf.call(stamped_values, ref3) < 0) {
      //.........................................................................................................
      return false;
    }
    if (g.key != null) {
      return d.$key === g.skey;
    }
    if (!d.$key.startsWith(g.sigil)) {
      return false;
    }
    return true;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.Cupofdatom = (function() {
    class Cupofdatom extends Cupofjoe {
      //---------------------------------------------------------------------------------------------------------
      constructor(settings) {
        var base;
        super(settings);
        this.settings = Object.assign(this.settings, this._defaults);
        if ((base = this.settings).DATOM == null) {
          base.DATOM = module.exports;
        }
      }

      //---------------------------------------------------------------------------------------------------------
      cram(name, ...content) {
        var d1, d2;
        if (!(content.length > 0)) {
          return super.cram(this.settings.DATOM.new_datom(`^${name}`));
        }
        if (name === null) {
          return super.cram(...content);
        }
        d1 = this.settings.DATOM.new_datom(`<${name}`);
        d2 = this.settings.DATOM.new_datom(`>${name}`);
        return super.cram(d1, ...content, d2);
      }

      //---------------------------------------------------------------------------------------------------------
      expand() {
        var R, i, idx, len, text;
        R = super.expand();
        for (idx = i = 0, len = R.length; i < len; idx = ++i) {
          text = R[idx];
          if (!isa.text(text)) {
            continue;
          }
          R[idx] = this.settings.DATOM.new_datom('^text', {text});
        }
        return R;
      }

    };

    Cupofdatom.prototype._defaults = {
      flatten: true,
      DATOM: null
    };

    return Cupofdatom;

  }).call(this);

  //===========================================================================================================
  // EXPORT
  //-----------------------------------------------------------------------------------------------------------
  MAIN = this;

  Datom = (function() {
    class Datom extends Multimix {
      // @include ( require './cachewalker.mixin' ), { overwrite: false, }
      // @include ( require './_temp_svgttf' ),      { overwrite: false, } ### !!!!!!!!!!!!!!!!!!!!!!!!!!! ###
      // @extend MAIN, { overwrite: false, }

        //---------------------------------------------------------------------------------------------------------
      constructor(settings = null) {
        super();
        validate.datom_settings(settings = {...defaults.settings, ...settings});
        this.settings = LFT.freeze(settings);
        this.VNR = require('./vnr');
        this.Datom = Datom;
        return this;
      }

    };

    Datom.include(MAIN, {
      overwrite: false
    });

    Datom.include(require('./xemitter.mixin'), {
      overwrite: false
    });

    return Datom;

  }).call(this);

  module.exports = new Datom();

}).call(this);

//# sourceMappingURL=main.js.map