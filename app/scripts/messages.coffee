module.exports = class Message

  MESSAGES_CONTAINER_CLASS = '.messages-container'
  TEMPLATE_CONTAINER_ID = '#message'
  MESSAGE_HEADER = 'Новый вопрос'

  constructor: (@api) ->
    # ...

  showMessage: (content) ->
    templateString = $(TEMPLATE_CONTAINER_ID).html()
    templateFunc = _.template(templateString)

    $(MESSAGES_CONTAINER_CLASS).append(templateFunc({message : content, header: MESSAGE_HEADER}))