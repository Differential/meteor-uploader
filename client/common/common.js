Deps.autorun(function(){
  Meteor.subscribe('s3files', Meteor.user());
  Meteor.subscribe('s3_admin_users', Meteor.user());
  Meteor.subscribe('s3_all_users', Meteor.user());
});

Meteor.subscribe('s3_global_config');
Meteor.subscribe('s3config');
Meteor.subscribe('s3_users');

