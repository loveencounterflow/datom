(function() {
  'use strict';
  var GUY, Intertype, base_types, debug, echo, get_base_types, inspect, log, misfit, rpr;

  //###########################################################################################################
  GUY = require('guy');

  // { alert
  //   debug
  //   help
  //   info
  //   plain
  //   praise
  //   urge
  //   warn
  //   whisper }               = GUY.trm.get_loggers 'DATOM/TYPES'
  ({debug} = GUY.trm.get_loggers('DATOM/TYPES'));

  ({rpr, inspect, echo, log} = GUY.trm);

  ({Intertype} = require('intertype'));

  base_types = null;

  misfit = Symbol('misfit');

  //-----------------------------------------------------------------------------------------------------------
  get_base_types = function() {
    var declare;
    if (base_types != null) {
      return base_types;
    }
    //.........................................................................................................
    base_types = new Intertype();
    ({declare} = base_types);
    //.........................................................................................................
    declare.datom_constructor_cfg({
      fields: {
        merge_values: 'boolean',
        freeze: 'boolean',
        dirty: 'boolean'
      },
      /* TAINT ??? to be removed ??? */template: {
        merge_values: true,
        freeze: true,
        dirty: false
      }
    });
    //.........................................................................................................
    /* TAINT ??? to be removed ??? */    declare.datom_key(function(x) {
      return (this.isa.text(x)) && (x.length > 0);
    });
    //.........................................................................................................
    declare.datom_name('nonempty.text');
    //.........................................................................................................
    declare.datom_vnr(function(x) {
      if (x == null) {
        return true;
      }
      if (!this.isa.list(x)) {
        return false;
      }
      if (!(x.length > 0)) {
        return false;
      }
      return x.every((n) => {
        return this.isa.positive0.integer(n);
      });
    });
    //.........................................................................................................
    declare.datom_datom({
      fields: {
        $key: 'datom_key',
        $stamped: 'optional.boolean',
        $dirty: 'optional.boolean',
        $fresh: 'optional.boolean',
        $vnr: 'optional.datom_vnr'
      },
      template: {
        $key: null,
        $stamped: null,
        $dirty: null,
        $fresh: null
      }
    });
    //.........................................................................................................
    return base_types;
  };

  //===========================================================================================================
  module.exports = {misfit, get_base_types};

}).call(this);

//# sourceMappingURL=types.js.map