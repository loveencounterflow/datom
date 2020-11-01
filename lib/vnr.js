(function() {
  'use strict';
  var CND, MAIN, Multimix, Vnr, assign, badge, debug, defaults, echo, help, info, isa, jr, rpr, types, urge, validate, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'DATOM/VNR';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  urge = CND.get_logger('urge', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  ({jr, assign} = CND);

  //...........................................................................................................
  types = require('./types');

  ({isa, defaults, validate} = types);

  Multimix = require('multimix');

  //-----------------------------------------------------------------------------------------------------------
  this.new_vnr = function(source = null) {
    if (source == null) {
      return [0];
    }
    if (this.settings.validate) {
      validate.vnr(source);
    }
    return [...source];
  };

  //-----------------------------------------------------------------------------------------------------------
  this.deepen = function(d, nr = 0) {
    if (this.settings.validate) {
      /* Given a vectorial line number `vnr`, return a copy of `vnr`, call it
       `vnr0`, which has an index of `0` appended, thus representing the pre-first `vnr` for a level of lines
       derived from the one that the original `vnr` pointed to. */
      validate.vnr(d);
    }
    return [...d, nr];
  };

  //-----------------------------------------------------------------------------------------------------------
  this.advance = function(d) {
    return this._advance_or_recede(d, +1);
  };

  this.recede = function(d) {
    return this._advance_or_recede(d, -1);
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @_lower_bound = ( vnr ) ->
  //   ### Return a new VNR `z` such that `( as_hollerith vnr ) > ( as_hollerith z )` holds; this is needed to
  //   iterate over all rows within a given limit. ###
  //   validate.vnr vnr
  //   return [ vnr[ 0 ] - 1 ]

  // #-----------------------------------------------------------------------------------------------------------
  // @_upper_bound = ( vnr ) ->
  //   ### Return a new VNR `z` such that `( as_hollerith vnr ) < ( as_hollerith z )` holds; this is needed to
  //   iterate over all rows within a given limit. ###
  //   validate.vnr vnr
  //   return [ vnr[ 0 ] + 1 ]

  //-----------------------------------------------------------------------------------------------------------
  this._advance_or_recede = function(d, delta) {
    var R;
    if (this.settings.validate) {
      /* Given a vectorial line number `vnr`, return a copy of `vnr`, call it
       `vnr0`, which has its last index incremented by `1`, thus representing the vectorial line number of the
       next line in the same level that is derived from the same line as its predecessor. */
      validate.vnr(d);
    }
    R = [...d];
    R[d.length - 1] += delta;
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.cmp_total = function(a, b) {
    var ai, bi, i, idx, min_idx, ref;
    /* Given two VNRs `𝖆` and `𝖇`, return `-1` if `𝖆` comes lexicographically before `𝖇`, `+1` if `𝖆` comes
     after `𝖇` and `0` if `𝖆` equals `𝖇`. This works by comparing all integers in `𝖆` and `𝖇` in a pairwise
     fashion and stopping at the first difference; if no difference is found, then either `𝖆` equals `𝖇` or
     else `𝖆` is the prefix of `𝖇` (so `𝖆` comes before `𝖇`) or vice versa. Because this method provides a
     *total* ordering over all VNRs—that is, any two VNRs are either identical (`𝖆 ≍ 𝖇 ⇔ 𝖆 = 𝖇`) or else the
     one comes before the other—it is called `cmp_total`.  */
    if (this.settings.validate) {
      validate.vnr(a);
      validate.vnr(b);
    }
    min_idx = (Math.min(a.length, b.length)) - 1;
    for (idx = i = 0, ref = min_idx; (0 <= ref ? i <= ref : i >= ref); idx = 0 <= ref ? ++i : --i) {
      ai = a[idx];
      bi = b[idx];
      if (ai < bi) {
        return -1;
      }
      if (ai > bi) {
        return +1;
      }
    }
    if (a.length < b.length) {
      return -1;
    }
    if (a.length > b.length) {
      return +1;
    }
    return 0;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.cmp_partial = function(a, b) {
    var ai, bi, i, idx, max_idx, ref, ref1, ref2;
    /* Like `cmp_total()`, but returns `0` in case either VNR is a prefix of the other, that is to say, e.g.
    `[ 4, 7, ]` is equivalent to `[ 4, 7, 0, ]`, `[ 4, 7, 0, 0, ]` and so on. This is not a total ordering
    because `[ 4, 7, ]` is clearly not equal to `[ 4, 7, 0, ]` and so on, yet is considered to be in the same
    position; therefore, the relative ordering of these two VNRs is undefined. Since such an ordering is
    called partial this method has been called `cmp_partial`.

    `cmp_partial()` is the default ordering method for VNRs because it allows to add arbitrary numbers of
    items in a sequence before or after a given position (the reference) *without having to modify any
    existing item*, only by knowing the reference's VNR. This is because `[ x, -1, ] ≺ ( [ x, 0, ] ≍ [ x, ] )
    ≺ [ x, +1, ]` in partial ordering */
    if (this.settings.validate) {
      validate.vnr(a);
      validate.vnr(b);
    }
    max_idx = (Math.max(a.length, b.length)) - 1;
    for (idx = i = 0, ref = max_idx; (0 <= ref ? i <= ref : i >= ref); idx = 0 <= ref ? ++i : --i) {
      ai = (ref1 = a[idx]) != null ? ref1 : 0;
      bi = (ref2 = b[idx]) != null ? ref2 : 0;
      if (ai < bi) {
        return -1;
      }
      if (ai > bi) {
        return +1;
      }
    }
    return 0;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._first_nonzero_is_negative = function(list, first_idx) {
    var R, idx;
    idx = first_idx;
    while (true) {
      if ((R = list[idx]) === 0) {
        idx++;
        continue;
      }
      if ((R === void 0) || (R > 0)) {
        return false;
      }
      return true;
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  this.cmp_fair = function(a, b) {
    var a_length, ai, b_length, bi, i, idx, min_idx, ref;
    if (this.settings.validate) {
      validate.vnr(a);
      validate.vnr(b);
    }
    a_length = a.length;
    b_length = b.length;
    min_idx = (Math.min(a_length, b_length)) - 1;
    for (idx = i = 0, ref = min_idx; (0 <= ref ? i <= ref : i >= ref); idx = 0 <= ref ? ++i : --i) {
      ai = a[idx];
      bi = b[idx];
      if (ai < bi) {
        return -1;
      }
      if (ai > bi) {
        return +1;
      }
    }
    if (a_length === b_length) {
      return 0;
    }
    if (a_length < b_length) {
      if (this._first_nonzero_is_negative(b, min_idx + 1)) {
        return +1;
      }
      return -1;
    }
    if (this._first_nonzero_is_negative(a, min_idx + 1)) {
      return -1;
    }
    return +1;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.sort = function(vnrs) {
    if (this.settings.validate) {
      /* Given a list of VNRs, return a copy of the list with the VNRs lexicographically sorted. */
      validate.list(vnrs);
    }
    return [...vnrs].sort(this._cmp);
  };

  //===========================================================================================================
  // EXPORT
  //-----------------------------------------------------------------------------------------------------------
  MAIN = this;

  Vnr = (function() {
    class Vnr extends Multimix {
      //---------------------------------------------------------------------------------------------------------
      constructor(settings = null) {
        super();
        validate.datom_vnr_settings(settings = {...defaults.vnr_settings, ...settings});
        this.settings = (require('letsfreezethat')).freeze(settings);
        this.Vnr = Vnr;
        this._cmp = (function() {
          switch (this.settings.ordering) {
            case 'fair':
              return this.cmp_fair.bind(this);
            case 'partial':
              return this.cmp_partial.bind(this);
            case 'total':
              return this.cmp_total.bind(this);
          }
        }).call(this);
        return this;
      }

    };

    Vnr.include(MAIN, {
      overwrite: false
    });

    return Vnr;

  }).call(this);

  module.exports = new Vnr();

}).call(this);

//# sourceMappingURL=vnr.js.map