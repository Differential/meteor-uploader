<!--
---
layout: default
username: Differential
repo: meteor-uploader
version: 0.1.1
desc: Upload files to the clouds
---
-->
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

## Client-side Example
The uploader helper can be rendered via the inclusion helper, which will display a default button.
You can use it as a block helper to specify a custom button or anchor tag.

Settings configuration:
* name: Unique name per uploader on page. (Required)
* multiple: Allow multiple file selection.
* accept: Comma-separated list of unique content type specifiers.  See more [here](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/Input).
* onSelection: Callback fired when files are selected from dialog.
* onUpload: Callback after uploaded.  Called once for each file.  Contains the new URL of the uploaded file.
* manipulateImage: If specified, this callback will be called with the following arguments for image manipulation:
  * dataURL: {String} Base64 data URI of the uploaded image
  * fileInfo: {Object} Information about the file
  * upload: {Function} Call this function after you have modified the image, passing it the DataURL of the modified image.


```HTML
<template name="MyTemplate">
  <!-- show default button -->
  {{> uploader settings=forProfilePic}}

  <!-- OR -->

  <!-- show custom button -->
  {{#uploader settings=forProfilePic}}
  <button class="btn btn-block btn-lg btn-green">
    <i class="fa fa-upload"></i> Upload Profile Image
  </button>
  {{/uploader}}
</template>
```

```CoffeeScript
# Example setup that uses the third-party caman.js library
# to resize the image before uploading

Template.MyTemplate.helpers
  forProfilePic: ->
    name: "profilePic"
    multiple: true
    accept: "image/*"
    onSelection: (fileList) ->
      console.log fileList
    manipulateImage: (dataURL, fileInfo, upload) ->
      img = new Image()
      img.onload = ->
        Caman @, ->
          @resize height: 100
          @render ->
            upload @canvas.toDataURL(fileInfo.type)
      img.src = dataURL
    onUpload: (error, result) ->
      if result
        console.log result
        Session.set "profilePicUrl", result
```

## Methods
You can delete files from s3 using the "uploaderDelete" method:
```CoffeeScript
Meteor.call "uploaderDelete", s3Url
```

## AWS S3 Setup
### CORS Setup
```XML
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
  </CORSRule>
</CORSConfiguration>
```

### S3 Bucket Policy
Add to your S3 bucket policy. Change "BUCKET_NAME" to the name of the bucket you're applying the policy to.
```JSON
{
  "Version": "2008-10-17",
  "Id": "Policy1401826004702",
  "Statement": [
    {
      "Sid": "Stmt1401825990142",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::BUCKET_NAME/*"
    }
  ]
}
```
