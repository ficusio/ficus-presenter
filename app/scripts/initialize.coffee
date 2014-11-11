require './utils/bacon-helpers'
require './participants'

API          = require './server-api'
Feynman      = require './feynman'
Messages     = require './messages'
Presentation = require './presentation'
Participants = require './participants'

###
# Полная инициализация
###
$ ->
  window.api = new API '/api'

  api.$initialState.onValue (initialState) ->
    window.feynman      = new Feynman(api)
    window.messages     = new Messages(api)
    window.presentation = new Presentation(api)
    window.participants = new Participants(api, '.participants-container', initialState)

    do api.startPresentation


