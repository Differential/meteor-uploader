Knox = Npm.require "knox"
Future = Npm.require "fibers/future"
# StreamBuffers = Npm.require "stream-buffers"

Meteor.methods

  uploadChunk: (uFile) ->
    uFile.save()


  # Delete file from cloud
  uploaderDelete: (url) ->
    config = Uploader.getConfig()
    knox = Knox.createClient config
    path = url.split(".com/")[1]
    future = new Future()

    knox.deleteFile path, (error, response) ->
      if error
        throw new Meteor.Error 500, "An error occured deleting your file"
      if response
        future.return path
    future.wait()


  # List files that begin with @prefix
  uploaderList: (prefix) ->
    config = Uploader.getConfig()
    knox = Knox.createClient(config)
    future = new Future()

    knox.list prefix: prefix, (error, response) ->
      if error
        throw new Meteor.Error 500, "An error occured getting your files"
      if response
        future.return response
    future.wait()
