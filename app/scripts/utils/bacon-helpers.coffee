
unless console?
  nop = ->
  window.console = log: nop, warn: nop, error: nop, debug: nop


Bacon.Observable::skipNulls = do ->
  nonNull = (v) -> v?
  -> @filter nonNull


Bacon.Observable::toProp = (initialValue) ->
  $prop = @toProperty.apply this, arguments
  value = undefined
  $prop.get = -> value
  $prop.onValue (v) -> value = v
  $prop
