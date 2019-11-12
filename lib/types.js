(function() {
  'use strict';
  var CND, Intertype, alert, badge, debug, help, info, intertype, jr, rpr, urge, warn, whisper,
    indexOf = [].indexOf;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/TYPES';

  debug = CND.get_logger('debug', badge);

  alert = CND.get_logger('alert', badge);

  whisper = CND.get_logger('whisper', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  info = CND.get_logger('info', badge);

  jr = JSON.stringify;

  Intertype = (require('intertype')).Intertype;

  intertype = new Intertype(module.exports);

  //-----------------------------------------------------------------------------------------------------------
  this.declare('datom_settings', {
    tests: {
      "x is a object": function(x) {
        return this.isa.object(x);
      },
      "x.merge_values is a ?boolean": function(x) {
        return (x.merge_values == null) || this.isa.boolean(x.merge_values);
      },
      "x.freeze is a ?boolean": function(x) {
        return (x.freeze == null) || this.isa.boolean(x.freeze);
      }
    }
  });

  //-----------------------------------------------------------------------------------------------------------
  this.declare('datom_nonempty_list_of_positive_integers', function(x) {
    if (!this.isa.nonempty_list(x)) {
      return false;
    }
    return x.every((xx) => {
      return this.isa.positive_integer(xx);
    });
  });

  //-----------------------------------------------------------------------------------------------------------
  this.declare('datom_sigil', {
    tests: {
      "x is a chr": function(x) {
        return this.isa.chr(x);
      },
      "x has sigil": function(x) {
        return indexOf.call('^<>~[]', x) >= 0;
      }
    }
  });

  //-----------------------------------------------------------------------------------------------------------
  this.declare('datom_key', {
    tests: {
      "x is a nonempty text": function(x) {
        return this.isa.nonempty_text(x);
      },
      "x has sigil": function(x) {
        return this.isa.datom_sigil(x[0]);
      }
    }
  });

  //-----------------------------------------------------------------------------------------------------------
  this.declare('datom_datom', {
    tests: {
      "x is a object": function(x) {
        return this.isa.object(x);
      },
      "x has key 'key'": function(x) {
        return this.has_key(x, 'key');
      },
      "x.key is a datom_key": function(x) {
        return this.isa.datom_key(x.key);
      },
      "x.$stamped is an optional boolean": function(x) {
        return (x.$stamped == null) || (this.isa.boolean(x.$stamped));
      },
      "x.$dirty is an optional boolean": function(x) {
        return (x.$dirty == null) || (this.isa.boolean(x.$dirty));
      },
      "x.$fresh is an optional boolean": function(x) {
        return (x.$fresh == null) || (this.isa.boolean(x.$fresh));
      },
      //.......................................................................................................
      "x.$vnr is an optional nonempty list of positive integers": function(x) {
        return (x.$vnr == null) || this.isa.datom_nonempty_list_of_positive_integers(x.$vnr);
      }
    }
  });

  //-----------------------------------------------------------------------------------------------------------
  this.declare('datom_value', function(x) {
    if (!this.isa.object(x)) {
      return true;
    }
    return x.$key === void 0;
  });

  //-----------------------------------------------------------------------------------------------------------
  this.defaults = {
    settings: {
      merge_values: true,
      freeze: true
    }
  };

}).call(this);
