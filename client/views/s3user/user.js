Template.s3_file_row.helpers({
  name: function(){
    if(this.original_name){
      return this.original_name;
    } else {
      return this.file_name;
    }
  },
  complete: function(){
    if(this.percent_uploaded == 100) {
      return true;
    } else {
      return false;
    }
  },
  processing: function(){
    if(this.percent_uploaded !== 100 && this.error !== true) {
      return 's3-upload-progressing';
    } else if(this.error){
      return 's3-upload-error';
    } else {
      return '';
    }
  },
  uploaded_ago: function(){
    if(this.percent_uploaded == 100) {
      return moment(this.modifiedAt).fromNow();
    } else {
      return '';
    }
  }
});

Template.s3_file_row.events({
  'click .uploaded-time-ago': function (event, template) {
    if(template.data.percent_uploaded !== 100)
      return '';

    var button = $(template.find('.uploaded-time-ago'));
    var html = [];
    if(button.hasClass('ago')){
      button.removeClass('ago');
      html.push('<small>');
      html.push(moment(template.data.modifiedAt).calendar());
      html.push('</small>');
      button.html(html.join(''));
    } else {
      button.addClass('ago');
      html.push('<small>');
      html.push(moment(template.data.modifiedAt).fromNow());
      html.push('</small>');
      button.html(html.join(''));
    }
  },
  'click .path-popover': function(event, template){
    if(template.data.percent_uploaded !== 100)
      return '';

    var button = $(template.find('.path-popover'));

    var options = {
      container: 'body',
      content: 'Path: ' + template.data.path,
      placement: 'bottom',
      html: true
    };
    button.popover(options);
  }
});

Template.s3list_all.events({
  'click .s3-check-all-files': function (event, template) {
    var files = template.findAll('.selected-file');
    var this_button_checked = template.find('.s3-check-all-files').checked;
    _.each(files, function(file){
      file.checked = this_button_checked;
    });
  },
  'click .s3-delete-selected-files': function (event, template) {
    var files = template.findAll('.selected-file');
    var checked_files = [];
    _.each(files, function(file){
      if(file.checked){
        checked_files.push(file.id);
      }
    });

    if(checked_files.length > 0){
      bootbox.confirm('You are about to remove '+ checked_files.length + ' files.  This CANNOT BE UNDONE!', function(confirmed) {
        if(confirmed){
          _.each(checked_files, function(file){
            Meteor.call('S3delete', file);
          });
          Session.set('s3-file-name', null);
          // Do something
        }
      });
    }
  },
  'click .selected-file': function (event, template) {
    template.find('.s3-check-all-files').checked = false;
  }
});

Template.s3list_of_user.helpers({
  all_files: function(){
    return S3files.find({user: Meteor.userId()}).fetch();
  },
  allow_user_config: function(){
    var s3config = S3config.findOne({type: 'global'});
    if(s3config && s3config.allow_user_config == 'on'){
      return true;
    } else {
      return false;
    }
  },
  useUserRole: Files.useUserRole
});

Template.s3list_of_user.events({
  'click .s3-check-all-files': function (event, template) {
    var files = template.findAll('.selected-file');
    var this_button_checked = template.find('.s3-check-all-files').checked;
    _.each(files, function(file){
      file.checked = this_button_checked;
    });
  },
  'click .s3-delete-selected-files': function (event, template) {
    var files = template.findAll('.selected-file');
    var checked_files = [];
    _.each(files, function(file){
      if(file.checked){
        checked_files.push(file.id);
      }
    });

    if(checked_files.length > 0){
      bootbox.confirm('You are about to remove '+ checked_files.length + ' files.  This CANNOT BE UNDONE!', function(confirmed) {
        if(confirmed){
          _.each(checked_files, function(file){
            Meteor.call('S3delete', file);
          });

          // Do something
        }
      });
    }
  },
  'click .selected-file': function (event, template) {
    template.find('.s3-check-all-files').checked = false;
  }
});