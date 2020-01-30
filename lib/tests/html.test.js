(function() {
  'use strict';
  var CND, DATOM, alert, badge, debug, echo, help, info, jr, log, new_datom, rpr, select, test, urge, warn, whisper, wrap_datom;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/TESTS/HTML';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  ({jr} = CND);

  //...........................................................................................................
  DATOM = new (require('../..')).Datom({
    dirty: false
  });

  // lets
  ({new_datom, wrap_datom, select} = DATOM.export());

  //...........................................................................................................
  test = require('guy-test');

  //===========================================================================================================
  // TESTS
  //-----------------------------------------------------------------------------------------------------------
  this["must quote attribute value"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [["", true, null], ["\"", true, null], ["'", true, null], ["<", true, null], ["<>", true, null], ["foo", false, null], ["foo bar", true, null], ["foo\nbar", true, null]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var must_quote;
          must_quote = !DATOM.HTML.isa.datom_html_naked_attribute_value(probe);
          return resolve(must_quote);
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["DATOM.HTML._as_attribute_literal"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [["", "''", null], ['"', '\'"\'', null], ["'", "'&#39;'", null], ["<", "'&lt;'", null], ["<>", "'&lt;&gt;'", null], ["foo", "foo", null], ["foo bar", "'foo bar'", null], ["foo\nbar", "'foo&#10;bar'", null], ["'<>'", "'&#39;&lt;&gt;&#39;'", null]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          return resolve(DATOM.HTML._as_attribute_literal(probe));
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["DATOM.HTML.isa.datom_html_tagname"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [["", false, null], ["\"", false, null], ["'", false, null], ["<", false, null], ["<>", false, null], ["foo bar", false, null], ["foo\nbar", false, null], ["foo", true, null], ["此は何ですか", true, null]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          return resolve(DATOM.HTML.isa.datom_html_tagname(probe));
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["DATOM.HTML.cast.html (singular tags)"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [
      [['^foo'],
      "<foo/>"],
      [
        [
          '^foo',
          {
            height: 42
          }
        ],
        "<foo height=42/>"
      ],
      [
        [
          '^foo',
          {
            class: 'plain'
          }
        ],
        "<foo class=plain/>"
      ],
      [
        [
          '^foo',
          {
            class: 'plain hilite'
          }
        ],
        "<foo class='plain hilite'/>"
      ],
      [
        [
          '^foo',
          {
            editable: true
          }
        ],
        "<foo editable/>"
      ],
      [
        [
          '^foo',
          {
            empty: ''
          }
        ],
        "<foo empty=''/>"
      ],
      [
        [
          '^foo',
          {
            specials: '<\n\'"&>'
          }
        ],
        "<foo specials='&lt;&#10;&#39;\"&amp;&gt;'/>"
      ],
      [
        [
          '^something',
          {
            one: 1,
            two: 2
          }
        ],
        "<something one=1 two=2/>"
      ],
      [
        [
          '^something',
          {
            z: 'Z',
            a: 'A'
          }
        ],
        "<something a=A z=Z/>"
      ]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var d;
          d = new_datom(...probe);
          return resolve(DATOM.HTML.cast.html(d));
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["DATOM.HTML.cast.html (closing tags)"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [
      [['>foo'],
      "</foo>"],
      [
        [
          '>foo',
          {
            height: 42
          }
        ],
        "</foo>"
      ],
      [
        [
          '>foo',
          {
            class: 'plain'
          }
        ],
        "</foo>"
      ],
      [
        [
          '>foo',
          {
            class: 'plain hilite'
          }
        ],
        "</foo>"
      ],
      [
        [
          '>foo',
          {
            editable: true
          }
        ],
        "</foo>"
      ],
      [
        [
          '>foo',
          {
            empty: ''
          }
        ],
        "</foo>"
      ],
      [
        [
          '>foo',
          {
            specials: '<\n\'"&>'
          }
        ],
        "</foo>"
      ],
      [
        [
          '>something',
          {
            one: 1,
            two: 2
          }
        ],
        "</something>"
      ],
      [
        [
          '>something',
          {
            z: 'Z',
            a: 'A'
          }
        ],
        "</something>"
      ]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var d;
          d = new_datom(...probe);
          return resolve(DATOM.HTML.cast.html(d));
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["DATOM.HTML.cast.html (opening tags)"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [
      [['<foo'],
      "<foo>"],
      [
        [
          '<foo',
          {
            height: 42
          }
        ],
        "<foo height=42>"
      ],
      [
        [
          '<foo',
          {
            class: 'plain'
          }
        ],
        "<foo class=plain>"
      ],
      [
        [
          '<foo',
          {
            class: 'plain hilite'
          }
        ],
        "<foo class='plain hilite'>"
      ],
      [
        [
          '<foo',
          {
            editable: true
          }
        ],
        "<foo editable>"
      ],
      [
        [
          '<foo',
          {
            empty: ''
          }
        ],
        "<foo empty=''>"
      ],
      [
        [
          '<foo',
          {
            specials: '<\n\'"&>'
          }
        ],
        "<foo specials='&lt;&#10;&#39;\"&amp;&gt;'>"
      ],
      [
        [
          '<something',
          {
            one: 1,
            two: 2
          }
        ],
        "<something one=1 two=2>"
      ],
      [
        [
          '<something',
          {
            z: 'Z',
            a: 'A'
          }
        ],
        "<something a=A z=Z>"
      ]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var d;
          d = new_datom(...probe);
          return resolve(DATOM.HTML.cast.html(d));
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["DATOM.HTML.cast.html (texts)"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [
      [['^text'],
      ""],
      [
        [
          '^text',
          {
            height: 42
          }
        ],
        ""
      ],
      [
        [
          '^text',
          {
            text: '<me & you>'
          }
        ],
        "&lt;me &amp; you&gt;"
      ]
    ];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var d;
          d = new_datom(...probe);
          return resolve(DATOM.HTML.cast.html(d));
        });
      });
    }
    //.........................................................................................................
    done();
    return null;
  };

  //###########################################################################################################
  if (module === require.main) {
    (() => { // await do =>
      // await @_demo()
      test(this);
      return help('ok');
    })();
  }

}).call(this);
