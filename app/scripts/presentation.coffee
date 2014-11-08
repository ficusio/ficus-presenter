module.exports = class Presentation
  constructor: (@api) ->
    Reveal.initialize
      controls: false
      progress: false
      history: false
      center: true
      transition: 'fade'
      dependencies: []

    # Reveal.addEventListener 'slidechanged', (event) ->
    #   console.log event.currentSlide

# ###
# # Использование опросника
# ###
# PollChart = require './poll-chart'
# chart = new PollChart('#poll')

# hipsterColors = [
#   '#1abc9c', '#9b59b6', '#e74c3c'
#   '#f1c40f', '#95a5a6', '#16a085'
# ]

# hipsters = [
#   'Пшеничный', 'Адимов', 'Белоусько',
#   'Суздалев', 'Тактаров', 'Козин'
# ]

# l = 4
# data = _.map [0...l], (x,i) ->
#   color: hipsterColors[i]
#   label: hipsters[i]
#   weight: 0
#   count:  0

# (update = ->
#   data[_.random(0, l-1)].count += 1

#   sum = d3.sum data, (d) -> d.count
#   _.each data, (d) ->
#     x = 0
#     if sum isnt 0
#       x = d.count / sum
#     d.weight = x

#   chart.updateData(data)
#   setTimeout update, _.random(60, 300)
# )()