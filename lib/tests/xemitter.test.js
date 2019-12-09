(function() {
  'use strict';
  var CND, arity_of, badge, debug, echo, help, info, isa, jr, rpr, test, type_of, types, urge, validate, warn, whisper,
    indexOf = [].indexOf;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/TESTS/SELECT';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  urge = CND.get_logger('urge', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  test = require('guy-test');

  jr = JSON.stringify;

  //...........................................................................................................
  types = require('../types');

  ({isa, validate, arity_of, type_of} = types);

  //-----------------------------------------------------------------------------------------------------------
  this["_"] = async function(T, done) {
    var DATOM, error, i, len, matcher, new_datom, probe, probes_and_matchers, select;
    DATOM = require('../..');
    ({new_datom, select} = DATOM.export());
    //.........................................................................................................
    probes_and_matchers = [
      [
        [
          '^foo',
          {
            time: 1500000,
            value: "msg#1"
          }
        ],
        {
          "time": 1500000,
          "value": "msg#1",
          "$key": "^foo"
        },
        null
      ]
    ];
//.........................................................................................................
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var key, value;
          [key, value] = probe;
          return resolve(new_datom(key, value));
        });
      });
    }
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["public API shape"] = function(T, done) {
    var DATOM, XE, k, known_keys, new_datom, new_xemitter, select;
    DATOM = require('../..');
    ({new_datom, new_xemitter, select} = DATOM.export());
    //.........................................................................................................
    XE = new_xemitter();
    T.ok(isa.asyncfunction(XE.emit));
    T.ok(isa.asyncfunction(XE.delegate));
    T.ok(isa.function(XE.contract));
    T.ok(isa.function(XE.listen_to));
    T.ok(isa.function(XE.listen_to_all));
    T.eq(XE.emit.length, 2);
    T.eq(XE.delegate.length, 2);
    T.eq(XE.contract.length, 2);
    T.eq(XE.listen_to.length, 2);
    T.eq(XE.listen_to_all.length, 1);
    T.eq(XE.listen_to_unheard.length, 1);
    known_keys = ['emit', 'delegate', 'contract', 'listen_to', 'listen_to_all', 'listen_to_unheard'];
    T.eq((function() {
      var results;
      results = [];
      for (k in XE) {
        if ((!k.startsWith('_')) && (indexOf.call(known_keys, k) < 0)) {
          results.push(k);
        }
      }
      return results;
    })(), []);
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["emit equivalently accepts key, value or datom"] = async function(T, done) {
    var DATOM, XE, count, new_datom, new_xemitter, select;
    DATOM = require('../..');
    ({new_datom, new_xemitter, select} = DATOM.export());
    //.........................................................................................................
    count = 0;
    XE = new_xemitter();
    XE.listen_to('^mykey', function(d) {
      count++;
      return T.eq(d, {
        $key: '^mykey',
        $value: 42
      });
    });
    await XE.emit('^mykey', 42);
    await XE.emit(new_datom('^mykey', 42));
    await XE.emit(new_datom('^notmykey', 42));
    T.eq(count, 2);
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["throws when more than one contractor is added for given event key"] = function(T, done) {
    var DATOM, XE, new_datom, new_xemitter, select;
    DATOM = require('../..');
    ({new_datom, new_xemitter, select} = DATOM.export());
    XE = new_xemitter();
    //.........................................................................................................
    XE.contract('^mykey', function(d) {});
    XE.contract('^otherkey', function(d) {});
    T.throws(/already has a primary listener/, (function() {
      return XE.contract('^otherkey', function(d) {});
    }));
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["can listen to events that have no specific listener"] = async function(T, done) {
    var DATOM, XE, keys, new_datom, new_xemitter, select;
    DATOM = require('../..');
    ({new_datom, new_xemitter, select} = DATOM.export());
    XE = new_xemitter();
    //.........................................................................................................
    keys = {
      listen: [],
      contract: [],
      all: [],
      unheard: []
    };
    XE.listen_to('^mykey', function(d) {
      return keys.listen.push(d.$key);
    });
    XE.contract('^otherkey', function(d) {
      return keys.contract.push(d.$key);
    });
    XE.listen_to_all(function(key, d) {
      return keys.all.push(d.$key);
    });
    XE.listen_to_unheard(function(key, d) {
      return keys.unheard.push(d.$key);
    });
    await XE.emit('^mykey');
    await XE.emit('^otherkey');
    await XE.emit('^thirdkey');
    // debug keys
    T.eq(keys, {
      listen: ['^mykey'],
      contract: ['^otherkey'],
      all: ['^mykey', '^otherkey', '^thirdkey'],
      unheard: ['^thirdkey']
    });
    done();
    return null;
  };

  //###########################################################################################################
  if (require.main === module) {
    (() => {
      return test(this);
    })();
  }

  // test @[ "public API shape" ]

}).call(this);
