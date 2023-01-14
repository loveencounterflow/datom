(function() {
  'use strict';
  var Datom, GUY, MAIN, alert, assign, debug, echo, get_base_types, help, info, inspect, letsfreezethat, letsfreezethat_nofreeze, log, p1, p2, plain, praise, rpr, urge, warn, whisper,
    indexOf = [].indexOf;

  //###########################################################################################################
  GUY = require('guy');

  ({alert, debug, help, info, plain, praise, urge, warn, whisper} = GUY.trm.get_loggers('DATOM'));

  ({rpr, inspect, echo, log} = GUY.trm);

  ({assign} = Object);

  //...........................................................................................................
  ({get_base_types} = require('./types'));

  letsfreezethat = require('letsfreezethat');

  letsfreezethat_nofreeze = require('letsfreezethat/nofreeze');

  //===========================================================================================================
  // SELECT
  //-----------------------------------------------------------------------------------------------------------
  p1 = /^(?<skey>(?<sigil>[<^>\[~\]\x23])(?<key>[^<^>\[~\]\x23]*))$/u; // `\x23` used instead of `\#` which causes syntax error (???)

  p2 = /^(?<skey>(?<sigil>[<^>\[~\]\x23])(?<key>[^<^>\[~\]\x23]*))\x23(?<attribute>[^<^>\[~\]\x23]+):(?<value>[^<^>\[~\]\x23]+)$/u; // `\x23` used instead of `\#` which causes syntax error (???)

  //===========================================================================================================
  // EXPORT
  //-----------------------------------------------------------------------------------------------------------
  MAIN = this;

  Datom = class Datom {
    //---------------------------------------------------------------------------------------------------------
    constructor(cfg = null) {
      //---------------------------------------------------------------------------------------------------------
      this.lets = this.lets.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.set = this.set.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.unset = this.unset.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.stamp = this.stamp.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.unstamp = this.unstamp.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.is_system = this.is_system.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.is_stamped = this.is_stamped.bind(this);
      this.is_fresh = this.is_fresh.bind(this);
      this.is_dirty = this.is_dirty.bind(this);
      this.is_datom = this.is_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.new_datom = this.new_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this._new_datom = this._new_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.fresh_datom = this.fresh_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.wrap_datom = this.wrap_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.new_single_datom = this.new_single_datom.bind(this);
      this.new_open_datom = this.new_open_datom.bind(this);
      this.new_close_datom = this.new_close_datom.bind(this);
      this.new_system_datom = this.new_system_datom.bind(this);
      this.new_text_datom = this.new_text_datom.bind(this);
      // @new_flush_datom    =                           -> @new_system_datom  'flush'

      //---------------------------------------------------------------------------------------------------------
      this.new_warning = this.new_warning.bind(this);
      //=========================================================================================================

      //---------------------------------------------------------------------------------------------------------
      /* TAINT likely to be removed */
      this.new_xemitter = this.new_xemitter.bind(this);
      //=========================================================================================================

      //---------------------------------------------------------------------------------------------------------
      this.select = this.select.bind(this);
      // super()
      this.types = get_base_types();
      this.cfg = letsfreezethat.freeze(this.types.create.datom_constructor_cfg(cfg));
      this.LFT = this.cfg.freeze ? letsfreezethat : letsfreezethat_nofreeze;
      this.freeze = this.LFT.freeze;
      this.thaw = this.LFT.thaw;
      return void 0;
    }

    lets(original, modifier) {
      var draft;
      draft = this.thaw(original);
      if (modifier != null) {
        modifier(draft);
        /* TAINT simplify logic by rewriting as single term without double negatives */
        if (this.cfg.dirty) {
          if (draft.$dirty === original.dirty) {
            draft.$dirty = true;
          }
        }
      }
      return this.freeze(draft);
    }

    set(d, k, ...P) {
      var count;
      if (this.types.isa.text(k)) {
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
    }

    unset(d, k) {
      return this.lets(d, function(d) {
        return delete d[k];
      });
    }

    stamp(d, ...P) {
      /* Set the `$stamped` attribute on datom to sigil it as processed. Stamped datoms will not be selected
         by the `select` method unless tag '#stamped' is used. */
      return this.lets(d, function(d) {
        return assign(d, ...P, {
          $stamped: true
        });
      });
    }

    unstamp(d) {
      if (!d.$stamped) {
        return d;
      }
      return this.lets(d, function(d) {
        return delete d.$stamped;
      });
    }

    is_system(d) {
      /* Return whether datom is a system datom (i.e. whether its `sigil` equals `'~'`). */
      return d.$key.match(/^[~\[\]]/);
    }

    is_stamped(d) {
      var ref1;
      return (ref1 = d.$stamped) != null ? ref1 : false/* i.e. already processed? */;
    }

    is_fresh(d) {
      var ref1;
      return (ref1 = d.$fresh) != null ? ref1 : false/* i.e. created within stream? */;
    }

    is_dirty(d) {
      var ref1;
      return (ref1 = d.$dirty) != null ? ref1 : false/* i.e. modified? */;
    }

    is_datom(x) {
      return this.types.isa.datom_datom(x);
    }

    new_datom($key, $value, ...other) {
      /* When `other` contains a key `$`, it is treated as a hint to copy
         system-level attributes; if the value of key `$` is a POD that has itself a
         key `$`, then a copy of that value is used. This allows to write `new_datom
         ..., $: d` to copy system-level attributes such as source locations to a new
         datom. */
      this.types.validate.datom_key($key);
      return this._new_datom($key, $value, ...other);
    }

    _new_datom($key, $value, ...other) {
      var R;
      if ($value != null) {
        if ((!this.cfg.merge_values) || (!this.types.isa.object($value))) {
          $value = {$value};
        }
        if (indexOf.call(Object.keys($value), '$key') >= 0) {
          throw new Error("µ55632 value must not have attribute '$key'");
        }
        R = assign({}, $value, ...other, {$key});
      } else {
        R = assign({}, ...other, {$key});
      }
      while ((this.types.isa.object(R.$)) && (this.types.isa.object(R.$.$))) {
        R.$ = this.LFT._deep_copy(R.$.$);
      }
      return this.freeze(R);
    }

    fresh_datom(...P) {
      return this.new_datom(...P, {
        $fresh: true
      });
    }

    wrap_datom($key, $value) {
      this.types.validate.datom_key($key);
      this.types.validate.datom_datom($value);
      return this.freeze({$key, $value});
    }

    new_single_datom(name, ...P) {
      this.types.validate.datom_name(name);
      return this._new_datom(`^${name}`, ...P);
    }

    new_open_datom(name, ...P) {
      this.types.validate.datom_name(name);
      return this.new_datom(`<${name}`, ...P);
    }

    new_close_datom(name, ...P) {
      this.types.validate.datom_name(name);
      return this.new_datom(`>${name}`, ...P);
    }

    new_system_datom(name, ...P) {
      this.types.validate.datom_name(name);
      return this.new_datom(`~${name}`, ...P);
    }

    new_text_datom(...P) {
      return this.new_single_datom('text', ...P);
    }

    new_end_datom() {
      return this.new_system_datom('end');
    }

    new_warning(ref, message, d, ...other) {
      return this.new_system_datom('warning', d, {ref, message}, ...other);
    }

    new_xemitter(...P) {
      return new (require('./xemitter')).Xemitter(...P);
    }

    select(d, selector) {
      var g, k, match, ref1, ref2, ref3, ref4, stamped_values, v;
      if (selector == null) {
        throw new Error("µ86606 expected a selector, got none");
      }
      if (!((this.types.isa.object(d)) && (d.$key != null))) {
        return false;
      }
      //.......................................................................................................
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
        //.......................................................................................................
        return false;
      }
      if (g.key != null) {
        return d.$key === g.skey;
      }
      if (!d.$key.startsWith(g.sigil)) {
        return false;
      }
      return true;
    }

  };

  //===========================================================================================================
  module.exports = {
    Datom,
    DATOM: new Datom()
  };

}).call(this);

//# sourceMappingURL=main.js.map