---
layout: default
username: Differential
repo: meteor-uploader
version: 0.1.0
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
  <!-- shows default button -->
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
Template.MyTemplate.helpers
  forProfilePic: ->
    name: "profilePic" # Unique name per uploader on page
    multiple: true # Optional
    onSelection: (fileList) -> # Callback when files are selected from dialog
      console.log fileList
    onUpload: (error, result) -> # Callback after uploaded - runs once per file uploaded
      if result
        console.log result
        Session.set "profilePicUrl", result
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
