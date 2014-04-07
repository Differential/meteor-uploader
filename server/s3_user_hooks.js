Meteor.users.before.remove(function (userId, doc) {
  DeleteUserFiles = function(files){

  }

  var _s3files = S3files.find({user: doc._id});
  var _s3config = getS3Config();
  var _deleteUserFiles = _s3config.deleteUserFiles;
  if(_deleteUserFiles = 'yes'){
    _.each(_s3files, function(file){
      Meteor.call('S3Delete', file._id)
    })
  }

});