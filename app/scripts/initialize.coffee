PDFJS.workerSrc = 'http://localhost:3333/pdf.worker.js'

require './utils/bacon-helpers'


API          = require './server-api'
Feynman      = require './feynman'
Messages     = require './messages'
Presentation = require './presentation'
Participants = require './participants'
PDFViewer    = require './pdf-viewer'


api = new API '/api'


api.$initialState.onValue (initialState) -> $ ->
  feynman      = new Feynman api
  messages     = new Messages api
  presentation = new Presentation api
  participants = new Participants api, '.participants-container', initialState

  api.startPresentation()

  pdfjs = new PDFViewer($('.pdf-presentation'))

  pageNum = 1
  pdfjs.setMaxHeight $(window).height()
  pdfjs.load 'http://localhost:3333/test.pdf'

  resize = ->
    viewportHeight = $(window).height()
    pdfjs.setMaxHeight viewportHeight

  $(window).on "resize", _.debounce(resize, 200)

  onPrevPage = ->
    return  if pageNum <= 1
    pageNum--
    pdfjs.displayPage pageNum

  onNextPage = ->
    return  if pageNum >= 30
    pageNum++
    pdfjs.displayPage pageNum

  document.onkeydown = (evt) ->
    evt = evt or window.event
    switch evt.keyCode
      when 37
        onPrevPage()
      when 39
        onNextPage()
