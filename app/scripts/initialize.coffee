require './utils'
require './participants'

API          = require './api'
Feynman      = require './feynman'
Messages     = require './messages'
Presentation = require './presentation'

###
# Полная инициализация
###
$ ->
  window.api          = new API '/api', 'test1'
  window.feynman      = new Feynman(api)
  window.messages     = new Messages(api)
  window.presentation = new Presentation(api)

  stringify = (obj) -> JSON.stringify obj, null, '  '

  init = (initialState) ->
    console.log 'initialState:', stringify(initialState)

    api.$listenerCount.log '$listenerCount'
    api.$audienceMood.log '$audienceMood'
    api.$audienceMessages.map(stringify).log '$audienceMessages'
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


