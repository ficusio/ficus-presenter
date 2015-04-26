plurals = require './utils/plurals'

safeFraction = (a, b) ->
  return 0.0 if b is 0
  a / b


NAME_WIDTH  = 200
BARS_MARGIN = 32
BAR_MIN_VALUE = 0.05

# ---
# Голосование
# ---
module.exports = class CloudPoll
  constructor: (@el) ->
    @$el = $(@el)

  pollTotalText: (total) ->
    peopleInflection =
      'one':   'человек проголосовал'
      'few':   'человекa проголосовали'
      'many':  'человек проголосовали'
      'other': 'человек проголосовали'

    peopleInflection[ plurals.ru(total) ]

  entryTemplate: (data) ->
    """
      <div class="name">#{data.label}</div>
      <div class="votes"></div>
      <div class="votes-count">#{data.count}</div>
    """


  calcBoundary: (max) ->
    10 * Math.ceil(max / 10)

  updateData: (data) ->
    barMaxWidth = @$el.find('.contenders').width() - NAME_WIDTH - 20

    @data = _.sortBy(data, (d) -> -d.count)

    root  = d3.select(@el).select('.contenders')
    total = Math.round(d3.sum(data, (d) -> d.count) / 3)
    max   = @calcBoundary(d3.max(data, (d) -> d.count))

    summary = d3.select(@el)
      .select('.already-voted')
      .datum(total)

    number = summary.select('.number')

    number
      .classed(flash: true)
      .text (c) -> c

    # Плохо!
    setTimeout =>
      number.classed(flash: false)
    , 300

    summary.select('.label')
      .text(@pollTotalText)

    entry = root
      .selectAll('.entry')
      .data(@data, (d) -> d.label)

    entry.enter()
      .append('div')
      .attr('class', 'entry')
      .html(@entryTemplate)

    entry.exit().remove()

    entry
      .transition()
      .duration(500)
      .style 'top', (d, i) ->
        y = BARS_MARGIN * i
        "#{y}px"

    entry.select('.votes-count')
      .transition()
      .delay(0)
      .text (d) -> d.count

    entry.select('.votes')
      .transition()
      .delay(500)
      .duration(1000)
      .style 'width', (d) =>
        x = safeFraction(d.count, max)
        bmin = BAR_MIN_VALUE * barMaxWidth
        w = bmin + (barMaxWidth - bmin) * x
        "#{w.toFixed(0)}px"



