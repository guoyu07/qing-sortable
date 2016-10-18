class QingSortable extends QingModule

  @opts:
    el: null

  constructor: (opts) ->
    super

    @el = $ @opts.el
    unless @el.length > 0
      throw new Error 'QingSortable: option el is required'

    @opts = $.extend {}, QingSortable.opts, @opts
    @_render()
    @trigger 'ready'

  _render: ->
    @el.append """
      <p>This is a sample component.</p>
    """
    @el.addClass ' qing-sortable'
      .data 'qingSortable', @

  destroy: ->
    @el.empty()
      .removeData 'qingSortable'

module.exports = QingSortable
