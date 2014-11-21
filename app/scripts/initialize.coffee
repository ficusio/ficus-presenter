PDFJS.workerSrc = '/pdf.worker.js'

require './utils/bacon-helpers'


API          = require './server-api-mock'
Feynman      = require './feynman'
Messages     = require './messages'
Presentation = require './presentation'
Participants = require './participants'
PDFViewer    = require './pdf-viewer'


api = new API '/api'


api.$initialState.onValue (initialState) -> $ ->
  feynman      = new Feynman api
  messages     = new Messages api
  pdfjs        = new PDFViewer $('.pdf-presentation')
  presentation = new Presentation api, pdfjs
  participants = new Participants api, '.participants-container', initialState

  api.startPresentation()

  $poll = $('.naming-poll')
  $result = $('.poll-results')

  resize = ->
    viewportHeight = $(window).height()
    pdfjs.setMaxHeight viewportHeight
    
    zoom = viewportHeight / 850

    $poll.css 'zoom', zoom
    $poll.css '-moz-transform', "scale(#{zoom})"
    $poll.css '-o-transform', "scale(#{zoom})"

    $result.css 'zoom', zoom
    $result.css '-moz-transform', "scale(#{zoom})"
    $result.css '-o-transform', "scale(#{zoom})"
    

  $(window).on "resize", _.debounce(resize, 200)

  document.onkeydown = (evt) ->
    evt = evt or window.event
    switch evt.keyCode
      when 37
        pdfjs.prevPage()
      when 39
        pdfjs.nextPage()

  do resize
  pdfjs.load '/test.pdf'
