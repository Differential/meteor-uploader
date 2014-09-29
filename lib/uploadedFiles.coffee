@UploadedFiles = new Meteor.Collection "uploadedFiles"

@UploadedFiles.allow
  insert: (userId, doc) ->
    true

  update: (userId, doc, fieldNames, modifier) ->
    true

  remove: (userId, doc) ->
    true
