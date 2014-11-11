
exports.obtainClientData = ->
  try
    cookiesByName = listCookiesByName()
    unless ( clientDataCookie = cookiesByName.cd )? then return {}
    JSON.parse b64_to_utf8 clientDataCookie
  catch e
    console?.warn? 'error parsing clientData cookie: ' + e
    {}


exports.listCookiesByName = listCookiesByName = ->
  cookies = {}
  for cookie in document.cookie.split '; '
    idx = cookie.indexOf '='
    if idx >= 0
      cookies[ cookie.substr(0, idx) ] = cookie.substr(idx + 1)
  cookies


exports.b64_to_utf8 = b64_to_utf8 = (str) ->
  unescape decodeURIComponent atob str
