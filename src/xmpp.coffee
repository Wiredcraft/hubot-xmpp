{Adapter,Robot,TextMessage,EnterMessage,LeaveMessage} = require 'hubot'

url     = require 'url'
util    = require 'util'
request = require 'request'
Xmpp    = require 'node-xmpp'

#
DefaultAvatarId = 'd1e79e85731e6319b9859bef4607ef2c5dab16bc'
DefaultAvatarContent = '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'


#
_notify = (robot, status) ->
  jid = process.env.HUBOT_XMPP_USERNAME
  org = process.env.HUBOT_ORG_NAME
  notifyUrl = process.env.HUBOT_NOTIFY_URL
  username = process.env.API_AUTH_USERNAME
  password = process.env.API_AUTH_PASSWORD
  now = Date.now()

  #
  if (jid and org and notifyUrl and username and password)
    urlObj = url.parse(notifyUrl)
    robot.logger.info util.inspect(urlObj)

    parameters = "#{urlObj.pathname}?org=#{org}&status=#{status}&timestamp=#{now}&jid=#{jid}"
    auth = "Basic " + new Buffer(username + ":" + password).toString("base64");

    robot.logger.info "Going to notify api status"
    robot.logger.info "Status: #{status}"
    robot.logger.info "Org: #{org}"
    robot.logger.info "Jid: #{jid}"
    robot.logger.info "Api username: #{username}"
    robot.logger.info "Api password: #{password}"
    robot.logger.info "Parameters: #{parameters}"
    robot.logger.info "Auth: #{auth}"

    request.get notifyUrl, {qs:
                                org: org
                                jid: jid
                                status: status
                                timestamp: now
                            headers:
                                Authorization: auth
                            strictSSL: false
                            }, (err) ->
                                robot.logger.error err.toString() if err

