// Extracted from jQuery.cookie, authored by Klaus Hartl/klaus.hartl@stilbuero.de
window.Cookie = {
  set: function(key, value, options) {
    if( !options ) options = {}

    if (value === null || value === undefined) {
        options.expires = -1;
    }

    if (typeof options.expires === 'number') {
        var days = options.expires, t = options.expires = new Date();
        t.setDate(t.getDate() + days);
    }

    value = String(value);

    return (document.cookie = [
        encodeURIComponent(key), '=',
        options.raw ? value : encodeURIComponent(value),
        options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
        options.path ? '; path=' + options.path : '',
        options.domain ? '; domain=' + options.domain : '',
        options.secure ? '; secure' : ''
    ].join(''));
  },

  get: function(key, options) {
    if(!options) options = {}
    var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
    return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
  }
}
