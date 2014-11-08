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


