plurals = require './utils/plurals'

safeFraction = (a, b) ->
  return 0.0 if b is 0
  a / b


NAME_WIDTH    = 200
BARS_MARGIN   = 32
BAR_MIN_VALUE = 0.05

BALLS_ANIM_DURATION    = 1000
REORDER_ANIM_DURATION  = 500
BAR_GROW_ANIM_DURATION = 500


# ---
# Голосование
# ---
module.exports = class CloudPoll
  constructor: (@el) ->
    @$el = $(@el)
    @data = []

  getWinners: ->

    topVotes = _.chain(@data)
      .map((d) -> d.count)
      .uniq()
      .filter (d) -> d != 0
      .sortBy((d) -> -d)
      .first(3)
      .value()

    winners = _.chain(@data)
      .filter (d) ->
        d.count in topVotes
      .sort (d) ->
        -d.count
      .value()

    winners

  # ---
  # Формирует строку с количеством проголосовавших
  # ---
  pollTotalText: (total) ->
    peopleInflection =
      'one':   'человек проголосовал'
      'few':   'человекa проголосовали'
      'many':  'человек проголосовали'
      'other': 'человек проголосовали'

    peopleInflection[ plurals.ru(total) ]

  # ---
  # Темплейт для строки голосования
  # ---
  entryTemplate: (data) ->
    """
      <div class="name">#{data.label}</div>
      <div class="votes"></div>
      <div class="votes-count">#{data.count}</div>
    """

  # ---
  # Фильтриует только изменившиеся строки
  # ---
  diffVotes: (prevData, data) ->
    _.filter data, (elem) ->
      oldElem = _.find prevData, (d) -> d.label == elem.label

      return (elem.count != 0) unless oldElem
      (oldElem.count isnt elem.count) and (elem.count != 0)


  # ---
  # Высчитывает верхнюю границу для значений голосовалки
  # ---
  calcBoundary: (max) ->
    10 * Math.ceil(max / 10)

  # ---
  # Перерисовка
  # ---
  updateData: (data) ->
    contendersHeight = @$el.find('.contenders').height()
    contendersWidth  = @$el.find('.contenders').width()

    barMaxWidth = contendersWidth - NAME_WIDTH - 20

    # получаем новые данные, смотрим, кто поменялся
    data =  _.sortBy(data, (d) -> -d.count)
    votes = @diffVotes( @data, data)
    @data = data

    ballsEnter = d3.select(@el)
      .select('.balls-container')
      .selectAll('.ball')
      .data(votes, (d) ->
        d.label + d.count)
      .enter()
      .append('div')
      .attr('class', 'ball')

    ballsEnter
      .transition()
      .duration(BALLS_ANIM_DURATION)
      .delay (d, i) -> 100*i
      .attrTween 'style', (d, i) ->
        (t) ->
          a = $('.balls-container').offset()
          b = $("[data-label=\"#{d.label}\"] .votes-count").offset()

          x = (b.left - a.left - 55)  * d3.ease('cubic', 'out')(t)
          y = (b.top  - a.top  - 10)  * t

          CP_1   = 0.2
          CP_2   = 0.015

          scale   = 1.0
          opacity = 1.0

          if t >= 0 and t <= CP_1
            opacity = (t / CP_1)
            scale = opacity

          if t >= (1.0 - CP_2) and t <= 1.0
            opacity = 1 - ((t - (1.0 - CP_2)) / CP_2)
            scale = 1.0

          transform = "translate3d(#{x}px, #{y}px, 0px) scale(#{scale}, #{scale})"
          """
            opacity: #{opacity};
            transform: #{transform};
            -webkit-transform: #{transform};
          """
      .remove()

    root  = d3.select(@el).select('.contenders')
    total = Math.round(d3.sum(data, (d) -> d.count) / 3)
    max   = @calcBoundary(d3.max(data, (d) -> d.count))

    summary = d3.select(@el)
      .select('.already-voted')
      .datum(total)

    number = summary.select('.number')

    number
      .classed 'flash-animation', (d) ->
        d != 0
      .text (c) -> c

    # Плохо!
    setTimeout =>
      number.classed('flash-animation': false)
    , 300


    summary.select('.label')
      .text(@pollTotalText)

    entry = root
      .selectAll('.entry')
      .data(@data, (d) -> d.label)

    # Entry bootstrap
    entryEnter = entry.enter()
      .append('div')
      .attr('class', 'entry')
      .attr('data-label', (d) -> d.label)
      .html(@entryTemplate)

    entry.exit().remove()

    positionFunc = (d,i) ->
      fullHeight = BARS_MARGIN * (data.length+1)

      y = 0.5*contendersHeight - 0.5*fullHeight + BARS_MARGIN * i
      "#{y}px"

    entryEnter
      .style 'top', positionFunc

    entry.select('.votes')
      .transition()
      .delay(BALLS_ANIM_DURATION)
      .duration(BAR_GROW_ANIM_DURATION)
      .style 'width', (d) =>
        x = safeFraction(d.count, max)
        bmin = BAR_MIN_VALUE * barMaxWidth
        w = bmin + (barMaxWidth - bmin) * x
        "#{w.toFixed(0)}px"

    entry
      .transition()
      .duration(REORDER_ANIM_DURATION)
      .delay(BALLS_ANIM_DURATION + BAR_GROW_ANIM_DURATION)
      .style 'top', positionFunc

    setTimeout =>
      entry.classed 'leader', (d, i) ->
        true
    , (BALLS_ANIM_DURATION + BAR_GROW_ANIM_DURATION + REORDER_ANIM_DURATION)

    entry.select('.votes-count')
      .transition()
      .delay(BALLS_ANIM_DURATION)
      .text((d) -> d.count)



