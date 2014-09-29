class @Uploader
  _configuration: null

  @config: (config) ->
    @_configuration = config

  @getConfig: ->
    if @_configuration?
      @_configuration
    else
      throw new Meteor.Error "Uploader not configured!"
