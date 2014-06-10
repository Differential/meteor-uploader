UI.registerHelper "queueSize", ->
  Session.get "uploader-queueSize-#{@settings.name}"

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

clickHandler = (event, template) ->
  event.preventDefault()
  $(template.find(".file-upload")).click()

#
# S3 Upload
#

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
  "change input[type=file]": (event, template) ->
    files = event.currentTarget.files
    Session.set "uploader-queueSize-#{template.data.settings.name}", files.length

    if template.data.settings.onSelection
      template.data.settings.onSelection(files)

    _.each files, (file) ->
      reader = new FileReader
      fileData =
        name: file.name
        size: file.size
        type: file.type

      reader.onload = (e) ->
        fileData.data = new Uint8Array reader.result
        fileData.originalName = fileData.name

        extension = (fileData.name).match(/\.[0-9a-z]{1,5}$/i)
        fileData.name = Meteor.uuid() + extension

        options = template.data.settings
        options.file = fileData

        Meteor.call "uploaderUpload", options, (error, result) ->
          # Display error
          if error then Session.set "uploader-error-#{template.data.settings.name}", error.reason

          # Increment completed count no matter what happens here
          completed = Session.get "uploader-completed-#{template.data.settings.name}"
          Session.set "uploader-completed-#{template.data.settings.name}", ++completed

          # Pass results to user defined callback
          if template.data.settings.onUpload
            template.data.settings.onUpload(error, result)

      reader.readAsArrayBuffer file

  # Upload button
  "click button": (event, template) ->
    clickHandler event, template

  "click a": (event, template) ->
    clickHandler event, template
