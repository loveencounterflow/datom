(function() {
  'use strict';
  var CND, alert, badge, cast, debug, help, info, isa, misfit, provide_library, rpr, type_of, types, urge, validate, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/XEMITTER';

  debug = CND.get_logger('debug', badge);

  alert = CND.get_logger('alert', badge);

  whisper = CND.get_logger('whisper', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  info = CND.get_logger('info', badge);

  //...........................................................................................................
  misfit = Symbol('misfit');

  types = require('./types');

  ({isa, validate, cast, type_of} = types);

  //-----------------------------------------------------------------------------------------------------------
  /* rewrite using MultiMix` */
  provide_library = function() {
    var DATOM, Emittery, L, name, ref, results, value;
    //=========================================================================================================
    /* https://github.com/sindresorhus/emittery */
    Emittery = require('emittery');
    DATOM = require('..');
    //=========================================================================================================
    // IMPLEMENTATION DETAILS
    //---------------------------------------------------------------------------------------------------------
    this._emitter = new Emittery();
    this._has_contractors = {};
    //---------------------------------------------------------------------------------------------------------
    this._mark_as_primary = function(x) {
      return DATOM.wrap_datom('~XEMITTER-preferred', {
        $key: '~wrapper',
        $value: x
      });
    };
    this._filter_primary = function(x) {
      return DATOM.select(x, '~XEMITTER-preferred');
    };
    //---------------------------------------------------------------------------------------------------------
    this._get_primary = function(values) {
      var primary_responses, ref;
      primary_responses = values.filter(this._filter_primary);
      if (!(primary_responses.length > 0)) {
        return misfit;
      }
      return (ref = primary_responses[0]) != null ? ref.$value.$value : void 0;
    };
    //---------------------------------------------------------------------------------------------------------
    this._get_ksl = function(key, self, listener) {
      var arity;
      switch (arity = arguments.length) {
        case 2:
          [key, self, listener] = [key, null, self];
          break;
        case 3:
          [key, self, listener] = [key, self, listener];
          break;
        default:
          throw new Error(`µ67348 expected 2 or 3 arguments, got ${arity}`);
      }
      validate.nonempty_text(key);
      return [key, self, listener];
    };
    //---------------------------------------------------------------------------------------------------------
    this._get_sl = function(self, listener) {
      var arity;
      switch (arity = arguments.length) {
        case 1:
          [self, listener] = [null, self];
          break;
        case 2:
          [self, listener] = [self, listener];
          break;
        default:
          throw new Error(`µ68252 expected 1 or 2 arguments, got ${arity}`);
      }
      return [self, listener];
    };
    //---------------------------------------------------------------------------------------------------------
    this._get_kd = function(key, d) {
      var arity, org_d, org_key;
      org_key = key;
      org_d = d;
      switch (arity = arguments.length) {
        case 1:
          if (isa.text(key)) {
            [key, d] = [key, key];
          } else {
            if (!DATOM.is_datom(key)) {
              throw new Error(`µ44422 expected a text or a datom got a ${type_of(key)}`);
            }
            [key, d] = [key.$key, key];
          }
          break;
        case 2:
          null;
          break;
        default:
          throw new Error(`µ69156 expected 1 or 2 arguments, got ${arity}`);
      }
      if (key == null) {
        throw new Error(`µ69608 expected a key, got ${rpr(key)} from ${rpr(org_key)}, ${rpr(org_d)}`);
      }
      return [key, d];
    };
    //=========================================================================================================
    // API / RECEIVING
    //---------------------------------------------------------------------------------------------------------
    this.contract = function(key, self, listener) {
      [key, self, listener] = this._get_ksl(...arguments);
      if (this._has_contractors[key]) {
        throw new Error(`µ68704 key ${rpr(key)} already has a primary listener`);
      }
      this._has_contractors[key] = true;
      return this._emitter.on(key, async(d) => {
        return this._mark_as_primary((await listener.call(self, d)));
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.listen_to = function(key, self, listener) {
      [key, self, listener] = this._get_ksl(...arguments);
      return this._emitter.on(key, async function(d) {
        return (await listener.call(self, d));
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.listen_to_all = function(self, listener) {
      [self, listener] = this._get_sl(...arguments);
      return this._emitter.onAny(async function(key, d) {
        return (await listener.call(self, key, d));
      });
    };
    //=========================================================================================================
    // API / SENDING
    //---------------------------------------------------------------------------------------------------------
    this.emit = async function(key, d) {
      return (await this._emitter.emit(...(this._get_kd(...arguments))));
    };
    //---------------------------------------------------------------------------------------------------------
    this.delegate = async function(key, d) {
      var R, ref;
      if ((R = this._get_primary((await this.emit(...arguments)))) === misfit) {
        throw new Error(`µ83733 no results for ${rpr((ref = key.$key) != null ? ref : key)}`);
      }
      return R;
    };
    ref = L = this;
    //=========================================================================================================

    //---------------------------------------------------------------------------------------------------------
    results = [];
    for (name in ref) {
      value = ref[name];
      if (!isa.function(value.bind)) {
        continue;
      }
      results.push(L[name] = value.bind(L));
    }
    return results;
  };

  //###########################################################################################################
  this.new_xemitter = function() {
    var R;
    provide_library.apply(R = {});
    return R;
  };

}).call(this);