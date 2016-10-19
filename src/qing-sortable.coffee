class QingSortable extends QingModule

  @opts:
    sortable: null

  constructor: (opts) ->
    super

    @sortable = $ @opts.sortable
    unless @sortable.length > 0
      throw new Error 'QingSortable: option sortable is required'

    @opts = $.extend {}, QingSortable.opts, @opts
    @_render()
    @_bind()

  placeholder: null
  active: null
  _render: ->
    @sortable.each (index, el)=>
      el.draggable = true

  _bind: ->
    @sortable.on 'dragstart.qingSortable', (e) =>
      dragImage = $('<div/>').addClass('qing-sortable-dragimage')
      dragImage.appendTo('body')
      e.originalEvent.dataTransfer.setDragImage(
        dragImage[0],dragImage.width()/2,dragImage.height()/2
      )
      $item = $(e.currentTarget).addClass('qing-sortable-active')
      @active = $item
      @placeholder = $item.clone()

    @sortable.on 'dragend.qingSortable', (e) =>
      $item = $(e.currentTarget)
      $item.removeClass 'qing-sortable-active'
      @active = null
      return unless $.contains document, @placeholder[0]
      $(e.currentTarget).show().insertAfter(@placeholder)
      @placeholder.detach()

    @sortable.on 'dragenter.qingSortable', (e)=>
      $item = $ e.currentTarget
      unless $item[0] is @active[0]
        index = if $.contains document, @placeholder[0]
        then @placeholder.index()
        else @active.index()
        method = if index < $item.index()
        then 'after' else 'before'
        $item[method] @placeholder
        @active.hide()

  destroy: ->
    @sortable.off('.qingSortable')
    @placeholder?.remove()

module.exports = QingSortable
