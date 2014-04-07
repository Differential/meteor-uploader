Template.s3list_all.helpers({
  noConfig: Files.noConfig,
  users: function(){
    var users = Meteor.users.find({}).fetch();
    return users;
  },
  all_files: function(){
    return S3files.find({user: this._id}).fetch();
  },
  has_files: function(){
    var file_count = S3files.find({user: this._id}).count();
    if(file_count > 0){
      return true;
    } else {
      return false;
    }
  },
  unassigned_files: function(){
    return S3files.find({user: {$exists: false}}).fetch();
  },
  orphaned_files: function(){
    var users = Meteor.users.find().fetch();
    var user_ids = [];
    _.each(users, function(user){
      user_ids.push(user._id);
    });
    return S3files.find({user: {$exists: true, $nin: user_ids}}).fetch();
  }
});

Template.s3config.helpers({
  noConfig: Files.noConfig,
  noAdminUsers: function(){
    var admin_users = Roles.getUsersInRole('s3_admin').fetch();
    if(admin_users.length == 0){
      return true;
    } else {
      return false;
    }
  },
  config: function(){
    var existing_global_config = S3config.findOne({type: 'global'});
    return existing_global_config;
  },
  type: function(){
    return global;
  }
});



Template.s3config_form.helpers({
  on_active: function(){
    if(this.allow_user_config == 'on'){
      return 'btn-default active'
    } else {
      return 'btn-default'
    }
  },
  off_active: function(){
    if(this.allow_user_config == 'off'){
      return 'btn-default active'
    } else {
      return 'btn-default'
    }
  },
  use_user_role_on_active: function(){
    if(this.use_user_role == 'on'){
      return 'btn-default active'
    } else {
      return 'btn-default'
    }
  },
  use_user_role_off_active: function(){
    if(this.use_user_role == 'off'){
      return 'btn-default active'
    } else {
      return 'btn-default'
    }
  }
});


Template.s3config.events({
  'click #S3ConfigSaveButton': function (event, template) {
    event.preventDefault();

    var form = template.find('form');
    var serialized_form = $(form).serializeArray();
    var s3configObject = {};
    $.each(serialized_form, function(i, v) {
        s3configObject[v.name] = v.value;
    });
    Meteor.call('S3AdminConfig', s3configObject, function(err, res){
      console.log(err);
    });
  }
});

Template.s3config_no_users.helpers({
  admin_user: function () {
    var admin_user = Session.get('admin_user');
    if(admin_user){
      return admin_user;
    } else {
      return 'username'
    }
  },
  user_exists: function(){
    var admin_user = Session.get('admin_user');
    var user = Meteor.users.findOne({username: admin_user});
    if(user){
      return true;
    } else {
      return false;
    }
  }

});

Template.s3config_no_users.events({
  'keyup #Username': function (event, template) {
    var admin_user = template.find('#Username').value;
    if(admin_user.length > 0){
      Session.set('admin_user', admin_user);
    } else {
      Session.set('admin_user', null);
    }
  },
  'click #CreateS3AdminUser': function(event, template) {
    event.preventDefault();
    var form = template.find('form');
    var serialized_form = $(form).serializeArray();
    var user_object = {};
    $.each(serialized_form, function(i, v) {
        user_object[v.name] = v.value;
        if(v.name == 'username'){
          user_object['email'] = v.value;
        }
    });
    Accounts.createUser(user_object);
  },
  'click #AddS3AdminRole': function(event, template) {
    event.preventDefault();
    var form = template.find('form');
    var serialized_form = $(form).serializeArray();
    var user_object = {};
    $.each(serialized_form, function(i, v) {
        user_object[v.name] = v.value;
        if(v.name == 'username'){
          user_object['email'] = v.value;
        }
    });
    Meteor.call('AddS3AdminRole', user_object);
  }
});

Template.s3config_admin_users.helpers({
  users: function (){
    return Meteor.users.find({}).fetch();
  },
  isS3Admin: function(){
    if(Roles.userIsInRole(this._id,['s3_admin'])){
      return true;
    } else {
      return false;
    }
  },
  isS3User: function(){
    if(Roles.userIsInRole(this._id,['s3_user'])){
      return true;
    } else {
      return false;
    }
  },
  useUserRole: function(){
    var config = S3config.findOne({type: 'global'});
    if(config && config.use_user_role == 'on'){
      return true;
    } else {
      return false;
    }
  }
});

var S3CallBack = function(error, result){
  console.log('Enter S3CallBack');
  if(error){
    console.log('error S3CallBack');
    var html = [];
    html.push('<div class="alert alert-danger">');
    html.push(error.message);
    html.push('</div');
    html = html.join('');
    bootbox.dialog({
      message: html,
      title: "S3 Package Error"
    });
  }
}

Template.s3config_admin_users.events({
  'click .remove-s3-admin-role-button': function (event, template) {
    Meteor.call('S3RemoveAdminRole', this._id, S3CallBack);
  },
  'click .add-s3-admin-role-button': function (event, template) {
    console.log(this._id)
    Meteor.call('S3AddAdminRole', this._id, S3CallBack);
  },
  'click .remove-s3-user-role-button': function (event, template) {
    Meteor.call('S3RemoveUserRole', this._id, S3CallBack)
  },
  'click .add-s3-user-role-button': function (event, template) {
    Meteor.call('S3AddUserRole', this._id, S3CallBack)
  }
});