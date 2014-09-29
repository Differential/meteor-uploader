#
#  GLOBAL TEMPLATE HELPERS
#
UI.registerHelper "queueSize", ->
  Session.get "uploader-queueSize-#{@settings.name}"

UI.registerHelper "multipleQueue", ->
  Session.get "uploader-queueSize-#{@settings.name}" > 1

UI.registerHelper "queueExists", ->
  queueSize = Session.get "uploader-queueSize-#{@settings.name}"
  queueSize? and queueSize > 0

UI.registerHelper "progress", ->
  Session.get "uploader-progress-#{@settings.name}"

UI.registerHelper "progressExists", ->
  progress = Session.get "uploader-progress-#{@settings.name}"
  progress? and progress > 0

UI.registerHelper "error", ->
  Session.get "uploader-error-#{@settings.name}"

UI.registerHelper "currentlyUploading", ->
    completed = Session.get "uploader-completed-#{@settings.name}"
    ++completed

UI.registerHelper "complete", ->
  queueSize = Session.get "uploader-queueSize-#{@settings.name}"
  completed = Session.get "uploader-completed-#{@settings.name}"
  completed is queueSize


resetState = (context) ->
  Session.set "uploader-progress-#{context.data.settings.name}", 0
  Session.set "uploader-queueSize-#{context.data.settings.name}", 0
  Session.set "uploader-completed-#{context.data.settings.name}", 0

clickHandler = (event, tpl) ->
  event.preventDefault()
  $(tpl.find(".file-upload")).click()

dataURLToUA = (dataUrl) ->
  binaryImg = window.atob(dataUrl.slice(dataUrl.indexOf("base64") + 7, dataUrl.length))
  length = binaryImg.length
  ab = new ArrayBuffer length
  ua = new Uint8Array ab
  i = 0
  while i < length
    ua[i] = binaryImg.charCodeAt(i)
    i++
  ua


uploadFile = (settings, fileData) ->
  settings.file = fileData

  if settings.directUpload
    return new UploaderS3DirectUpload(settings)

  Meteor.call "uploaderUpload", settings, (error, result) ->
    # Display error
    if error then Session.set "uploader-error-#{settings.name}", error.reason

    # Increment completed count no matter what happens here
    completed = Session.get "uploader-completed-#{settings.name}"
    Session.set "uploader-completed-#{settings.name}", ++completed

    # Pass results to user defined callback
    if settings.onUpload
      settings.onUpload(error, result)


# Watches queue and completed to determine when to reset
completionWatch = null

Template.uploader.created = ->
  # Clear the slate
  resetState @

  # Set up watch on session vars
  completionWatch = Deps.autorun =>
    queueSize = Session.get "uploader-queueSize-#{@data.settings.name}"
    completed = Session.get "uploader-completed-#{@data.settings.name}"

    # Have we completed the queue
    if completed? and completed > 0 and completed is queueSize
      # Reset file picker
      $(".file-upload").val null
      resetState @

Template.uploader.destroyed = ->
  # Stop the computation if we leave
  if completionWatch then completionWatch.stop()

Template.uploader.events
  # After file(s) have been chosen
  "change input[type=file]": (event, tpl) ->
    settings = tpl.data.settings
    files = event.currentTarget.files
    Session.set "uploader-queueSize-#{settings.name}", files.length

    if settings.onSelection?
      settings.onSelection(files)

    _.each files, (file) ->
      extension = (file.name).match(/\.[0-9a-z]{1,5}$/i)

      fileData =
        originalName: file.name
        name: Meteor.uuid() + extension
        size: file.size
        type: file.type

      # Setup FileReader
      reader = new FileReader

      # Read file as DataURL for manipulation
      if settings.manipulateImage? and file.type.match(/image.*/)?
        reader.onload = ->
          # Client code is responsible for uploading file
          # by calling the provided callback
          settings.manipulateImage reader.result, fileData, (dataUrl) ->
            fileData.data = dataURLToUA dataUrl
            uploadFile settings, fileData

        reader.readAsDataURL file

      # Read the file as ArrayBuffer
      else
        reader.onload = ->
          fileData.data = new Uint8Array reader.result
          uploadFile settings, fileData

        reader.readAsArrayBuffer file


  # Upload button
  "click button": (event, tpl) ->
    clickHandler event, tpl

  "click a": (event, tpl) ->
    clickHandler event, tpl
