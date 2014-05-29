Router.map ->
  @route 'cors_xml',
    where: 'server'
    path: '/s3/cors_configuration.xml'
    action: ->
      template = Handlebars.templates['cors_configuration']({})
      @response.write(template)
      @response.end()

  @route 'cors_json',
    where: 'server'
    path: '/s3/bucket_policy_configuration.json'
    action: ->
      template = Handlebars.templates['bucket_policy_configuration']({bucket: s3config.bucket})
      @response.write(template)
      @response.end()
