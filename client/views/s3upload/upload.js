Template.s3upload.helpers({
  button_size_css: function(){
    var s3config = S3config.findOne({type: 'global'});
    if(s3config.allow_user_config == 'on'){
      return 'col-md-11 col-sm-10 col-xs-10 col-lg-11'
    } else {
      return 'btn-block'
    }
  },
  allow_user_config: function(){
    var s3config = S3config.findOne({type: 'global'});
    if(s3config.allow_user_config == 'on'){
      return true;
    } else {
      return false;
    }
  },
  noUploads: function(){
    var s3_file_name = Session.get('s3-file-name-' + this.name);
    if(s3_file_name == null || typeof s3_file_name == 'undefined') {
      return true;
    } else {
      return false;
    }
  },
  s3private: function(){
    var s3config_user = S3config.findOne({user_id: Meteor.userId()});
    if(typeof s3config_user == 'object'){
      return true;
    } else {
      return false;
    }
  },
  noConfig: Files.noConfig,
  useUserRole: Files.useUserRole
});

Template.s3upload.events({
  'change input[type=file]': function (event,template){
    var files = event.currentTarget.files;
    $(template.find('.s3-file-upload-button')).addClass('disabled');
    $(template.find('.s3-file-upload-button')).text('Preparing to transfer file...');
    _.each(files,function(file){
      var reader = new FileReader;
      var fileData = {
        name:file.name,
        size:file.size,
        type:file.type
      };

      reader.onload = function (e) {
        fileData.data = new Uint8Array(reader.result);
        fileData.originalName = fileData.name;
        var extension = (fileData.name).match(/\.[0-9a-z]{1,5}$/i);
        fileData.name = Meteor.uuid()+extension;
        options = template.data;
        options.file = fileData;
        Session.set('s3-file-name-' + template.data.name, fileData.name)
        Meteor.call("S3upload", options, template.data.onUpload);
      };

      reader.readAsArrayBuffer(file);

    });
  },
  'click .s3-file-delete-button': function(event,template){
    if (confirm('Are you sure?')) {
      var el = event.currentTarget;
      Meteor.call('S3delete', $(el).data('url'), template.data.onDelete);
    }
  },
  'click .s3-file-upload-button': function(event,template){
    $(template.find('.s3-file-upload')).click();
  },
  'click .s3-user-config-button': function(event,template){

  }
});

Template.s3progress.helpers({
  has_errors: function(){
    var file_name = Session.get('s3-file-name-' + this.name)
    if(file_name != null){
      var file = S3files.findOne({file_name: file_name});
      if(file){
        var error = file.error
        if(error){
          var self = this;
          Meteor.setTimeout(function(){
            Session.set('s3-file-name-' + self.name, null);
          },5000);
          $('.s3-file-upload').val(null);
          return true
        } else {
          return false
        }
      }
    } else {
      return false;
    }
  },
  error_class: function(){
    var file_name = Session.get('s3-file-name-' + this.name)
    if(file_name != null){
      var file = S3files.findOne({file_name: file_name});
      if(file){
        var error = file.error
        if(error)
          return 'progress-bar-danger'
      }
    } else {
      return '';
    }
  },
  show_progress: function(){
    var file_name = Session.get('s3-file-name-' + this.name)
    if(file_name != null){
      return true;
    } else {
      return false;
    }
  },
  progress: function () {
    var file_name = Session.get('s3-file-name-' + this.name)
    if(file_name != null){
      var file = S3files.findOne({file_name: file_name});
      if(file){
        var percent = file.percent_uploaded
        if(percent)
          return percent
      }
    } else {
      return 0;
    }
  },
  percent_uploaded_to_browser: function(){
    var file_name = Session.get('s3-file-name-' + this.name)
    if(file_name != null){
      var file = S3files.findOne({file_name: file_name});
      if(file){
        var percent = file.percent_uploaded_to_browser
        if(percent)
          return percent
      }
    } else {
      return 0;
    }
  },
  complete: function() {
    var file_name = Session.get('s3-file-name-' + this.name)
    if(file_name != null){
      var file = S3files.findOne({file_name: file_name});
      if(file){
        var percent = file.percent_uploaded
        if(percent == 100) {
          var self = this;
          Meteor.setTimeout(function(){
            Session.set('s3-file-name-' + self.name, null);
          },5000);
          $('.s3-file-upload').val(null);
          return true
        } else {
          return false;
        }
      }
    }
  }
});
