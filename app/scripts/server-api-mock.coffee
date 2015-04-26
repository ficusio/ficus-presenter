
module.exports = class API

  @PresentationState:
    NOT_STARTED: 'not_started'
    ACTIVE: 'active'
    ENDED: 'ended'

  PresentationState: API.PresentationState


  constructor: (apiEndpoint) ->
    console.debug "new API #{ apiEndpoint }"
    @_ = new APIImpl apiEndpoint
    @$initialState = @_.$initialState.toProp()
    @$listenerCount = @_.$listenerCount.toProp()
    @$audienceMood = @_.$audienceMood.toProp()
    @$audienceMessages = @_.$audienceMessages
    @$pollState = @_.$pollState.toProp()


  startPresentation: ->
    console.debug 'api.startPresentation'
    @_.startPresentation()
    undefined


  setSlideId: (id) ->
    console.debug "api.setSlideId '#{ id }'"
    @_.setSlideId id
    id


  startPoll: (id, poll) ->
    console.debug "api.startPoll '#{ id }', #{ JSON.stringify poll, null, '  ' }"
    @_.startPoll id, poll
    id


  stopPoll: ->
    console.debug 'api.stopPoll'
    @_.stopPoll()
    undefined


  finishPresentation: ->
    console.debug 'api.finishPresentation'
    @_.finishPresentation()
    undefined


####################################################################################################

class APIImpl

  constructor: (@apiEndpoint) ->

    @initialState = if Math.random() < 0.5
      state: API.PresentationState.NOT_STARTED
      listenerCount: 1
    else
      state: API.PresentationState.ACTIVE
      listenerCount: 25
      slide: '2'
      audienceMood: 2 * Math.random() - 1

    @state = @initialState.state
    @$initialState = Bacon.later 100, @initialState

    @$initialState.onValue (initialState) =>
      if initialState.state isnt API.PresentationState.NOT_STARTED
        @initEvents()

    @$listenerCount = new Bacon.Bus
    @$audienceMood = new Bacon.Bus
    @$pollState = new Bacon.Bus
    @$audienceMessages = new Bacon.Bus

    @$listenerCount.plug @$initialState.map('.listenerCount').skipNulls()
    @$audienceMood.plug @$initialState.map('.audienceMood').skipNulls()
    @$pollState.plug @$initialState.map('.pollState').skipNulls()

    @slide = undefined


  startPresentation: ->
    if @state isnt API.PresentationState.NOT_STARTED
      return console.warn 'presentation has been already started'
    @state = API.PresentationState.ACTIVE
    @initEvents()
    undefined


  initEvents: ->
    @$listenerCountSrc = randomStream 500, 3000, @initialState.listenerCount, randomizeListenerCount
    @$audienceMoodSrc = randomStream 100, 200, @initialState.audienceMood, randomizeMood
    @$audienceMessagesSrc = randomStream 1000, 20000, null, randomMessage
    noPoll = => not @pollId?
    @$listenerCount.plug @$listenerCountSrc
    @$audienceMood.plug @$audienceMoodSrc.filter noPoll
    @$audienceMessages.plug @$audienceMessagesSrc


  setSlideId: (id) ->
    @slide = id


  startPoll: (id, poll) ->
    if @pollId? then @stopPoll()
    @pollId = id
    @poll = poll
    pollState = pollStateFromPoll poll
    @$pollStateSrc = randomStream 200, 800, pollState, randomizePollState
    @$pollState.plug Bacon.later(0, pollState).concat @$pollStateSrc
    undefined


  stopPoll: ->
    unless @pollId?
      return console.warn 'no active poll to stop'
    @pollId = @poll = undefined
    @$pollStateSrc.end()
    @$pollState.push undefined
    undefined


  finishPresentation: ->
    unless @state is API.PresentationState.ACTIVE
      return console.warn 'presentation is not started'
    if @pollId? then @stopPoll()
    @$listenerCountSrc.end()
    @$audienceMoodSrc.end()
    @$audienceMessagesSrc.end()
    @state = API.PresentationState.ENDED


  randomizeListenerCount = (prevCount) ->
    minD = if prevCount < 30 then 0 else -10
    maxD = 15
    Math.min 142, prevCount + Math.floor minD + (maxD - minD) * Math.random()


  randomizeMood = (prevMood) ->
    if Math.random() > 0.97
      (if Math.random() > 0.5 then 1 else -1) * (0.2 + 0.8 * Math.random())
    else if Math.abs(prevMood) > 0.01
      prevMood / 1.1
    else 0


  pollStateFromPoll = (poll) ->
    _.map poll.options, (opt) ->
      { label: opt.label, color: opt.color, count: 0, weight: 0 }


  randomizePollState = (prevPollState) ->
    newTotal = 0
    luckyIndices = _.sample([0...prevPollState.length], 3)

    newPollState = _.map prevPollState, (opt, i) ->
      count = opt.count
      ++count if i in luckyIndices
      { count, label: opt.label, color: opt.color }

    _.each newPollState, (opt) ->
      if newTotal != 0
        opt.weight = opt.count / newTotal
      else
        opt.weight = 0


  randomMessage = do ->
    messages = [
      { type: 'twitter', userId: 'epshenichniy', message: 'бобры пожрут планету' }
      { type: 'inapp', userId: '1', message: 'кто здесь?' }
      { type: 'inapp', userId: '2', message: 'уруру уруру' }
      { type: 'inapp', userId: '3', message: 'Cookies are a contract between a browser and an
                                 http server, and are identified by a domain name. If a browser
                                 has a cookie set for particular domain, it will pass it as a part
                                 of all http requests to the host.' }
      { type: 'twitter', userId: 'ururu', message: 'greetings from Urugvai!' }
    ]
    -> messages[ Math.floor messages.length * Math.random() ]


  randomStream = (minIntv, maxIntv, initialValue, valueRandomizer) ->
    $bus = new Bacon.Bus
    lastValue = initialValue
    timeoutId = undefined
    schedule = ->
      timeout = Math.floor minIntv + (maxIntv - minIntv) * Math.random()
      timeoutId = setTimeout next, timeout
    next = ->
      $bus.push lastValue = valueRandomizer lastValue
      schedule()
    $result = $bus.skipDuplicates()
    $result.end = ->
      if timeoutId? then clearTimeout timeoutId
      $bus.end()
    schedule()
    $result
