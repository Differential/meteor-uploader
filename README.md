---
layout: default
username: Differential
repo: meteor-uploader
version: 0.0.1
desc: Upload files to the clouds
---
# meteor-uploader

Renders an upload button so you can upload files from the browser to the cloud (currently only s3)

## Server Configuration
```CoffeeScript
Uploader.config
  key: "my-key"
  secret: "my-secret"
  bucket: "my-bucket"
  directory: "/" # Optional
```

## Client Example
```HTML
<template name="MyTemplate">
  {{> Uploader forProfilePic}}
</template>
```

```CoffeeScript
Template.MyTemplate.helpers
  forProfilePic: ->
    name: "profilePic" # Unique name per uploader on page
    multiple: true # Optional
    current: Session.get "profilePicUrl" # Optional - shows thumbnail and remove button
    onUpload: (error, result) -> # Callback after uploaded - runs once per file uploaded
      if result
        console.log result
        Session.set "profilePicUrl", result
    onDelete: (error, result) -> # Callback after deleted - runs once per file deleted
      if result
        console.log "Deleted", result
        Session.set "profilePicUrl", null
```
