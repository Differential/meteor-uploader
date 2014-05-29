class @s3Config
  _configuration: null
  @config: (config) ->
    @_configuration = config

  @getConfig: ->
    if @_configuration?
      @_configuration
    else
      throw new Meteor.Error "s3Uploader not configured!"
