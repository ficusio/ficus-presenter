require './utils'
require './participants'

API          = require './api'
Feynman      = require './feynman'
Messages     = require './messages'
Presentation = require './presentation'
Participants = require './participants'

###
# Полная инициализация
###
$ ->
  window.api          = new API '/api', 'test1'
  window.feynman      = new Feynman(api)
  window.messages     = new Messages(api)
  window.presentation = new Presentation(api)
  window.participants = new Participants(api, '.participants-container')

  init = (initialState) ->
    # stringify = (obj) -> JSON.stringify obj, null, '  '
    # console.log 'initialState:', stringify(initialState)


    # api.$listenerCount.log '$listenerCount'
    # api.$audienceMood.log '$audienceMood'
    # api.$audienceMessages.map(stringify).log '$audienceMessages'
    # api.$pollState.map(stringify).log '$pollState'

    api.startPresentation 1
  #   setTimeout simulatePoll, 5000

  # simulatePoll = ->
  #   api.startPoll 1,
  #     title: 'Test poll'
  #     options: [
  #         label: 'Opt 1'
  #         color: '#ff0000'
  #       ,
  #         label: 'Opt 2'
  #         color: '#00ff00'
  #       ,
  #         label: 'Opt 3'
  #         color: '#0000ff'
  #     ]
  #   setTimeout ( -> api.stopPoll() ), 15000

  api.$initialState.onValue init


