
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
    @$slide = @_.$slide.skipDuplicates().toProp()
    @$listenerCount = @_.$listenerCount.skipDuplicates().toProp()
    @$audienceMessages = @_.$audienceMessages
    @$questionLikes = @_.$questionLikes.skipNulls()
    @$pollState = @_.$pollState.toProp()
    @$discussingQuestion = @_.$discussingQuestion.skipDuplicates().toProp()
    @traceEvents()


  traceEvents: ->
    @$initialState.onValue (v) -> console.log 'api ~> initialState:', v
    @$slide.onValue (v) -> console.log 'api ~> slide:', v
    @$listenerCount.onValue (v) -> console.log 'api ~> listenerCount:', v
    @$audienceMessages.onValue (v) -> console.log 'api ~> audienceMessages:', v
    @$discussingQuestion.onValue (v) -> console.log 'api ~> discussingQuestion:', v
    @$questionLikes.onValue (v) -> console.log 'api ~> questionLikes:', v
    @$pollState.onValue (v) -> console.log 'api ~> pollState:', v


  startPresentation: ->
    console.debug 'api.startPresentation'
    @_.startPresentation()
    undefined


  setSlideId: (id) ->
    console.debug "api.setSlideId '#{ id }'"
    @_.setSlideId id
    undefined


  startPoll: (id, poll) ->
    console.debug "api.startPoll '#{ id }', #{ JSON.stringify poll, null, '  ' }"
    @_.startPoll id, poll
    undefined


  stopPoll: ->
    console.debug 'api.stopPoll'
    @_.stopPoll()
    undefined


  startDiscussingQuestion: (id) ->
    console.debug "api.startDiscussingQuestion '#{ id }'"
    @_.startDiscussingQuestion id
    undefined


  stopDiscussingQuestion: ->
    console.debug "api.stopDiscussingQuestion"
    @_.stopDiscussingQuestion()
    undefined


  hideQuestion: (id) ->
    console.debug "api.hideQuestion '#{ id }'"
    @_.hideQuestion id
    undefined


  finishPresentation: ->
    console.debug 'api.finishPresentation'
    @_.finishPresentation()
    undefined


####################################################################################################