class XmppBot extends Adapter
  run: ->
    options =
      username: process.env.HUBOT_XMPP_USERNAME
      password: '********'
      host: process.env.HUBOT_XMPP_HOST
      port: process.env.HUBOT_XMPP_PORT
      rooms:    @parseRooms process.env.HUBOT_XMPP_ROOMS.split(',')
      keepaliveInterval: 30000 # ms interval to send whitespace to xmpp server
      legacySSL: process.env.HUBOT_XMPP_LEGACYSSL
      preferredSaslMechanism: process.env.HUBOT_XMPP_PREFERRED_SASL_MECHANISM

    @robot.logger.info util.inspect(options)
    options.password = process.env.HUBOT_XMPP_PASSWORD

    @client = new Xmpp.Client
      reconnect: true
      jid: options.username
      password: options.password
      host: options.host
      port: options.port
      legacySSL: options.legacySSL
      preferredSaslMechanism: options.preferredSaslMechanism

    @client.on 'error', @.error
    @client.on 'online', @.online
    @client.on 'stanza', @.read
    @client.on 'offline', @.offline

    @options = options
    @connected = false

  error: (error) =>
    if error.code == "ECONNREFUSED"
      @robot.logger.error "Connection refused, exiting"
      setTimeout () ->
        process.exit(1)
      , 1500
    else if error.children?[0]?.name == "system-shutdown"
      @robot.logger.error "Server shutdown detected, exiting"
      setTimeout () ->
        process.exit(1)
      , 1500
    else
      @robot.logger.error error.toString()
      console.log util.inspect(error.children?[0]?.name, { showHidden: true, depth: 1 })

  online: =>
    @robot.logger.info 'Hubot XMPP client online'
    @notify 'online'

    avatarId = process.env.HUBOT_AVATAR_ID || DefaultAvatarId
    el = new Xmpp.Element('presence', from: @client.jid)
    el.c('x', xmlns:'vcard-temp:x:update').c('photo').t(avatarId)

    @robot.logger.info "Hubot presence xml #{el}"

    #
    @robot.logger.info 'Hubot XMPP publish avatar'
    @publishAvatar()

    @robot.logger.info 'Hubot XMPP sent initial presence'
    @client.send el

    @joinRoom room for room in @options.rooms
    @unlockRoom room for room in @options.rooms

    # send raw whitespace for keepalive
    @keepaliveInterval = setInterval =>
      @client.send ' '
    , @options.keepaliveInterval

    @emit if @connected then 'reconnected' else 'connected'
    @connected = true

  publishAvatar: =>
      avatarId = process.env.HUBOT_AVATAR_ID || DefaultAvatarId
      avatarContent = process.env.HUBOT_AVATAR_CONTENT || DefaultAvatarContent

      vCard = """
      <BDAY>1970-01-01</BDAY>
      <ADR>
      <CTRY>Italy</CTRY>
      <LOCALITY>Verona</LOCALITY>
      <HOME/>
      </ADR>
      <NICKNAME/>
      <N><GIVEN>Juliet</GIVEN><FAMILY>Capulet</FAMILY></N>
      <EMAIL>#{@client.jid}</EMAIL>
      <PHOTO>
        <TYPE>image/png</TYPE>
        <BINVAL>
          #{avatarContent}
        </BINVAL>
      </PHOTO>
      """

      @robot.logger.info "Hubot avatar id #{avatarId}"
      @robot.logger.info "Hubot avatar content #{avatarContent}"

      @client.send do =>
        el = new Xmpp.Element('iq', from: @client.jid, id:'vc1', type: 'set')

        x = el.c('vCard', xmlns: 'vcard-temp')
              .t(vCard)

        @robot.logger.info "Hubot avatar xml element #{x}"

        return x

  publishAvatarMetadata: =>
      avatarId = process.env.HUBOT_AVATAR_ID || DefaultAvatarId

      @robot.logger.info "Hubot avatar id #{avatarId}"

      @client.send do =>
        el = new Xmpp.Element('iq', from: @client.jid, id:'avatar2', type: 'set')

        x = el.c('pubsub', xmlns: 'http://jabber.org/protocol/pubsub')
              .c('publish', node: 'urn:xmpp:avatar:metadata')
              .c('item', id: avatarId)
              .c('metadata', xmlns: 'urn:xmpp:avatar:metadata')
              .c('info', width:"64", height:"64", type:"image/png", bytes:4724, id:avatarId)

        @robot.logger.info "Hubot avatar xml element #{x}"

        return x

  notify: (status) =>
    @robot.logger.info "Notify to #{process.env.HUBOT_NOTIFY_URL} status #{status}"

    _notify @robot, status

  # Direct inviation - http://xmpp.org/extensions/xep-0249.html
  directlyInvite: (invitor, invitee, room, reason='') ->
    @robot.logger.info "Directly invite user #{invitee} to room #{room}"

    @client.send do =>
        message = new Xmpp.Element('message', from: invitor, to: invitee)
                          .c('x', xmlns: 'jabber:x:conference', jid: room, reason: reason)

        return message

  # Mediated invitation - http://xmpp.org/extensions/xep-0045.html#invite
  mediatedInvite: (invitee, room, reason='') ->
    @robot.logger.info "Mediately invite user #{invitee} to room #{room}"

    @client.send do =>
      message = new Xmpp.Element('message', to: room)
                        .c('x', xmlns: 'http://jabber.org/protocol/muc#user')
                        .c('invite', to: invitee)
                        .c('reason').t(reason)
      return message

  parseRooms: (items) ->
    rooms = []
    for room in items
      index = room.indexOf(':')
      rooms.push
        jid:      room.slice(0, if index > 0 then index else room.length)
        password: if index > 0 then room.slice(index+1) else false
    return rooms

  # XMPP kick a occupant froma room - http://xmpp.org/extensions/xep-0045.html#kick
  kickOccupant: (jid, room, reason='') ->
    @robot.logger.info "Kicking occupant #{jid} from room #{room}"

    @client.send do =>
      el = new Xmpp.Element('iq', from: @client.jid, id:'kick1', to: room, type: 'set')

      x = el.c('query', xmlns:'http://jabber.org/protocol/muc#admin')
            .c('item', jid:jid, role:'none')
            .c('reason').t(reason)

      return x

  # XMPP destroy an instant room - http://xmpp.org/extensions/xep-0045.html#destroyroom
  destroyRoom: (room, reason='') ->
    @robot.logger.info "Going to destroy room #{room}"

    @client.send do =>
      el = new Xmpp.Element('iq',to: room, type: "set", id: "destroy1")

      x = el.c('query', xmlns:'http://jabber.org/protocol/muc#owner')
            .c('destroy', jid: room)
            .c('reason').t(reason)

      return x

  # XMPP unlock an instant room - http://xmpp.org/extensions/xep-0045.html#createroom-instant
  unlockRoom: (room) ->
    @robot.logger.info "Unlock room #{room.jid}"

    @client.send do =>
      el = new Xmpp.Element('iq', to: room.jid, type: 'set', id: 'create1')

      x = el.c('query', xmlns: 'http://jabber.org/protocol/muc#owner')
            .c('x', xmlns:'jabber:x:data', type:'submit')

      return x

  # XMPP Joining a room - http://xmpp.org/extensions/xep-0045.html#enter-muc
  joinRoom: (room) ->
    @client.send do =>
      @robot.logger.debug "Joining #{room.jid}/#{@robot.name}"

      el = new Xmpp.Element('presence', to: "#{room.jid}/#{@robot.name}" )
      x = el.c('x', xmlns: 'http://jabber.org/protocol/muc' )
      x.c('history', seconds: 1 ) # prevent the server from confusing us with old messages
                                  # and it seems that servers don't reliably support maxchars
                                  # or zero values
      if (room.password) then x.c('password').t(room.password)
      return x

  # XMPP Leaving a room - http://xmpp.org/extensions/xep-0045.html#exit
  leaveRoom: (room) ->
    @client.send do =>
      @robot.logger.debug "Leaving #{room.jid}/#{@robot.name}"

      return new Xmpp.Element('presence', to: "#{room.jid}/#{@robot.name}", type: 'unavailable' )

  read: (stanza) =>
    if stanza.attrs.type is 'error'
      @robot.logger.error '[xmpp error]' + stanza
      return

    switch stanza.name
      when 'message'
        @readMessage stanza
      when 'presence'
        @readPresence stanza
      when 'iq'
        @readIq stanza

  readIq: (stanza) =>
    @robot.logger.debug "[received iq] #{stanza}"

    # Some servers use iq pings to make sure the client is still functional.  We need
    # to reply or we'll get kicked out of rooms we've joined.
    if (stanza.attrs.type == 'get' && stanza.children[0].name == 'ping')
      pong = new Xmpp.Element('iq',
        to: stanza.attrs.from
        from: stanza.attrs.to
        type: 'result'
        id: stanza.attrs.id
      )

      @robot.logger.debug "[sending pong] #{pong}"
      @client.send pong

  readMessage: (stanza) =>
    # ignore non-messages
    return if stanza.attrs.type not in ['groupchat', 'direct', 'chat']

    # ignore empty bodies (i.e., topic changes -- maybe watch these someday)
    body = stanza.getChild 'body'
    return unless body

    message = body.getText()
    [room, from] = stanza.attrs.from.split '/'
    @robot.logger.debug "Received message: #{message} in room: #{room}, from: #{from}"

    # ignore our own messages in rooms
    return if from == @robot.name or from == @options.username or from is undefined

    # note that 'from' isn't a full JID, just the local user part
    user = @robot.brain.userForId from
    user.type = stanza.attrs.type
    user.room = room

    @receive new TextMessage(user, message)

  readPresence: (stanza) =>
    jid = new Xmpp.JID(stanza.attrs.from)
    bareJid = jid.bare().toString()

    # xmpp doesn't add types for standard available mesages
    # note that upon joining a room, server will send available
    # presences for all members
    # http://xmpp.org/rfcs/rfc3921.html#rfc.section.2.2.1
    stanza.attrs.type ?= 'available'

    # Parse a stanza and figure out where it came from.
    getFrom = (stanza) =>
      if bareJid not in @options.rooms
        from = stanza.attrs.from
      else
        # room presence is stupid, and optional for some anonymous rooms
        # http://xmpp.org/extensions/xep-0045.html#enter-nonanon
        from = stanza.getChild('x', 'http://jabber.org/protocol/muc#user')?.getChild('item')?.attrs?.jid
      return from

    switch stanza.attrs.type
      when 'subscribe'
        @robot.logger.debug "#{stanza.attrs.from} subscribed to me"

        @client.send new Xmpp.Element('presence',
            from: stanza.attrs.to
            to:   stanza.attrs.from
            id:   stanza.attrs.id
            type: 'subscribed'
        )
      when 'probe'
        @robot.logger.debug "#{stanza.attrs.from} probed me"

        @client.send new Xmpp.Element('presence',
            from: stanza.attrs.to
            to:   stanza.attrs.from
            id:   stanza.attrs.id
        )
      when 'available'
        # for now, user IDs and user names are the same. we don't
        # use full JIDs as user ID, since we don't get them in
        # standard groupchat messages
        from = getFrom(stanza)
        return if not from?

        [room, from] = from.split '/'

        # ignore presence messages that sometimes get broadcast
        return if not @messageFromRoom room

        # If the presence is from us, track that.
        # Xmpp sends presence for every person in a room, when join it
        # Only after we've heard our own presence should we respond to
        # presence messages.
        if from == @robot.name or from == @options.username
          @heardOwnPresence = true
          return

        return unless @heardOwnPresence

        @robot.logger.debug "Availability received for #{from}"

        user = @robot.brain.userForId from, room: room, jid: jid.toString()
        @receive new EnterMessage user

      when 'unavailable'
        from = getFrom(stanza)

        [room, from] = from.split '/'

        # ignore presence messages that sometimes get broadcast
        return if not @messageFromRoom room

        # ignore our own messages in rooms
        return if from == @robot.name or from == @options.username

        @robot.logger.debug "Unavailability received for #{from}"

        user = @robot.brain.userForId from, room: room, jid: jid.toString()
        @receive new LeaveMessage(user)

  # Checks that the room parameter is a room the bot is in.
  messageFromRoom: (room) ->
    for joined in @options.rooms
      return true if joined.jid == room
    return false

  send: (envelope, messages...) ->
    for msg in messages
      @robot.logger.debug "Sending to #{envelope.room}: #{msg}"

      params =
        to: if envelope.user?.type in ['direct', 'chat'] then "#{envelope.room}/#{envelope.user.id}" else envelope.room
        type: envelope.user?.type or 'groupchat'

      if msg.attrs? # Xmpp.Element type
        message = msg.root()
        message.attrs.to ?= params.to
        message.attrs.type ?= params.type
      else
        message = new Xmpp.Element('message', params).
                  c('body').t(msg)

      @client.send message

  reply: (envelope, messages...) ->
    for msg in messages
      if msg.attrs? #Xmpp.Element
        @send envelope, msg
      else
        @send envelope, "#{envelope.user.name}: #{msg}"

  topic: (envelope, strings...) ->
    string = strings.join "\n"

    message = new Xmpp.Element('message',
                to: envelope.room
                type: envelope.user.type
              ).
              c('subject').t(string)

    @client.send message

  offline: =>
    @robot.logger.debug "Received offline event"
    clearInterval(@keepaliveInterval)

    @notify 'offline'

exports.use = (robot) ->
  new XmppBot robot
