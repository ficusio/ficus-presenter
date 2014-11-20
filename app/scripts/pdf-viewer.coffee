console.log PDFJS 
module.exports = class PDFView

    constructor: (@$el) ->
      @ready = no
      @canvas = ($el.find 'canvas')[0]
      @ctx = @canvas.getContext '2d'

    setMaxHeight: (@maxHeight) -> 
      @$el.height maxHeight
      if @pdfDoc
        @pdfDoc.getPage(@pageNum).then @_renderPage

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

      viewport = page.getViewport scale
      @canvas.width = viewport.width
      @canvas.height = viewport.height

      page.render
        canvasContext: @ctx
        viewport: viewport