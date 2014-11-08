window.drawHumans = (amount) ->
  root = $('#participants-container')
  currentCount = root.find('.human').length

  if currentCount > amount
    for i in [amount..currentCount - 1]
      root.find('.human').last().remove()
  else
    for i in [currentCount..amount - 1]
      root.find('.people').append( '<div class="human icon-person"></div>' )

  countNext    = root.find('.count-next')
  countCurrent = root.find('.count')
  container    = root.find('.meter')

  countNext.text(amount)
  container.addClass('changed')

  setTimeout (->
    container.removeClass('changed')
    countCurrent.text(countNext.text())

    ), 200



