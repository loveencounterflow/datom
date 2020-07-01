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
    this._has_listener = {};
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
    this._datom_from_emit_arguments = function(...P) {
      var arity, d;
      if (!((arity = P.length) > 0)) {
        throw new Error("µ44422 expected one or more arguments, got none");
      }
      if (isa.text(P[0])) {
        return DATOM.new_datom(P[0], ...P.slice(1));
      }
      if ((arity = P.length) !== 1) {
        throw new Error(`µ44422 expected single argument unless first is key, got ${arity}`);
      }
      if (!DATOM.is_datom(d = P[0])) {
        throw new Error(`µ44422 expected a text or a datom got a ${type_of(d)}`);
      }
      return d;
    };
    //=========================================================================================================
    // API / RECEIVING
    //---------------------------------------------------------------------------------------------------------
    this.contract = function(key, listener) {
      validate.datom_key(key);
      validate.callable(listener);
      if (this._has_contractors[key]) {
        throw new Error(`µ68704 key ${rpr(key)} already has a primary listener`);
      }
      this._has_contractors[key] = true;
      this._has_listener[key] = true;
      return this._emitter.on(key, async(d) => {
        return this._mark_as_primary((await listener(d)));
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.listen_to = function(key, listener) {
      validate.datom_key(key);
      validate.callable(listener);
      this._has_listener[key] = true;
      return this._emitter.on(key, async(d) => {
        return (await listener(d));
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.listen_to_all = function(listener) {
      validate.callable(listener);
      return this._emitter.onAny(async(key, d) => {
        return (await listener(key, d));
      });
    };
    //---------------------------------------------------------------------------------------------------------
    this.listen_to_unheard = function(listener) {
      validate.callable(listener);
      return this._emitter.onAny(async(key, d) => {
        if (!this._has_listener[key]) {
          return (await listener(key, d));
        }
      });
    };
    //=========================================================================================================
    // API / SENDING
    //---------------------------------------------------------------------------------------------------------
    this.emit = async function(key, d) {
      d = this._datom_from_emit_arguments(...arguments);
      return (await this._emitter.emit(d.$key, d));
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

//# sourceMappingURL=xemitter.mixin.js.map