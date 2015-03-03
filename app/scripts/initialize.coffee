require './utils/bacon-helpers'


API          = require './server-api'
Messages     = require './messages'
Presentation = require './presentation'
Participants = require './participants'


api = new API '/api'


api.$initialState.onValue (initialState) -> $ ->
  messages     = new Messages api
  presentation = new Presentation api
  participants = new Participants api, '.participants-container', initialState

  api.startPresentation()
