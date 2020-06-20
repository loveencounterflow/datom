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
    /* When `other` contains a key `$`, it is treated as a hint to copy
     system-level attributes; if the value of key `$` is a POD that has itself a
     key `$`, then a copy of that value is used. This allows to write `new_datom
     ..., $: d` to copy system-level attributes such as source locations to a new
     datom. */
    validate.datom_key($key);
    return this._new_datom($key, $value, ...other);
  };

  //-----------------------------------------------------------------------------------------------------------
  this._new_datom = function($key, $value, ...other) {
    var R;
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
  this.new_single_datom = function(name, ...P) {
    validate.datom_name(name);
    return this._new_datom(`^${name}`, ...P);
  };

  this.new_open_datom = function(name, ...P) {
    validate.datom_name(name);
    return this.new_datom(`<${name}`, ...P);
  };

  this.new_close_datom = function(name, ...P) {
    validate.datom_name(name);
    return this.new_datom(`>${name}`, ...P);
  };

  this.new_system_datom = function(name, ...P) {
    validate.datom_name(name);
    return this.new_datom(`~${name}`, ...P);
  };

  this.new_text_datom = function(...P) {
    return this.new_single_datom('text', ...P);
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
        this.settings = Object.assign(this._defaults, this.settings);
        this.DATOM = (base = this.settings).DATOM != null ? base.DATOM : base.DATOM = module.exports;
        delete this.settings.DATOM;
      }

      //---------------------------------------------------------------------------------------------------------
      _analyze(name, tail) {
        /* NOTE to be overriden by derivatives as seen necessary */
        var attributes, content, i, idx, len, part, type;
        attributes = [];
        content = [];
        for (idx = i = 0, len = tail.length; i < len; idx = ++i) {
          part = tail[idx];
          switch (type = type_of(part)) {
            case 'object':
              attributes.push(part);
              break;
            case 'function':
              content.push(part);
              break;
            case /* NOTE always leave as-is, expanded by Cupofjoe */'text':
              content.push(this.DATOM.new_single_datom('text', {
                text: part,
                $: '^ð1^'
              }));
              break;
            default:
              content.push(this.DATOM.new_single_datom('value', {
                $value: part,
                $: '^ð2^'
              }));
          }
        }
        return {name, attributes, content};
      }

      //---------------------------------------------------------------------------------------------------------
      _cram(...P) {
        return super.cram(...P);
      }

      //---------------------------------------------------------------------------------------------------------
      cram(name, ...tail) {
        var attributes, content, d1, d2, has_attributes, v;
        // XXX_SUPER = @Cupofjoe.
        ({name, attributes, content} = this._analyze(name, tail));
        has_attributes = false;
        //.......................................................................................................
        if ((attributes != null) && attributes.length > 0) {
          has_attributes = true;
          attributes = Object.assign({}, ...attributes);
        }
        //.......................................................................................................
        if (has_attributes && name === null) {
          v = rpr({name, attributes, content});
          throw new Error(`^datom/cupofjoe@3498^ cannot have attributes without name, got ${v}`);
        }
        //.......................................................................................................
        if ((content != null) && content.length > 0) {
          if (name === null) {
            return super.cram(...content);
          }
          if (has_attributes) {
            d1 = this.DATOM.new_open_datom(name, attributes, {
              $: '^ð3^'
            });
            d2 = this.DATOM.new_close_datom(name, attributes, {
              $: '^ð4^'
            });
          } else {
            d1 = this.DATOM.new_open_datom(name, {
              $: '^ð5^'
            });
            d2 = this.DATOM.new_close_datom(name, {
              $: '^ð6^'
            });
          }
          return super.cram(d1, ...content, d2);
        }
        //.......................................................................................................
        if (has_attributes) {
          return super.cram(this.DATOM.new_single_datom(name, attributes, {
            $: '^ð7^'
          }));
        }
        if (name !== null) {
          return super.cram(this.DATOM.new_single_datom(name, {
            $: '^ð8^'
          }));
        }
        return null;
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