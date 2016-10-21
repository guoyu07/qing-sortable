$active = null
$placeholder = null
allItems = $ []

class QingSortable extends QingModule

  @opts:
    container: null
    items: null
    axis: 'x' # 'y'

  constructor: (opts) ->
    super
    @items = $(@opts.items)
    @container = $(@opts.container)
    @_checkOptions()
    @items.data('qingSortable', @)
    allItems = allItems.add @items
    @opts = $.extend {}, QingSortable.opts, @opts
    @_render()
    @_bind()
  _checkOptions: ->
    unless @items.length > 0
      throw new Error 'QingSortable: option items is required'
    unless @container.length > 0
      throw new Error 'QingSortable: option container is required'
  _render: ->
    @items.each (index, el)->
      el.draggable = true
  _setDragImage: (e)->
    $item = $(e.currentTarget)
    @dragImage = $item.clone().addClass('qing-sortable-dragimage')
    @dragImage.css
      width: $item.width()
      height: $item.height()
    @dragImage.prependTo $item.parent()
    e.originalEvent.dataTransfer.setDragImage(
      @dragImage[0],
      e.pageX-$item.offset().left,
      e.pageY-$item.offset().top
    )
  _getMousePosition: (e)->
    $item = $(e.currentTarget)
    x: e.pageX-$item.offset().left
    y: e.pageY-$item.offset().top

  _onStart: ($item) ->
    @dragging = true
    $active = $item
  _onEnd: ()->
    @dragging = false
    $active = null
  _shouldCalculatePosition: (e)->
    return false unless @dragging
    return false if $(e.target).data('qingSortable')
    return false if e.target is $placeholder[0]
    return false if e.target is $active[0]
    true

  _bind: ->
    @items.on 'dragstart.qingSortable', (e) =>
      @_setDragImage e
      @mousePosition = @_getMousePosition(e)
      $item = $(e.currentTarget).addClass('qing-sortable-placeholder')
      $placeholder = $item.clone().attr('qing-sortable-placeholder',true)
      @_onStart $item

    @items.on 'dragend.qingSortable', (e) =>
      $item = $(e.currentTarget).removeClass(
        'qing-sortable-placeholder qing-sortable-hide'
      )
      if $.contains document, $placeholder[0]
        $item.insertAfter($placeholder)
        $placeholder.detach()
      @_onEnd()


    @container.on 'dragenter.qingSortable', (e)=>
      @inContainer = true
    @container.on 'dragleave.qingSortable', (e)=>
      if e.target is e.currentTarget
        @inContainer = false

    $(document).on 'dragover.qingSortable', (e)=>
      return unless @_shouldCalculatePosition(e)

      $placeholder.detach()
      center =
        x: e.pageX - @mousePosition.x + $active.outerWidth() / 2
        y: e.pageY - @mousePosition.y + $active.outerHeight() / 2
      scope = if @inContainer then @items else allItems
      sorted = @_getSortedCenters scope, center
      nearest = sorted[0].element
      if center[@opts.axis] < sorted[0].center[@opts.axis]
        $(nearest).before($placeholder)
      else
        $(nearest).after($placeholder)
      $active.addClass('qing-sortable-hide')

    @items.on 'dragenter.qingSortable', (e)=>
      return unless @inContainer
      $item = $ e.currentTarget
      index = if $.contains document, $placeholder[0]
      then $placeholder.index()
      else $active.index()
      if index < $item.index()
        $item.after $placeholder
      else
        $item.before $placeholder
      $active.addClass('qing-sortable-hide')

  _getSortedCenters: (items, center)->
    all =  items.map (index, el)->
      $el = $(el)
      offset = $el.offset()
      c =
        x: offset.left + $el.outerWidth()/2
        y: offset.top + $el.outerHeight()/2
      delta = Math.sqrt(Math.pow((center.x - c.x),2) +
        Math.pow((center.y - c.y),2))
      delta: delta
      element: el
      center: c
    all.sort (a,b)->
      a.delta - b.delta
  destroy: ->
    allItems = allItems.not @items
    @items.off('.qingSortable')
    $placeholder?.remove()
    @dragImage?.remove()

module.exports = QingSortable
