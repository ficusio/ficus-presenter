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
  constructor: (@api) ->
    Reveal.initialize
      controls: false
      progress: false
      history: false
      center: true
      transition: 'fade'
      dependencies: []

    Reveal.addEventListener 'slidechanged', (event) =>
      slide = event.currentSlide
      slideName = $(slide).data('slide-name')
      @onSlideChanged(slideName)

  finishPresentation: ->
    @api.finishPresentation()

  startPoll: ->
    @api.startPoll 'project-name',
      title: 'Помогите выбрать название проекта'
      options: [
        label: 'Flow'
        color: '#f1c40f'
      ,
        label: 'Feynman'
        color: '#e74c3c'
      ,
        label: 'Ficus'
        color: '#3498db'
      ,
        label: 'Feedbacker'
        color: '#16a085'
      ,
        label: 'Fellini'
        color: '#9b59b6'
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
    return unless @pollActive
    @pollActive = false

    # останавливаем голосование
    @api.stopPoll()

    # выключаем график
    return unless @chart?
    @chart.destroy() unless @chart.isDestroyed

  showPollResults: ->
    return unless @pollData?
    winner = _.max @pollData, (d) -> d.count
    $('section.poll-results').attr('data-background', winner.color)
    $('.winner-name').text(winner.label)
    Reveal.sync()

  onSlideChanged: (slideName) ->
    switch slideName
      when 'bored-audience-1'
        true
      when 'interactivity'
        true
      when 'lectors-speed'
        do @stopPoll
      when 'naming-poll'
        do @startPoll
      when 'poll-results'
        do @stopPoll
        do @showPollResults
      when 'contacts'
        do @finishPresentation

