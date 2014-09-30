Package.describe({
  name: "schnie:uploader",
  summary: "Upload files to the clouds",
  version: "2.0.1"
});

var both = ["client", "server"];

Npm.depends({
  "knox": "0.9.1",
  "stream-buffers": "1.0.0"
});

Package.on_use(function (api) {

  api.versionsFrom("METEOR@0.9.0");

  api.use([
    "coffeescript",
    "underscore",
    "templating",
    "ejson",
    "reactive-dict"
    ], ["client", "server"]);

  api.use(["less"], ["client"]);

  api.addFiles([
    "lib/uploadedFiles.coffee",
    "lib/UploaderFile.coffee",
  ], both);

  api.addFiles([
    "client/views/uploader.html",
    "client/views/uploader.coffee",
    "client/views/uploader.less",
    "client/UploaderState.coffee"
    ], "client");

  api.addFiles([
    "server/Uploader.coffee",
    "server/server.coffee",
    "server/publications.coffee"
    ], "server");

});
