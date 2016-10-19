active = null
placeholder = null

class QingSortable extends QingModule

  @opts:
    sortable: null
    customDragImage: false

  constructor: (opts) ->
    super

    @sortable = $ @opts.sortable
    unless @sortable.length > 0
      throw new Error 'QingSortable: option sortable is required'

    @opts = $.extend {}, QingSortable.opts, @opts
    @_render()
    @_bind()

  _render: ->
    @sortable.each (index, el)->
      el.draggable = true

  _bind: ->
    @sortable.on 'dragstart.qingSortable', (e) =>
      $item = $(e.currentTarget).addClass('qing-sortable-active')
      if @opts.customDragImage
        dragImage = $item.clone().addClass('qing-sortable-dragimage')
        dragImage.appendTo('body')
        e.originalEvent.dataTransfer.setDragImage(
          dragImage[0],dragImage.width()/2,dragImage.height()/2
        )
      active = $item
      placeholder = $item.clone().attr('data-sort-placeholder', true)

    @sortable.on 'dragend.qingSortable', (e) =>
      $item = $(e.currentTarget)
      $item.removeClass 'qing-sortable-active'
      if $.contains document, placeholder[0]
        $(e.currentTarget).show().insertAfter(placeholder)
        placeholder.detach()
      active = null

    @sortable.on 'dragenter.qingSortable', (e)=>
      $item = $ e.currentTarget
      unless $item[0] is active[0]
        index = if $.contains document, placeholder[0]
        then placeholder.index()
        else active.index()
        method = if index < $item.index()
        then 'after' else 'before'
        $item[method] placeholder
        active.hide()

  destroy: ->
    @sortable.off('.qingSortable')
    placeholder?.remove()

module.exports = QingSortable
