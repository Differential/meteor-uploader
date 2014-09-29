Meteor.publish "uploadedFiles", (uploaderId) ->
  UploadedFiles.find uploaderId: uploaderId
