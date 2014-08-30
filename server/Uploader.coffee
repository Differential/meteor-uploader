class @Uploader
  _configuration: null
  @config: (config) ->
    @_configuration = config
    _aclList = ["private", "public-read", "public-read-write", "authenticated-read",
            "bucket-owner-read", "bucket-owner-full-control"]
    config.acl = config.acl or "private"
    throw new Meteor.Error("Unknown acl param!")  unless config.acl in _aclList

  @getConfig: ->
    if @_configuration?
      @_configuration
    else
      throw new Meteor.Error "Uploader not configured!"
