class @UploaderState extends ReactiveDict

  constructor: (@uploaderId) ->
    super()

  _getKey: (key) ->
    "#{@uploaderId}-#{key}"

  set: (key, value) ->
    super @_getKey(key), value

  get: (key) ->
    super @_getKey(key)
