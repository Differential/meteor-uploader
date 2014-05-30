UI.registerHelper "queueSize", ->
  Session.get "uploader-queueSize-#{@name}"

UI.registerHelper "queueExists", ->
  queueSize = Session.get "uploader-queueSize-#{@name}"
  queueSize? and queueSize > 0

UI.registerHelper "progress", ->
  Session.get "uploader-progress-#{@name}"

UI.registerHelper "progressExists", ->
  progress = Session.get "uploader-progress-#{@name}"
  progress? and progress > 0

UI.registerHelper "error", ->
  Session.get "uploader-error-#{@name}"

UI.registerHelper "currentlyUploading", ->
    completed = Session.get "uploader-completed-#{@name}"
    ++completed

UI.registerHelper "complete", ->
  queueSize = Session.get "uploader-queueSize-#{@name}"
  completed = Session.get "uploader-completed-#{@name}"
  completed is queueSize

resetState = (context) ->
  Session.set "uploader-progress-#{context.data.name}", 0
  Session.set "uploader-queueSize-#{context.data.name}", 0
  Session.set "uploader-completed-#{context.data.name}", 0

#
# S3 Upload
#

# Watches queue and completed to determine when to reset
completionWatch = null

Template.Uploader.created = ->
  # Clear the slate
  resetState @

  # Set up watch on session vars
  completionWatch = Deps.autorun =>
    queueSize = Session.get "uploader-queueSize-#{@data.name}"
    completed = Session.get "uploader-completed-#{@data.name}"

    # Have we completed the queue
    if completed? and completed > 0 and completed is queueSize
      # Reset file picker
      $(".s3-file-upload").val null

      # Reset values after 5 seconds (pause to show completion msg)
      Meteor.setTimeout =>
        resetState @
      , 5000

Template.Uploader.destroyed = ->
  # Stop the computation if we leave
  if completionWatch then completionWatch.stop()

Template.Uploader.events
  # After file(s) have been chosen
  "change input[type=file]": (event, template) ->
    files = event.currentTarget.files
    Session.set "uploader-queueSize-#{template.data.name}", files.length

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

        options = template.data
        options.file = fileData

        Meteor.call "uploaderUpload", options, (error, result) ->
          # Display error
          if error then Session.set "uploader-error-#{template.data.name}", error.reason

          # Increment completed count no matter what happens here
          completed = Session.get "uploader-completed-#{template.data.name}"
          Session.set "uploader-completed-#{template.data.name}", ++completed

          # Pass results to user defined callback
          template.data.onUpload(error, result)

      reader.readAsArrayBuffer file

  # Delete button
  "click .s3-file-delete-button": (event, template) ->
    if confirm("Are you sure?")
      el = event.currentTarget
      Meteor.call "S3delete", $(el).data("url"), template.data.onDelete

  # Upload button
  "click .s3-file-upload-button": (event, template) ->
    $(template.find(".s3-file-upload")).click()
