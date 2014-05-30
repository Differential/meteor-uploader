@s3UploaderStream = new Meteor.Stream "s3Uploader"

if Meteor.isServer
  s3UploaderStream.permissions.write (eventName) ->
    false

  s3UploaderStream.permissions.read (eventName) ->
    eventName is @userId

if Meteor.isClient
  s3UploaderStream.on Meteor.userId(), (msg) ->
    Session.set "uploader-progress-#{msg.name}", msg.progress
