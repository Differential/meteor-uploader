Meteor.Router.add({
  '/s3/cors_configuration.xml': function(){
    var template = Handlebars.templates['cors_configuration']({});
    return template;
  },
  '/s3/bucket_policy_configuration.json': function(){
    var s3config = getS3Config();

    var template = Handlebars.templates['bucket_policy_configuration']({bucket: s3config.bucket});
    return template;
  }
})