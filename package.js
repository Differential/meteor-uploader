Package.describe({
  summary: 'Upload files to Files. Allows use of Knox Server-Side and get files urls on client-side.'
});

var both = ['client', 'server'];

Npm.depends({
  'knox': '0.8.5',
  'stream-buffers': '0.2.5'
});

Package.on_use(function (api) {
  //Need service-configuration to use Meteor.method
  api.use([
    'coffeescript',
    'underscore',
    'handlebars',
    'templating',
    'iron-router',
    'streams',
    'deps'
    ], ['client', 'server']);

  api.use(['less'], ['client']);

  api.use(['handlebars-server'], 'server');

  api.add_files([
    'lib/streams.coffee'
  ], both);

  api.add_files([
    'client/views/s3-upload.html',
    'client/views/s3-upload.coffee',
    'client/views/s3-upload.less'
    ], 'client');

  api.add_files([
    'client/common/cors-configuration.handlebars',
    'client/common/bucket-policy-configuration.handlebars',
    'server/s3Config.coffee',
    'server/s3-server.coffee',
    'server/cors-routes.coffee'
    ], 'server');



  // Allows user access to Knox
  if(api.export) {
    // api.export('Knox','server');
    // api.export(['S3'],['client', 'server']);
  }
});
