Knox = Npm.require "knox"
Future = Npm.require "fibers/future"
StreamBuffers = Npm.require "stream-buffers"

Meteor.methods

  # @param {Object} [options] Uploader button's data context - passed from user
  # @param {String} [options.name] Name of uploader instance - user defined
  # @param {Object} [options.file] Single file data
  # @param {String} [options.file.name] New name of file - Meteor UUID
  # @param {String} [options.file.originalName] Original file name on users machine
  # @param {Int}    [options.file.size] File size
  # @param {String} [options.file.type] File type
  # @param {Object} [options.file.data] File data
  uploaderUpload: (options) ->
    config = Uploader.getConfig()
    knox = Knox.createClient config
    file = options.file

    file_stream_buffer = new StreamBuffers.ReadableStreamBuffer
      frequency: 10      # in miliseconds
      chunkSize: 2048    # in bytes.

    future = new Future()

    path = (config.directory or "") + Meteor.userId() + '/' + file.name

    buffer = new Buffer file.data
    file_stream_buffer.put buffer
    headers =
      "Content-Type": file.type
      "Content-Length": buffer.length
      "x-amz-acl": config.acl

    # Pipe file buffer to cloud
    put = knox.putStream file_stream_buffer, path, headers, (error, response) ->
      if response
        future.return path
      if error
        throw new Meteor.Error 500, "An error occured transferring #{file.originalName}"

    put.on "progress", Meteor.bindEnvironment (progress) ->
      ev = name: options.name, progress: progress.percent
      uploaderStream.emit Meteor.userId(), ev

    put.on "error", Meteor.bindEnvironment (error) ->
      throw new Meteor.Error 500, "An error occured transferring #{file.originalName}"

    # Return url to file
    url: knox.http future.wait()
    fileName: file.name
    originalFileName: options.file.originalName
    uploaderName: options.name


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
