TEMPLATE_SELECTOR = '#participants-template'
ANIMATION_DURATION = 200

module.exports = class Participants
  constructor: (@api, @rootSelector, initialState={}) ->
    @templateFunc = _.template($(TEMPLATE_SELECTOR).html())
    $(@rootSelector).html( @templateFunc() )

    # Слушаем изменение людей
    @api.$listenerCount.onValue _.bind(@drawHumans, @)

    if initialState.totalClients?
      @drawHumans(initialState.totalClients)

  drawHumans: (amount) ->
    root = $(@rootSelector)
    currentCount = root.find('.human').length

    if currentCount is amount
      return

    if currentCount > amount
      for i in [amount..currentCount - 1]
        root.find('.human').last().remove()

    if currentCount < amount
      for i in [currentCount..amount - 1]
        root.find('.people').append( '<div class="human icon-person"></div>' )

    countNext    = root.find('.count-next')
    countCurrent = root.find('.count')
    container    = root.find('.meter')

    countNext.text(amount)
    container.addClass('changed')

    setTimeout ->
      container.removeClass('changed')
      countCurrent.text(countNext.text())
    , ANIMATION_DURATION



