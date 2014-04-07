Files = {};

Files.noConfig = function(){
  var existing_global_config = S3config.findOne({type: 'global'});
  if(existing_global_config){
    return false;
  } else {
    return true;
  }
};

Files.useUserRole = function(){
  var s3config = S3config.findOne({type: 'global'});
  if(!s3config)
    return;
  if(typeof s3config.use_user_role == 'undefined')
    return;
  if(Roles.userIsInRole(Meteor.userId(), ['s3_admin'])){
    return true;
  } else if(s3config.use_user_role == 'on' && Roles.userIsInRole(Meteor.userId(), ['s3_user'])) {
    return true;
  } else if(s3config.use_user_role == 'off') {
    return true;
  } else {
    return false;
  }
};