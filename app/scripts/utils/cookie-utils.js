
function b64_to_utf8 (str) {
  return unescape(decodeURIComponent(window.atob(str)));
}

function parseCookies () {
  var cookiesArr = document.cookie.split('; '),
      cookies = {};
  cookiesArr.forEach(function (cookie) {
    var idx = cookie.indexOf('=');
    if (idx != -1) cookies[ cookie.substring(0, idx) ] = cookie.substr(idx + 1);
  });
  return cookies;
};

function obtainClientData () {
  try {
    var cookies = parseCookies(),
        clientDataCookie = cookies.cd;
    if (clientDataCookie == null)
      return {};
    return JSON.parse(b64_to_utf8(clientDataCookie));
  }
  catch (e) {
    console.log('error parsing clientData cookie: ' + e);
    return {};
  }
};

module.exports = {
  b64_to_utf8: b64_to_utf8,
  parseCookies: parseCookies,
  obtainClientData: obtainClientData
};
