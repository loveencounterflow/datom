(function() {
  'use strict';
  var Datom, GUY, MAIN, alert, assign, debug, echo, get_base_types, help, info, inspect, letsfreezethat, letsfreezethat_nofreeze, log, plain, praise, rpr, urge, warn, whisper,
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
      this.is_stamped = this.is_stamped.bind(this);
      this.is_fresh = this.is_fresh.bind(this);
      this.is_dirty = this.is_dirty.bind(this);
      this.is_datom = this.is_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.new_datom = this.new_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this._new_datom = this._new_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.new_fresh_datom = this.new_fresh_datom.bind(this);
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
        var ref, results, v;
        ref = assign({}, k, ...P);
        results = [];
        for (k in ref) {
          v = ref[k];
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
      /* Set the `$stamped` attribute on datom to mark it as processed. Stamped datoms will not be selected
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

    is_stamped(d) {
      var ref;
      return (ref = d.$stamped) != null ? ref : false/* i.e. already processed? */;
    }

    is_fresh(d) {
      var ref;
      return (ref = d.$fresh) != null ? ref : false/* i.e. created within stream? */;
    }

    is_dirty(d) {
      var ref;
      return (ref = d.$dirty) != null ? ref : false/* i.e. modified? */;
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

    new_fresh_datom(...P) {
      return this.new_datom(...P, {
        $fresh: true
      });
    }

    select(d, selector) {
      var ref;
      if (selector == null) {
        throw new Error("µ86606 expected a selector, got none");
      }
      if (!((this.types.isa.object(d)) && (d.$key != null))) {
        return false;
      }
      if ((ref = d.$stamped) != null ? ref : false) {
        return false;
      }
      return d.$key === selector;
    }

  };

  //===========================================================================================================
  module.exports = {
    Datom,
    DATOM: new Datom()
  };

}).call(this);

//# sourceMappingURL=main.js.map