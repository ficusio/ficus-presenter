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

  api.$initialState.onValue (initialState) ->
    api.startPresentation 1


