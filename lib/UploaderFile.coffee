class @UploaderFile

  CHUNK_SIZE: 1024 * 1024 * 0.5

  @fromJSONValue: (value) ->
    new UploaderFile
      id: value.id
      name: value.name
      ext: value.ext
      type: value.type
      size: value.size
      data: EJSON.fromJSONValue value.data
      start: value.start
      end: value.end
      bytesRead: value.bytesRead
      bytesUploaded: value.bytesUploaded
    ,
      value.settings


  constructor: (doc = {}, settings={}) ->
    @id = doc.id or Random.id()
    @name = doc.name or null
    @type = doc.type or null
    @data = doc.data or null
    @size = doc.size or 0
    @start = doc.start or 0
    @end = doc.end or 0
    @bytesRead = doc.bytesRead or 0
    @bytesUploaded = doc.bytesUploaded or 0
    @ext = @name?.match(/\.[0-9a-z]{1,5}$/i)
    @settings = settings

  typeName: ->
    "UploaderFile"

  equals: (id) ->
    @id = other.id

  clone: ->
    new UploaderFile
      id: @id
      name: @name
      type: @type
      size: @size
      data: @data
      start: @start
      end: @end
      bytesRead: @bytesRead
      bytesUploaded: @bytesUploaded
    ,
      @settings

  toJSONValue: ->
    id: @id
    name: @name
    type: @type
    size: @size
    data: EJSON.toJSONValue @data
    start: @start
    end: @end
    bytesRead: @bytesRead
    bytesUploaded: @bytesUploaded
    settings: @settings

  getDocument: ->
    UploadedFiles.findOne _id: @id

  getTotalProgress: ->
    file = @getDocument()
    uploadProgress = file.uploadProgress or 0
    cloudUploadProgress = file.cloudUploadProgress or 0
    uploadProgress/2 + cloudUploadProgress/2



EJSON.addType "UploaderFile", UploaderFile.fromJSONValue

#
# Client
#
if Meteor.isClient

  UploaderFile.upload = (uploaderId, file, settings={}) ->
    new UploaderFile({}, settings).upload uploaderId, file


  UploaderFile::rewind = ->
    @data = null
    @start = 0
    @end = 0
    @bytesRead = 0
    @bytesUploaded = 0

  UploaderFile::_updateStatus = ->
    readProgress = Math.round @bytesRead/@size * 100
    uploadProgress = Math.round @bytesUploaded/@size * 100

    UploadedFiles.update _id: @id,
      $set: readProgress: readProgress, uploadProgress: uploadProgress

  UploaderFile::upload = (uploaderId, file) ->
    @name = file.name
    @size = file.size
    @type = file.type

    UploadedFiles.insert
      _id: @id
      name: @name
      type: @type
      size: @size
      uploaderId: uploaderId
      readProgress: 0
      uploadProgress: 0
      cloudUploadProgress: 0

    @read file
    return @

  # Recursively read and transmit the file
  UploaderFile::read = (file) ->
    if @bytesUploaded < @size
      @start = @end
      @end += @CHUNK_SIZE

      if @end > @size
        @end = @size

      reader = new FileReader
      reader.onload = =>
        @bytesRead += @end - @start
        @data = new Uint8Array reader.result
        Meteor.call "uploadChunk", @, (error, result) =>
          if error
            @rewind()
            @_updateStatus()
            throw error
          else
            @bytesUploaded += @data.length
            @_updateStatus()
            @read file

      blob = file.slice @start, @end
      reader.readAsArrayBuffer blob
    else
      @_updateStatus()


#
# Server
#
if Meteor.isServer
  fs = Npm.require "fs"
  path = Npm.require "path"
  Knox = Npm.require "knox"

  UploaderFile::_updateStatus = (progress) ->
    UploadedFiles.update _id: @id,
      $set: cloudUploadProgress: progress.percent

  UploaderFile::_updateCloudUrl = (url) ->
    UploadedFiles.update _id: @id,
      $set: url: url

  UploaderFile::_setError = (error) ->
    UploadedFiles.update _id: @id,
      $set: error: error

  UploaderFile::save = (dirPath) ->
    filePath = path.resolve path.join "", "#{@id}#{@ext}"
    buffer = new Buffer @data
    mode = if @start is 0 then 'w' else 'a'
    fd = fs.openSync filePath, mode
    fs.writeSync fd, buffer, 0, buffer.length, @start
    fs.closeSync fd

    if @end is @size
      @upload filePath

  UploaderFile::upload = (filePath) ->
    config = Uploader.getConfig()
    knox = Knox.createClient config

    cloudPath = "#{@id}#{@ext}"
    if @settings.directory?
      cloudPath = @settings.directory.replace(/\/?$/, '/').concat cloudPath

    put = knox.putFile filePath, cloudPath, Meteor.bindEnvironment (error, response) =>
      fs.unlinkSync filePath
      if response
        @_updateCloudUrl knox.http(cloudPath)
      if error
        @_setError new Meteor.Error 500, "An error occured transferring #{@name}"

    put.on "progress", Meteor.bindEnvironment (progress) =>
      @_updateStatus progress

    put.on "error", Meteor.bindEnvironment (error) =>
      @_setError new Meteor.Error 500, "An error occured transferring #{@name}"
      fs.unlinkSync filePath
