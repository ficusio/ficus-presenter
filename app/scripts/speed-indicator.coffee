module.exports = class Feynman

  SPEED_INDICATOR_CLASS = '.speed-indicator'

  constructor: (@api) ->
    # ...

  updateSpeedIndicator: (value) ->
    value = Math.sign(value) if Math.abs(value) > 1

    fastBar = $("#{SPEED_INDICATOR_CLASS} .fast-bar")
    slowBar = $("#{SPEED_INDICATOR_CLASS} .slow-bar")

    fastBar.css(width: '0%')
    slowBar.css(width: '0%')

    if value > 0
      fastBar.css(width: "#{value * 50}%")

    if value < 0
      slowBar.css(width: "#{value * -50}%")

    middle =  $("#{SPEED_INDICATOR_CLASS} .middle")
    if value == 0
      middle.addClass('show')
    else
      middle.removeClass('show')