# S3 CORS upload

# https://devcenter.heroku.com/articles/s3-upload-node
# http://docs.amazonwebservices.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors
# http://www.ioncannon.net/programming/1539/direct-browser-uploading-amazon-s3-cors-fileapi-xhr2-and-signed-puts/
# https://github.com/carsonmcdonald/direct-browser-s3-upload-example
# http://stackoverflow.com/questions/17397924/amazon-s3-strange-error-sometimes-signaturedoesnotmatch-sometimes-it-does
# http://stackoverflow.com/questions/20709711/amazon-s3-signature-does-not-match-aws-sdk-java


class window.S3DirectUpload
  onError: (status) ->
    console.log 'base.onError()', status
  onProgress: (percent, status) ->
    console.log 'base.onProgress()', percent, status
  onFinishS3Put: (publicUrl) ->
    console.log 'base.onFinishS3Put()', publicUrl

  # Don't override these
  constructor: (settings) ->
    @settings = settings
    @uploadFile(settings.file)

  createCORSRequest: (method, url) ->
    xhr = new XMLHttpRequest()
    if xhr.withCredentials?
      xhr.open method, url, true
    else if typeof XDomainRequest isnt "undefined"
      xhr = new XDomainRequest()
      xhr.open method, url
    else
      xhr = null
    xhr

  # Use a CORS call to upload the given file to S3. Assumes the url
  # parameter has been signed and is accessible for upload.
  uploadToS3: (file, url, publicUrl) ->
    self = this
    xhr = @createCORSRequest 'PUT', url
    if !xhr
      @onError 'CORS not supported'
    else
      xhr.onload = ->

        if xhr.status is 200
          self.onProgress 100, 'Upload completed.'
          self.onFinishS3Put publicUrl
        else
          self.onError 'Upload error: ' + xhr.status

      xhr.onerror = ->
        self.onError 'XHR error.'

      xhr.upload.onprogress = (e) ->
        if e.lengthComputable
          percentLoaded = Math.round (e.loaded / e.total) * 100
          self.onProgress percentLoaded, if percentLoaded is 100 then 'Finalizing.' else 'Uploading.'

    xhr.setRequestHeader 'Content-Type', file.type
    # xhr.setRequestHeader 'x-amz-acl', 'public-read' #need tests

    xhr.send file.data

  uploadFile: (file) ->
    self = this
    @onProgress 0, 'Upload started.'
    Meteor.call 'uploaderSignedUrl', file.name, file.type, (error, signedUrl) ->
      return @onError error if error
      publicUrl = signedUrl.substring(0, signedUrl.indexOf('?'));
      self.uploadToS3 file, signedUrl, publicUrl
    
    

class window.UploaderS3DirectUpload extends S3DirectUpload
  onProgress: (percent, message) ->
    Session.set "uploader-progress-#{@settings.name}", percent
  onFinishS3Put: (publicUrl) ->
    completed = Session.get "uploader-completed-#{@settings.name}"
    Session.set "uploader-completed-#{@settings.name}", ++completed
    result =     
      url: publicUrl
      fileName: @settings.file.name
      originalFileName: @settings.file.originalName
      uploaderName: @settings.name

    if @settings.onUpload
      @settings.onUpload(false, result)
  onError: (reason) ->
    Session.set "uploader-error-#{@settings.name}", reason




