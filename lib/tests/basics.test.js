(function() {
  'use strict';
  var CND, badge, debug, echo, help, info, isa, jr, rpr, test, type_of, types, urge, validate, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/TESTS/BASICS';

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

  ({isa, validate, type_of} = types);

  //-----------------------------------------------------------------------------------------------------------
  this["fresh_datom"] = async function(T, done) {
    var DATOM, error, i, len, matcher, probe, probes_and_matchers;
    DATOM = require('../..');
    probes_and_matchers = [
      [
        ['^foo'],
        {
          '$fresh': true,
          '$key': '^foo'
        },
        null
      ],
      [
        [
          '^foo',
          {
            foo: 'bar'
          }
        ],
        {
          foo: 'bar',
          '$fresh': true,
          '$key': '^foo'
        },
        null
      ],
      [
        ['^foo',
        42],
        {
          '$value': 42,
          '$fresh': true,
          '$key': '^foo'
        },
        null
      ],
      [
        [
          '^foo',
          42,
          {
            '$fresh': false
          }
        ],
        {
          '$value': 42,
          '$fresh': true,
          '$key': '^foo'
        },
        null
      ]
    ];
//.........................................................................................................
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          resolve(DATOM.fresh_datom(...probe));
          return null;
        });
      });
    }
    done();
    return null;
  };

  //###########################################################################################################
  if (require.main === module) {
    (() => {
      // test @
      return test(this["fresh_datom"]);
    })();
  }

  // test @[ "wrap_datom" ]
// test @[ "new_datom complains when value has `$key`" ]
// test @[ "selector keypatterns" ]
// test @[ "select 2" ]
// test @[ "new_datom (default settings)" ]
// debug new_datom '^helo', 42

}).call(this);
