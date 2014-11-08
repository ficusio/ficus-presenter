PollChart = require './poll-chart'

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
      ]
    @chart = new PollChart('.poll-container')
    @api.$pollState.onValue (pollData) =>
      return if @chart.isDestroyed
      return unless pollData?
      @pollData = pollData
      @chart.updateData(pollData)

  stopPoll: ->
    @api.stopPoll()
    return unless @chart?
    return if @chart.isDestroyed
    @chart.destroy()

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
      when 'bored-audience-2'
        true
      when 'lectors-speed'
        do @stopPoll
      when 'naming-poll'
        do @startPoll
      when 'poll-results'
        do @stopPoll
        do @showPollResults
      when 'contacts'
        true