
module.exports = class API

  @PresentationState:
    NOT_STARTED: 'notStarted'
    ACTIVE: 'active'
    ENDED: 'ended'

  PresentationState: API.PresentationState


  constructor: (apiEndpoint) ->
    console.debug "new API #{ apiEndpoint }"
    @_ = new APIImpl apiEndpoint
    @$initialState = @_.$initialState.toProp()
    @$listenerCount = @_.$listenerCount.toProp()
    @$audienceMood = @_.$audienceMood.toProp()
    @$pollState = @_.$pollState.toProp()


  startPresentation: (id = 'dummy_id') ->
    console.debug "api.startPresentation '#{ id }'"
    @_.startPresentation id
    id


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
    @$initialState = Bacon.later 100,
      state: API.PresentationState.NOT_STARTED
      listenerCount: 5

    @$listenerCount = new Bacon.Bus
    @$audienceMood = new Bacon.Bus
    @$pollState = new Bacon.Bus

    @$listenerCount.plug @$initialState.map('.listenerCount').skipNulls()
    @$audienceMood.plug @$initialState.map('.audienceMood').skipNulls()
    @$pollState.plug @$initialState.map('.pollState').skipNulls()

    @slide = undefined


  startPresentation: (@presentationId) ->
    @$listenerCountSrc = randomStream 500, 3000, 5, randomizeListenerCount
    @$audienceMoodSrc = randomStream 100, 200, 0, randomizeMood
    noPoll = => not @pollId?
    @$listenerCount.plug @$listenerCountSrc
    @$audienceMood.plug @$audienceMoodSrc.filter noPoll
    undefined


  setSlideId: (id) ->
    @slide = id


  startPoll: (id, poll) ->
    if @pollId? then @stopPoll()
    @pollId = id
    @poll = poll
    pollState = pollStateFromPoll poll
    @$pollStateSrc = randomStream 500, 1000, pollState, randomizePollState
    @$pollState.plug Bacon.later(0, pollState).concat @$pollStateSrc
    undefined


  stopPoll: ->
    unless @pollId? then return console.warn 'no active poll to stop'
    @pollId = @poll = undefined
    @$pollStateSrc.end()
    @$pollState.push undefined
    undefined


  finishPresentation: ->
    unless @presentationId? then return console.warn 'presentation is not started'
    @$listenerCountSrc.end()
    @$audienceMoodSrc.end()
    if @pollId? then @stopPoll()
    @presentationId = undefined


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
    newPollState = _.map prevPollState, (opt) ->
      count = opt.count
      rand = Math.random()
      if rand > 0.95
        count = Math.max 0, count - 1
      else if rand > 0.5
        count += 1 + Math.floor 3 * Math.random()
      newTotal += count
      { count, label: opt.label, color: opt.color }
    if newTotal == 0
      idx = Math.floor newPollState.length * Math.random()
      newPollState[ idx ].count += (newTotal = 1)
    _.each newPollState, (opt) -> opt.weight = opt.count / newTotal


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
