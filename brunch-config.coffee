exports.config =
  files:
    javascripts:
      joinTo:
        'javascripts/app-presenter.js': /^app/
        'javascripts/vendor-presenter.js': /^(?!app)/

    stylesheets:
      joinTo: 'stylesheets/app-presenter.css'

    templates:
      joinTo: 'javascripts/app-presenter.js'

  plugins:
    jaded:
      jade:
        pretty: yes
