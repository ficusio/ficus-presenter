CloudPoll  = require './cloud-poll'
contenders = require './fixtures/contenders'

ALREADY_STARTED_KEY = 'ficus-poll-started'
PERSIST_POLL_STATE  = no

module.exports = class Presentation
  constructor: (@api) ->
    Reveal.initialize
      controls: false
      progress: false
      history: false
      center: true
      transition: 'fade'
      dependencies: []
      margin: 0.0
      width: 1024
      height: 768

    Reveal.addEventListener 'slidechanged', (event) =>
      slide = event.currentSlide
      slideName = $(slide).data('slide-name')
      @onSlideChanged(slideName)

    @cloudPoll = new CloudPoll('.cloud-poll')
    @startPoll()

  finishPresentation: ->
    @api.finishPresentation()

  startPoll: ->
    return if @pollActive
    @pollActive = true

    if PERSIST_POLL_STATE
      alreadyStarted = localStorage.getItem(ALREADY_STARTED_KEY)

      return if alreadyStarted
      localStorage.setItem(ALREADY_STARTED_KEY, true)

    @api.startPoll 'hackathon-winner',
      title: 'Проголосуйте за участников хакатона'
      options: _.map(contenders, (c) -> { label: c, color: '#f1c40f'})

    @api.$pollState.onValue (pollData) =>
      @cloudPoll.updateData(pollData)

  stopPoll: ->
    return unless @pollActive
    @pollActive = false
    @api.stopPoll()

  showPollResults: ->
    # not yet implemented!

    # return unless @pollData?
    # winner = _.max @pollData, (d) -> d.count
    # $('section.poll-results').attr('data-background', winner.color)
    # $('.winner-name').text(winner.label)
    # Reveal.sync()

  onSlideChanged: (slideName) ->
    switch slideName
      when 'cloud-poll'
        do @startPoll
      when 'poll-results'
        do @showPollResults
      when 'contacts'
        do @finishPresentation

