
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


###
# Инициализация презентации
###
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

  ###
  # Использование опросника
  ###
  PollChart = require './poll-chart'
  chart = new PollChart('#poll')

  hipsterColors = [
    '#1abc9c', '#9b59b6', '#e74c3c'
    '#f1c40f', '#95a5a6', '#16a085'
  ]

  hipsters = [
    'Пшеничный', 'Адимов', 'Белоусько',
    'Суздалев', 'Тактаров', 'Козин'
  ]

  l = 4
  data = _.map [0...l], (x,i) ->
    color: hipsterColors[i]
    label: hipsters[i]
    weight: 0
    count:  0

  (update = ->
    data[_.random(0, l-1)].count += 1

    sum = d3.sum data, (d) -> d.count
    _.each data, (d) ->
      x = 0
      if sum isnt 0
        x = d.count / sum
      d.weight = x

    chart.updateData(data)
    setTimeout update, _.random(60, 300)
  )()


