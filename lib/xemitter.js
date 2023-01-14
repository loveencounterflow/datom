(function() {
  'use strict';
  var DATOM, Emittery, GUY, Xemitter, alert, debug, echo, get_base_types, get_xemitter_types, help, info, inspect, log, misfit, plain, praise, rpr, urge, warn, whisper;

  //###########################################################################################################
  GUY = require('guy');

  ({alert, debug, help, info, plain, praise, urge, warn, whisper} = GUY.trm.get_loggers('DATOM/XEMITTER'));

  ({rpr, inspect, echo, log} = GUY.trm);

  //...........................................................................................................
  Emittery = require('../deps/emittery.js');

  ({DATOM} = require('./main'));

  ({misfit, get_base_types, get_xemitter_types} = require('./types'));

  //===========================================================================================================
  Xemitter = class Xemitter {
    //---------------------------------------------------------------------------------------------------------
    constructor() {
      //---------------------------------------------------------------------------------------------------------
      this._mark_as_primary = this._mark_as_primary.bind(this);
      this._filter_primary = this._filter_primary.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this._get_primary = this._get_primary.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this._datom_from_emit_arguments = this._datom_from_emit_arguments.bind(this);
      //=========================================================================================================
      // API / RECEIVING
      //---------------------------------------------------------------------------------------------------------
      this.contract = this.contract.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.listen_to = this.listen_to.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.listen_to_all = this.listen_to_all.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.listen_to_unheard = this.listen_to_unheard.bind(this);
      //=========================================================================================================
      // API / SENDING
      //---------------------------------------------------------------------------------------------------------
      this.emit = this.emit.bind(this);
      //---------------------------------------------------------------------------------------------------------
      this.delegate = this.delegate.bind(this);
      this.types = get_xemitter_types();
      this._emitter = new Emittery();
      this._has_contractors = {};
      this._has_listener = {};
      return void 0;
    }

    _mark_as_primary(x) {
      return DATOM.wrap_datom('~XEMITTER-preferred', {
        $key: '~wrapper',
        $value: x
      });
    }

    _filter_primary(x) {
      return DATOM.select(x, '~XEMITTER-preferred');
    }

    _get_primary(values) {
      var primary_responses, ref;
      primary_responses = values.filter(this._filter_primary);
      if (!(primary_responses.length > 0)) {
        return misfit;
      }
      return (ref = primary_responses[0]) != null ? ref.$value.$value : void 0;
    }

    _datom_from_emit_arguments(...P) {
      var arity, d;
      if (!((arity = P.length) > 0)) {
        throw new Error("µ44422 expected one or more arguments, got none");
      }
      if (this.types.isa.text(P[0])) {
        return DATOM.new_datom(P[0], ...P.slice(1));
      }
      if ((arity = P.length) !== 1) {
        throw new Error(`µ44422 expected single argument unless first is key, got ${arity}`);
      }
      if (!DATOM.is_datom(d = P[0])) {
        throw new Error(`µ44422 expected a text or a datom got a ${this.types.type_of(d)}`);
      }
      return d;
    }

    contract(key, listener) {
      this.types.validate.datom_key(key);
      this.types.validate.callable(listener);
      if (this._has_contractors[key]) {
        throw new Error(`µ68704 key ${rpr(key)} already has a primary listener`);
      }
      this._has_contractors[key] = true;
      this._has_listener[key] = true;
      return this._emitter.on(key, async(d) => {
        return this._mark_as_primary((await listener(d)));
      });
    }

    listen_to(key, listener) {
      this.types.validate.datom_key(key);
      this.types.validate.callable(listener);
      this._has_listener[key] = true;
      return this._emitter.on(key, async(d) => {
        return (await listener(d));
      });
    }

    listen_to_all(listener) {
      this.types.validate.callable(listener);
      return this._emitter.onAny(async(key, d) => {
        return (await listener(key, d));
      });
    }

    listen_to_unheard(listener) {
      this.types.validate.callable(listener);
      return this._emitter.onAny(async(key, d) => {
        if (!this._has_listener[key]) {
          return (await listener(key, d));
        }
      });
    }

    async emit(key, d) {
      d = this._datom_from_emit_arguments(...arguments);
      return (await this._emitter.emit(d.$key, d));
    }

    async delegate(key, d) {
      var R, ref;
      if ((R = this._get_primary((await this.emit(...arguments)))) === misfit) {
        throw new Error(`µ83733 no results for ${rpr((ref = key.$key) != null ? ref : key)}`);
      }
      return R;
    }

  };

  module.exports = {
    Xemitter,
    XEMITTER: new Xemitter()
  };

}).call(this);

//# sourceMappingURL=xemitter.js.map