module.exports = class Message

  MESSAGES_CONTAINER_CLASS = '.messages-container'
  TEMPLATE_CONTAINER_ID = '#message'
  MESSAGE_HEADER = 'Новый вопрос'
  MAX_MESSAGES = 5
  MESSAGE_DURATION = 20000

  constructor: (@api) ->
    templateString = $(TEMPLATE_CONTAINER_ID).html()
    @templateFunc = _.template(templateString)
    @api.$audienceMessages.onValue (data) =>
      @showMessage(data.message)

    checkMessages = () =>
      msgForRemove = []
      currentTime = moment Date.now()
      for message in @messages
        diff = moment.duration(currentTime.diff(message.timeAdd))
        diffInMs = diff._milliseconds
        
        if (diffInMs > MESSAGE_DURATION)
          msgForRemove.push message

      @removeMessages(msgForRemove)
      
      for i in _.range(msgForRemove.length)
        if @messagesBuffer.length > 0
          itemForShow = @messagesBuffer.pop()
          defferedShowMsg = (iter) =>
            _.delay((=> @showMessage(itemForShow)), Number(iter) * 1500)
          defferedShowMsg(i)

    setInterval checkMessages, 500
    
  removeMessages: (messagesForRemove) =>
    for message in messagesForRemove
      message.$msg.addClass('message-out')

      performDeleteMsg = (mess) ->
        removeFromDom = ->
          h = mess.$msg.height()
          mess.$msg.height(h)
          mess.$msg.removeClass('message')
          mess.$msg.empty()
          slideToggleMsg = () ->
            mess.$msg.slideToggle( "slow", ->
              mess.$msg.remove()
            )
          setTimeout slideToggleMsg, 10
          
        _.delay(removeFromDom, 700)

      performDeleteMsg(message)

    @messages = _.difference @messages, messagesForRemove

  messages: []
  messagesBuffer: []

  showMessage: (content) ->
    if(@messages.length >= MAX_MESSAGES)
      @messagesBuffer.push(content)
    else
      timeAdd = moment(Date.now())
      $msg = $(@templateFunc({message : content, header: MESSAGE_HEADER}))
      @messages.unshift( {$msg: $msg, timeAdd: timeAdd} )
      $(MESSAGES_CONTAINER_CLASS).append($msg)
      setTimeout (-> $msg.addClass('message-in')), 10
