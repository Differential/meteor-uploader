UI.registerHelper "progress", ->
  Session.get "s3Upload-#{@name}-progress"

UI.registerHelper "total", ->
  Session.get "s3Upload-#{@name}-total"

UI.registerHelper "error", ->
  Session.get "s3Upload-#{@name}-error"

UI.registerHelper "currentlyUploading", ->
    completed = Session.get "s3Upload-#{@name}-completed"
    ++completed

UI.registerHelper "complete", ->
  total = Session.get "s3Upload-#{@name}-total"
  completed = Session.get "s3Upload-#{@name}-completed"
  completed is total

#
# S3 Upload
#
computation = null

Template.s3Upload.created = ->
  computation = Deps.autorun =>
    total = Session.get "s3Upload-#{@data.name}-total"
    completed = Session.get "s3Upload-#{@data.name}-completed"

    if completed? and completed > 0 and completed is total
      Meteor.setTimeout =>
        Session.set "s3Upload-#{@data.name}", null
        Session.set "s3Upload-#{@data.name}-total", 0
        Session.set "s3Upload-#{@data.name}-completed", 0
      , 5000
      $(".s3-file-upload").val null


Template.s3Upload.destroyed = ->
  if computation then computation.stop()

Template.s3Upload.events
  "change input[type=file]": (event, template) ->
    files = event.currentTarget.files
    Session.set "s3Upload-#{template.data.name}-total", files.length

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

        key = "s3Upload-#{template.data.name}-completed"
        Session.set key, 0
        Meteor.call "S3upload", options, (error, result) ->
          if error
            Session.set "s3Upload-#{template.data.name}-error", error.reason

          total = Session.get key
          Session.set key, ++total

          template.data.onUpload(error, result)

      reader.readAsArrayBuffer file


  "click .s3-file-delete-button": (event, template) ->
    if confirm("Are you sure?")
      el = event.currentTarget
      Meteor.call "S3delete", $(el).data("url"), template.data.onDelete

  "click .s3-file-upload-button": (event, template) ->
    $(template.find(".s3-file-upload")).click()
