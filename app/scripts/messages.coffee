module.exports = class Message

  MESSAGES_CONTAINER_CLASS = '.messages-container'
  TEMPLATE_CONTAINER_ID = '#message'
  MESSAGE_HEADER = 'Новый вопрос'
  MAX_MESSAGES = 4
  MESSAGE_DURATION = 25000

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
          # console.log msgForRemove.length
          itemForShow = @messagesBuffer.pop()
          f = (iter) =>
            _.delay((=> @showMessage(itemForShow)), Number(iter) * 600)
          f(i)
          # console.log 'UNBUFFERIZE', itemForShow ,@messagesBuffer

    setInterval checkMessages, 500
    
  removeMessages: (messagesForRemove) =>
    for message in messagesForRemove
      message.$msg.addClass('message-out')
      # setTimeout (-> $msg.remove()), 1000
      # _.delay(=> @showMessage(itemForShow), 1000)
      f = (mess) ->
        _.delay((-> mess.$msg.remove()), 700)
      f(message)

      # _.delay(=> @showMessage(itemForShow), Number(iter) * 600)
      # message.$msg.delay(2000).remove()

    @messages = _.difference @messages, messagesForRemove

  messages: []
  messagesBuffer: []

  showMessage: (content) ->
    if(@messages.length >= MAX_MESSAGES)
      @messagesBuffer.push(content)
      # console.log 'BUFFERIZE', @messagesBuffer
    else
      timeAdd = moment(Date.now())
      $msg = $(@templateFunc({message : content, header: MESSAGE_HEADER}))
      @messages.unshift( {$msg: $msg, timeAdd: timeAdd} )
      $(MESSAGES_CONTAINER_CLASS).append($msg)
      setTimeout (-> $msg.addClass('message-in')), 10
