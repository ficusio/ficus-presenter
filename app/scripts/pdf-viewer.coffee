
CSS_UNITS = 96.0 / 72.0

module.exports = class PDFView

    constructor: (@$el) ->
      @ready = no
      @canvas = ($el.find 'canvas')[0]
      @ctx = @canvas.getContext '2d'
      
      @_$innerSlide = new Bacon.Bus
      @$slide = @_$innerSlide.toProp(1)

    setMaxHeight: (@maxHeight) -> 
      @$el.height maxHeight
      if @pdfDoc
        @pdfDoc.getPage(@pageNum).then @_renderPage

    nextPage: ->
      return if @pageNum >= @pdfDoc.numPages
      @displayPage @pageNum + 1

    prevPage: ->
      return if @pageNum <= 1
      @displayPage @pageNum - 1

    load: (@url) ->
      console.log 'load'
      PDFJS.getDocument(url).then @_onPDFReady

    _onPDFReady: (@pdfDoc) =>
      console.log 'ready'
      @ready = yes
      @displayPage 1 unless @pageNum?

    displayPage: (pageNum) ->
      console.log 'displayPage', pageNum
      return if @pageNum is pageNum
      @pageNum = pageNum
      return unless @ready
      @pdfDoc.getPage(pageNum).then @_renderPage

    _renderPage: (page) =>
      console.log "displaying page", page

      scaleY = @maxHeight / page.view[3]
      scaleX = @$el.width() / page.view[2]
      scale = Math.min scaleX, scaleY

      console.log 'pdf-view scaleX:', scaleX, 'scaleY:', scaleY, 'scale:', scale

      $('canvas').css 'zoom', '0.5'
      viewport = page.getViewport scale * 2
      @canvas.width = viewport.width 
      @canvas.height = viewport.height

      page.render
        canvasContext: @ctx
        viewport: viewport

      @_$innerSlide.push @pageNum