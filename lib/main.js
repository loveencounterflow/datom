(function() {
  'use strict';
  var Dataclass, Datom, GUY, MAIN, alert, assign, debug, echo, get_base_types, help, info, inspect, letsfreezethat, letsfreezethat_nofreeze, log, matcher_cache, plain, praise, rpr, urge, warn, whisper;

  //###########################################################################################################
  GUY = require('guy');

  ({alert, debug, help, info, plain, praise, urge, warn, whisper} = GUY.trm.get_loggers('DATOM'));

  ({rpr, inspect, echo, log} = GUY.trm);

  ({assign} = Object);

  //...........................................................................................................
  ({get_base_types} = require('./types'));

  letsfreezethat = require('letsfreezethat');

  letsfreezethat_nofreeze = require('letsfreezethat/nofreeze');

  matcher_cache = new Map();

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
      this.new_fresh_datom = this.new_fresh_datom.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.select = this.select.bind(this);
      // super()
      this.types = get_base_types();
      this.cfg = letsfreezethat.freeze(this.types.create.datom_constructor_cfg(cfg));
      this.LFT = this.cfg.freeze ? letsfreezethat : letsfreezethat_nofreeze;
      this.freeze = this.LFT.freeze;
      this.thaw = this.LFT.thaw;
      GUY.props.hide(this, 'matcher_cache', matcher_cache);
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

    new_datom($key, ...P) {
      this.types.validate.datom_key($key);
      return this.freeze(assign({$key}, ...P, {$key}));
    }

    new_fresh_datom(...P) {
      return this.new_datom(...P, {
        $fresh: true
      });
    }

    //=========================================================================================================

    //---------------------------------------------------------------------------------------------------------
    _get_matcher(selector) {
      var R, re;
      if ((R = matcher_cache.get(selector)) != null) {
        /* TAINT might make this method part of API */
        return R;
      }
      selector = selector.replace(/(?<!\\)\?/g, '.?');
      selector = selector.replace(/(?<!\\)\*/g, '.*');
      selector = `^(?:${selector})$`;
      re = new RegExp(selector, 'u');
      R = function(x) {
        return re.test(x);
      };
      matcher_cache.set(selector, R);
      return R;
    }

    select(d, ...selectors) {
      var i, len, ref, selector;
      if (!(selectors.length > 0)) {
        throw new Error("µ86606 expected a selector, got none");
      }
      if (!((this.types.isa.object(d)) && (d.$key != null))) {
        return false;
      }
      if ((ref = d.$stamped) != null ? ref : false) {
        return false;
      }
//.......................................................................................................
      for (i = 0, len = selectors.length; i < len; i++) {
        selector = selectors[i];
        if ((this._get_matcher(selector))(d.$key)) {
          return true;
        }
      }
      return false;
    }

  };

  Dataclass = (function() {
    //===========================================================================================================
    class Dataclass {
      //---------------------------------------------------------------------------------------------------------
      static _freeze_on_access(x) {
        return new Proxy(x, {
          //.......................................................................................................
          get: function(target, key, receiver) {
            if (!Object.isFrozen(target)) {
              Object.freeze(target);
            }
            return Reflect.get(target, key, receiver);
          },
          //.......................................................................................................
          set: function(target, key, value, receiver) {
            if (!Object.isFrozen(target)) {
              Object.freeze(target);
            }
            throw new TypeError(`Cannot assign to read only property ${rpr(key)} of object ${rpr(target)}`);
          }
        });
      }

      // #---------------------------------------------------------------------------------------------------------
      // @register: ->

        //---------------------------------------------------------------------------------------------------------
      constructor(cfg) {
        var R, __types, clasz, declaration, freezemode, k, paragon, ref, ref1, v;
        clasz = this.constructor;
        __types = (ref = clasz.types) != null ? ref : new (require('intertype')).Intertype();
        GUY.props.hide(this, '__types', __types);
        declaration = clasz.declaration;
        freezemode = (ref1 = declaration != null ? declaration.freeze : void 0) != null ? ref1 : 'deep';
        if (declaration != null) {
          if (!this.__types.isa.knowntype(clasz.name)) {
            this.__types.declare[clasz.name](declaration);
          }
          paragon = this.__types.create[clasz.name](cfg);
          if (freezemode === 'deep') {
            paragon = GUY.lft.freeze(paragon);
          }
          for (k in paragon) {
            v = paragon[k];
            this[k] = v;
          }
        }
        if (freezemode === false) {
          return void 0;
        }
        (R = clasz._freeze_on_access(this))[Symbol('test')];
        return R;
      }

    };

    //---------------------------------------------------------------------------------------------------------
    Dataclass.declaration = null;

    return Dataclass;

  }).call(this);

  //===========================================================================================================
  module.exports = {
    Datom,
    DATOM: new Datom(),
    Dataclass
  };

}).call(this);

//# sourceMappingURL=main.js.map