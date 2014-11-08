
require './utils'
API = require './api'


initAPI = ->
  api = new API '/api'
  window.api = api # TODO: tmp

  stringify = (obj) -> JSON.stringify obj, null, '  '

  init = (initialState) ->
    console.log 'initialState:', stringify(initialState)

    api.$listenerCount.log '$listenerCount'
    api.$audienceMood.log '$audienceMood'
    api.$pollState.map(stringify).log '$pollState'

    api.startPresentation 1
    setTimeout simulatePoll, 5000

  simulatePoll = ->
    api.startPoll 1,
      title: 'Test poll'
      options: [
          label: 'Opt 1'
          color: '#ff0000'
        ,
          label: 'Opt 2'
          color: '#00ff00'
        ,
          label: 'Opt 3'
          color: '#0000ff'
      ]
    setTimeout ( -> api.stopPoll() ), 15000

  api.$initialState.onValue init


initAPI()


$ ->
  Reveal.initialize
    controls: false
    progress: false
    history: true
    center: true
    transition: 'fade'
    dependencies: []


  Feynman = require './speed-indicator'
  window.feynman = new Feynman({})

  Messages = require './messages'
  window.messages = new Messages({})


