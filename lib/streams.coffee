@uploaderStream = new Meteor.Stream "uploaderStream"

if Meteor.isServer
  uploaderStream.permissions.write (eventName) ->
    false

  uploaderStream.permissions.read (eventName) ->
    eventName is @userId

if Meteor.isClient
  uploaderStream.on Meteor.userId(), (msg) ->
    Session.set "uploader-progress-#{msg.name}", msg.progress
