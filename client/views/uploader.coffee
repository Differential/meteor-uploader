clickHandler = (event, tpl) ->
  event.preventDefault()
  $(tpl.find(".file-upload")).click()

dataURLToBlob = (dataUrl) ->
  binaryImg = window.atob(dataUrl.slice(dataUrl.indexOf("base64") + 7, dataUrl.length))
  length = binaryImg.length
  ab = new ArrayBuffer length
  ua = new Uint8Array ab
  i = 0
  while i < length
    ua[i] = binaryImg.charCodeAt(i)
    i++
  new Blob([ua])

getFile = (id) ->
  files = @stateManager.get "files"
  file = _.findWhere files, id: id

getFileDocument = (id) ->
  file = getFile.call @, id
  if file? then file.getDocument()

removeFile = (id) ->
  files = @stateManager.get "files"
  files = _.reject files, (file) -> file.id is id
  @stateManager.set "files", files

addFile = (file) ->
  files = @stateManager.get "files"
  files.push file
  @stateManager.set "files", files

progress = ->
  tpl = UI._templateInstance()
  files = tpl.stateManager.get "files"
  total = _.reduce files, (memo, val) ->
    memo += val.getTotalProgress()
  , 0
  Math.round (total / _.size(files)*100 / 100)

reset = ->
  @stateManager.set "files", []

watchFilesCollection = ->
  Meteor.subscribe "uploadedFiles", @uploaderId
  UploadedFiles.find().observeChanges
    changed: (id, fields) =>
      if fields.url?
        file = getFileDocument.call @, id
        if file?
          @data.settings.onUpload? null, file

        if _.every(@stateManager.get("files"), (file) -> file.getDocument()?.url)
          reset.call @

      if fields.error?
        err = fields.error
        file = getFileDocument.call @, id
        if file?
          removeFile.call @, id
          @data.settings.onUpload? new Meteor.Error(err.error, err.reason), file


Template.uploader.created = ->
  @uploaderId = Random.id()
  @stateManager = new UploaderState @uploaderId
  reset.call @
  watchFilesCollection.call @

  # @autorun =>
  #   if progress() is 100
  #     Meteor.setTimeout =>
  #       reset.call @
  #     , 2000


Template.uploader.helpers
  progress: progress

  complete: ->
    progress() is 100

  filesSelected: ->
    tpl = UI._templateInstance()
    tpl.stateManager.get "files"

Template.uploader.events
  # Upload button
  "click button": (event, tpl) ->
    clickHandler event, tpl

  # Or anchor
  "click a": (event, tpl) ->
    clickHandler event, tpl

  # After file(s) have been chosen
  "change input[type=file]": (event, tpl) ->
    settings = tpl.data.settings
    files = event.currentTarget.files

    if settings.onSelection?
      settings.onSelection files

    _.each files, (file) =>
      if settings.manipulateImage? and file.type.match(/image.*/)?
        reader = new FileReader
        reader.onload = =>
          settings.manipulateImage reader.result, file, (dataUrl) =>
            blob = dataURLToBlob dataUrl
            blob.name = file.name
            uFile = UploaderFile.upload tpl.uploaderId, blob, settings
            addFile.call tpl, uFile
        reader.readAsDataURL file
      else
        uFile = UploaderFile.upload tpl.uploaderId, file, settings
        addFile.call tpl, uFile
