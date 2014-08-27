Package.describe({
  name: "schnie:uploader"
  summary: "Upload files to the clouds"
  version: "1.0.0"
  git: "https://github.com/Differential/meteor-uploader"
});

var both = ["client", "server"];

Npm.depends({
  "knox": "0.8.5",
  "stream-buffers": "0.2.5"
});

Package.onUse(function (api) {
  api.versionsFrom("METEOR@0.9.0");

  api.use([
    "coffeescript",
    "underscore",
    "handlebars",
    "templating",
    "arunoda:streams",
    "deps"
    ], both);

  api.use(["less"], ["client"]);

  // api.use(["handlebars-server"], "server");

  api.addFiles([
    "lib/streams.coffee"
  ], both);

  api.addFiles([
    "client/views/uploader.html",
    "client/views/uploader.coffee",
    "client/views/uploader.less"
    ], "client");

  api.addFiles([
    // "client/common/cors-configuration.handlebars",
    // "client/common/bucket-policy-configuration.handlebars",
    "server/Uploader.coffee",
    "server/server.coffee",
    "server/routes.coffee"
    ], "server");


  if(api.export) {
    // api.export("Knox","server");
    // api.export(["S3"],["client", "server"]);
  }
});
