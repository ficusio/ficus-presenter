CHART_DEFAULT_WIDTH   = 800.0
CHART_DEFAULT_HEIGHT  = 600.0

# Мы за безопасный секс
safeFraction = (a, b) ->
  return 0.0 if b is 0
  a / b

module.exports = class PollChart
  ###
  # Параметры
  ###
  labelsColor: '#000000'
  labelsFont:  'ProximaNova'
  labelsSize:  '28px'

  # Отступы между столбиками и подписями
  labelsHeight:  80
  labelsPadding: 10

  # Отступы между столиками
  barOuterPad:  0.1
  barPad:       0.05
  barAnimationDuration: 200
  barMinValue:  0.01

  sexyRatio: 0.7

  ###
  # Конструктор
  ###
  constructor: (@element, @width=CHART_DEFAULT_WIDTH, @height=CHART_DEFAULT_HEIGHT) ->
    @svg = d3.select(@element).append('svg')
      .attr('width',  @width)
      .attr('height', @height)

    @barsHeight = @height - @labelsHeight

    # Группа с барами
    @svg.append('g')
      .attr('class', 'bars')
      .attr('transform', =>
        "scale(1.0, -1.0) translate(0 -#{@barsHeight})")

    # Группа с подписями
    @svg.append('g')
      .attr('class', 'labels')
      .attr('transform', "translate(0 #{@barsHeight + @labelsPadding})")

  ###
  # Обновляет данные для отрисовки
  # TODO: не работает при изменении количества элементов в опросе!
  ###
  updateData: (pollData) ->
    dataLength = pollData.length

    max = d3.max pollData, (d) -> d.weight

    scaleX = d3.scale.ordinal()
      .domain([0...dataLength])
      .rangeRoundBands([0, @width], @barPad, @barOuterPad)

    @svg.select('g.bars')
      .selectAll('rect')
      .data(pollData)
      .enter().append('rect')
      .attr('x', (d, i) -> scaleX(i) )
      .attr('width', scaleX.rangeBand())

    @svg.select('g.bars')
      .selectAll('rect')
      .attr('fill', (d) -> d.color)
      .transition()
        .ease('linear')
        .duration(@barAnimationDuration)
        .attr('height', (d) =>
          x = @sexyRatio * safeFraction(d.weight, max)
          bmin = @barMinValue * @height
          bmin + (@height - bmin) * x)
        .attr('y', (d) => 0)

    @svg.select('g.labels')
      .selectAll('text')
      .data(pollData)
      .enter().append('text')
      .attr('y', 0)
      .attr('x', (d, i) ->
        scaleX(i) + 0.5 * scaleX.rangeBand(i))
      .attr('alignment-baseline', 'text-before-edge')
      .attr('text-anchor', 'middle')
      .attr('font-family', @labelsFont)
      .attr('font-size',   @labelsSize)
      .attr('fill', @labelsColor)
      .text (d) -> d.label

  destroy: ->
    @svg.remove()

    # ай-ай-ай!
    @isDestroyed = true


