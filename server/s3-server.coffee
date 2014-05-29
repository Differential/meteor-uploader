Knox = Npm.require "knox"
Future = Npm.require "fibers/future"
StreamBuffers = Npm.require "stream-buffers"

Meteor.methods
  S3upload: (options) ->
    s3config = s3Config.getConfig()
    knox = Knox.createClient s3config
    file = options.file

    file_stream_buffer = new StreamBuffers.ReadableStreamBuffer
      frequency: 10      # in miliseconds
      chunkSize: 2048    # in bytes.

    future = new Future()

    path = (s3config.directory or "") + Meteor.userId() + '/' + file.name

    buffer = new Buffer file.data
    file_stream_buffer.put buffer
    headers =
      "Content-Type": file.type
      "Content-Length": buffer.length

    put = knox.putStream file_stream_buffer, path, headers, (error, response) ->
      if response
        future.return path
      if error
        throw new Meteor.Error 500, "An error occured transferring #{file.originalName}"

    put.on "progress", Meteor.bindEnvironment (progress) ->
      ev = name: options.name, progress: progress.percent
      s3UploaderStream.emit Meteor.userId(), ev

    put.on "error", Meteor.bindEnvironment (error) ->
      throw new Meteor.Error 500, "An error occured transferring #{file.originalName}"

    knox.http future.wait()


  S3delete: (url) ->
    s3config = s3Config.getConfig()
    knox = Knox.createClient s3config
    path = url.split(".com/")[1]

    knox.deleteFile path, (error, response) ->
      if error
        throw new Meteor.Error 500, "An error occured deleting your file"


  S3list: (prefix) ->
    s3config = s3Config.getConfig()
    knox = Knox.createClient(s3config)
    future = new Future()

    knox.list prefix: prefix, (error, response) ->
      if error
        throw new Meteor.Error 500, "An error occured getting your files"
      if response
        future.return response
    future.wait()