class APIImpl

  constructor: ->
    msg = messageWithTextAndLikes 'где я?', 32

    initialState = randomElem [{
      state: API.PresentationState.NOT_STARTED
      slide: undefined
      listenerCount: undefined
      questions: undefined
      discussingQuestion: undefined
      pollState: undefined
    }, {
      state: API.PresentationState.ACTIVE
      slide: '2-0'
      listenerCount: 25
      questions: []
      discussingQuestion: undefined
      pollState: undefined
    }, {
      state: API.PresentationState.ACTIVE
      slide: '0-0'
      listenerCount: 17
      questions: [ msg, messageWithTextAndLikes('who is that guy in front of the screen?', 1) ]
      discussingQuestion: msg
      pollState: undefined
    }]

    @state = initialState.state
    @$initialState = withRandomDelay initialState

    @$slide = new Bacon.Bus
    @$listenerCount = new Bacon.Bus
    @$audienceMessages = new Bacon.Bus
    @$discussingQuestion = new Bacon.Bus
    @$questionLikes = new Bacon.Bus
    @$pollState = new Bacon.Bus

    @messagesById = {}
    @messages = []
    @knownSlides = []

    @$audienceMessages.onValue (msg) =>
      @addNewMessage msg

    @$discussingQuestion.onValue (q) =>
      @discussingQuestionId = q?.id || undefined

    @$initialState.onValue (initialState) =>
      if initialState.questions?.length
        @addNewMessage(msg) for msg in initialState.questions
      if initialState.state isnt API.PresentationState.NOT_STARTED
        @initEvents initialState


  startPresentation: ->
    if @state isnt API.PresentationState.NOT_STARTED
      return console.error 'presentation is already started'
    @state = API.PresentationState.ACTIVE
    @initEvents
      state: @state
      slide: '0-0'
      listenerCount: 1
      questions: []
      discussingQuestion: undefined


  initEvents: (currentState) ->
    @$slide.plug @$slideSrc = randomStream @$slide,
      minDelay: 3000
      maxDelay: 20000
      randomizer: (v) => @randomizeSlide v

    @$listenerCount.plug @$listenerCountSrc = randomStream @$listenerCount,
      minDelay: 2000
      maxDelay: 10000
      randomizer: randomizeListenerCount

    @$audienceMessages.plug @$audienceMessagesSrc = randomStream @$audienceMessages,
      minDelay: 1000
      maxDelay: 20000
      randomizer: randomMessage
      induceWith: yes

    @$discussingQuestion.plug @$discussingQuestionSrc = randomStream @$discussingQuestion,
      minDelay: 5000
      maxDelay: 20000
      randomizer: (v) => @randomizeDiscussingQuestion v

    @$questionLikes.plug @$questionLikesSrc = randomStream @$questionLikes,
      minDelay: 500
      maxDelay: 3000
      randomizer: (v) => @randomizeQuestionLikes v
      induceWith: yes

    @$listenerCount.push currentState.listenerCount
    @$slide.push currentState.slide
    @$discussingQuestion.push currentState.discussingQuestion


  finishPresentation: ->
    unless @assertStarted() then return
    @$slideSrc.end()
    @$listenerCountSrc.end()
    @$audienceMessagesSrc.end()
    @discussingQuestionId = undefined
    @$discussingQuestionSrc.end()
    @$questionLikesSrc.end()
    @poll = undefined
    @$pollStateSrc?.end()
    @state = API.PresentationState.ENDED


  setSlideId: (id) ->
    unless @assertStarted() then return
    @knownSlides.push id
    @$slide.plug withRandomDelay id


  startPoll: (id, poll) ->
    unless @assertStarted() then return
    if @poll
      return console.error 'another poll is still active'
    @poll = poll
    @poll.id = id
    @$pollState.plug @$pollStateSrc = randomStream @$pollState,
      minDelay: 500
      maxDelay: 1000
      randomizer: randomizePollState
    @$pollState.plug withRandomDelay pollStateFromPoll poll


  stopPoll: ->
    unless @assertStarted() then return
    unless @poll
      return console.error 'no active poll to stop'
    @poll = undefined
    @$pollStateSrc.end()
    @$pollState.plug withRandomDelay undefined


  addNewMessage: (msg) ->
    @messagesById[msg.id] = msg
    @messages.push msg


  startDiscussingQuestion: (id) ->
    unless @assertStarted() then return
    unless @messagesById[id]
      return console.error "no question with id '#{ id }'"
    @discussingQuestionId = id
    @$discussingQuestion.plug withRandomDelay @messagesById[id]


  stopDiscussingQuestion: ->
    unless @assertStarted() then return
    unless @discussingQuestionId?
      return console.error 'no currently discussing question'
    console.log '  questionId: ' + @discussingQuestionId
    @discussingQuestionId = undefined
    @$discussingQuestion.plug withRandomDelay undefined


  hideQuestion: (id) ->
    unless @assertStarted() then return
    unless @messagesById[id]
      return console.error "no question with id '#{ id }'"
    @messagesById[id].hidden = yes


  assertStarted: ->
    unless @state is API.PresentationState.ACTIVE
      console.error 'presentation is not started'
      return false
    true


  randomizeListenerCount = (prevCount) ->
    minD = if prevCount < 30 then 0 else -10
    maxD = 15
    Math.min 142, prevCount + randomInt(minD, maxD)


  randomizeSlide: (prevSlide) ->
    if @knownSlides.length
      randomElem @knownSlides
    else
      prevSlide


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
        count += randomInt 0, 3
      newTotal += count
      { count, label: opt.label, color: opt.color }
    if newTotal == 0
      randomElem(newPollState).count += 1
      newTotal = 1
    _.each newPollState, (opt) -> opt.weight = opt.count / newTotal


  randomMessage = ->
    text = randomElem [
      'бобры пожрут планету?'
      'кто здесь?'
      'уруру уруру?'
      'Are cookies a contract between a browser and an http server? How they are identified?'
      'greetings from what?!'
    ]
    messageWithTextAndLikes text, 0


  messageWithTextAndLikes = (text, likes) ->
    msg =
      text: text
      type: randomElem [ 'twitter', 'inapp' ]
      id: randomId()
      likes: likes
    msg.userId = if msg.type is 'inapp'
      randomId()
    else
      randomElem [ 'epshenichniy', 'ururu', 'whoami', 'pwd' ]
    msg


  randomizeDiscussingQuestion: (discussingQuestion) ->
    if discussingQuestion
      Bacon.later randomInt(3000, 6000), undefined
    else if @messages.length > 0
      randomElem @messages
    else
      Bacon.later 1000, undefined


  randomizeQuestionLikes: ->
    unless @messages.length
      return undefined
    msg = randomElem @messages
    msg.likes += if msg.likes is 0
      randomInt 1, 3
    else if Math.random() > 0.8
      Math.max -msg.likes, randomInt(-3, -1)
    else
      randomInt 1, 2
    {
      id: msg.id
      likes: msg.likes
    }


  randomStream = ($src, { minDelay, maxDelay, randomizer, induceWith }) ->
    $inducer = $src.toEventStream()
    if induceWith isnt undefined
      $inducer = $inducer.merge withRandomDelay induceWith
    $ender = new Bacon.Bus
    $result = $inducer.flatMapLatest (v) ->
      newValue = randomizer v
      if newValue instanceof Bacon.Observable
        return newValue
      timeout = randomInt minDelay, maxDelay
      Bacon.later timeout, newValue
    .takeUntil $ender
    $result.end = ->
      $ender.push yes
      $inducer = $result = $ender = undefined
    $result


  withRandomDelay = (value) ->
    delay = randomInt 10, 200
    Bacon.later delay, value


  randomId = ->
    [1..10]
    .map -> '0123456789abcdef'.charAt randomInt 0, 15
    .join ''


  randomInt = (min, max) ->
    Math.floor min + (max - min + 1) * Math.random()


  randomElem = (arr) ->
    arr[ Math.floor arr.length * Math.random() ]
