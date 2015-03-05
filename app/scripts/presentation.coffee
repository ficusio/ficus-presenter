PollChart = require './poll-chart'
plurals   = require './utils/plurals'

###
# Делает текст вида "уже 5 человек приняли решение"
###
pollTotalText = (total) ->
  peopleInflection =
    'one':   'человек принял'
    'few':   'человекa приняли'
    'many':  'человек приняли'
    'other': 'человек приняли'

  peopleText = peopleInflection[ plurals.ru(total) ]
  "уже #{total} #{peopleText} решение"

module.exports = class Presentation
  constructor: (@api, @pdfjs) ->
    @pdfjs.$slide.onValue (slideNum) =>
      @onSlideChanged slideNum

  finishPresentation: ->
    @api.finishPresentation()

  startPoll: ->
    $('.naming-poll').show()
    $('.poll-results').hide()
    @api.startPoll 'build-system',
      title: 'Чем вы будете собирать следующий проект'
      options: [
        label: 'Grunt'
        color: '#f1c40f'
      ,
        label: 'Gulp'
        color: '#e74c3c'
      ,
        label: 'Brunch'
        color: '#3498db'
      ,
        label: 'Broccoli'
        color: '#16a085'
      ,
        label: 'Bud'
        color: '#9b59b6'
      ,
        label: 'Webpack'
        color: '#7ea9e8'
      ]

    chart = @chart = new PollChart('.poll-container')

    @pollActive = true

    @api.$pollState.onValue (pollData) =>
      return if (chart.isDestroyed or !pollData?)

      total = d3.sum(pollData, (d) -> d.count)
      $('.poll-total').text(pollTotalText(total))

      @pollData = pollData
      @chart.updateData(pollData)

  stopPoll: ->
    $('.naming-poll').hide()
    $('.poll-results').hide()
    return unless @pollActive
    @pollActive = false

    # останавливаем голосование
    @api.stopPoll()

    # выключаем график
    return unless @chart?
    @chart.destroy() unless @chart.isDestroyed

  showPollResults: ->
    return unless @pollData?
    $('.naming-poll').hide()
    $('.poll-results').show()
    winner = _.max @pollData, (d) -> d.count
    $('.poll-wrapper').css('background-color', winner.color)
    $('.poll-results').attr('data-background', winner.color)
    $('.winner-name').text(winner.label)

  onSlideChanged: (slideNum) ->
    console.log 'onSlideChanged', slideNum

    participantsSlideNumber = 3
    pollSlideNumber = 16
    lastSlideNumber = 18

    switch slideNum
      when participantsSlideNumber - 1
        $('.participants-wrapper').hide()
      when participantsSlideNumber
        $('.participants-wrapper').show()
        do @stopPoll
      when participantsSlideNumber + 1
        $('.participants-wrapper').hide()
      when pollSlideNumber - 1
        do @stopPoll
      when pollSlideNumber
        do @startPoll
        $('.poll-wrapper').css('background-color', 'transparent')
        $('.poll-results').hide()
      when pollSlideNumber + 1
        do @stopPoll
        do @showPollResults
      when pollSlideNumber + 2
        $('.poll-wrapper').css('background-color', 'transparent')
        $('.poll-results').hide()
      when lastSlideNumber
        do @finishPresentation
