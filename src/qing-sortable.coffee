$ACTIVE = null
$PLACEHOLDER = null
allItems = $ []
allContainers = $ []
theContainer = null
cid = 1

class QingSortable extends QingModule

  @opts:
    scope: document
    container: null
    items: '[draggable=true]'
    axis: 'x' # 'y'

  constructor: (opts) ->
    super
    @opts = $.extend {}, QingSortable.opts, @opts
    @container = $(@opts.container)
    @items = @container.find(@opts.items)
    @_checkOptions()
    @_cid = cid++
    allContainers = allContainers.add @container
    allItems = allItems.add @items
    @_bind()
  _checkOptions: ->
    unless @opts.items.length > 0
      throw new Error 'QingSortable: option items is required'
    unless @container.length > 0
      throw new Error 'QingSortable: option container is required'
  _setDragImage: (e)->
    @dragImage?.hide().remove()
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
  _cacheMousePosition: (e)->
    $item = $(e.currentTarget)
    @mousePosition =
      x: e.pageX-$item.offset().left
      y: e.pageY-$item.offset().top
  _shouldCalculatePosition: (e)->
    return false unless @dragging
    return false if $(e.target).data('qingSortable')
    return false if e.target is $placeholder[0]
    return false if e.target is $active[0]
    true
  _cacheContainerDimensions: ()->
    @containerDimensions = allContainers.map((index, container)=>
      @_getDimension container
    ).get()

  _cacheItemPositions: ()->
    @itemCenters = allItems.map((index, item)->
      $el = $(item)
      offset = $el.offset()
      element: item
      x: offset.left + $el.outerWidth()/2
      y: offset.top + $el.outerHeight()/2
    ).get()

  _hideActiveItem: ($item)->
    $item.addClass 'qing-sortable-hide'

  _getDimension: (element)->
    offset = $(element).offset()
    top: offset.top
    left: offset.left
    bottom: offset.top + $(element).outerHeight()
    right: offset.left + $(element).outerWidth()
    element: element

  _findNearestContainer: (itemDimension)->
    distance = (x,y)->
      Math.sqrt(Math.pow(x,2)+Math.pow(y,2))

    compare = (d1, d2)->
      #7     8     9
      #
      #    +---+
      #    |   |
      #6   | 1 |   2
      #    |   |
      #    +---+
      #
      #5     4     3
      if d2.left > d1.right # 9 2 3
        if d2.bottom < d1.top # 9
          delta: distance d2.left-d1.right, d1.top - d2.bottom
          position: 9
        else if d2.top > d1.bottom # 3
          delta: distance d2.left-d1.right, d2.top-d1.bottom
          position: 3
        else #2
          delta: d2.left - d1.right
          position: 2
      else if d2.right < d1.left # 5 6 7
        if d2.bottom < d1.top # 7
          delta: distance d1.left-d2.right, d1.top - d2.bottom
          position: 7
        else if d2.top > d1.bottom # 5
          delta: distance d1.left-d2.right, d2.top - d1.bottom
          position: 5
        else #6
          delta: d1.left - d2.right
          position: 6
      else if d2.bottom < d1.top #8
        delta: d1.top - d2.bottom
        position: 8
      else if d2.top > d1.bottom #4
        delta: d2.top - d1.bottom
        position: 4
      else
        delta: 0
        position: 1

    list = $.map(@containerDimensions, (d, index)=>
      diff = compare(d, itemDimension)
      delta: diff.delta
      position: diff.position
      dimension: d
      element: d.element
    ).sort((a,b)-> a.delta - b.delta)
    list[0].element

  _getItemDimension: (e)->
    dimension =
      left: e.pageX - @mousePosition.x
      top: e.pageY - @mousePosition.y
    dimension.right = dimension.left + $ACTIVE.outerWidth()
    dimension.bottom = dimension.top + $ACTIVE.outerHeight()
    dimension
  _findNearestItem: (itemDimension, container)->
    items = $(container).find(@opts.items).not($PLACEHOLDER)
    center =
      x: (itemDimension.left + itemDimension.right) /2
      y: (itemDimension.top + itemDimension.bottom) /2

    all = items.map((index, el)->
      $el = $(el)
      offset = $el.offset()
      c =
        x: offset.left + $el.outerWidth()/2
        y: offset.top + $el.outerHeight()/2
      delta = Math.sqrt(Math.pow((center.x - c.x),2) +
        Math.pow((center.y - c.y),2))
      result =
        delta: delta
        element: el
        center: c
      result.xDelta = c.x - center.x
      result.yDelta = c.y - center.y
      result
    ).sort (a,b)->
      a.delta - b.delta

    all[0]

  _bind: ->
    @scope = $ @opts.scope

    @scope.on "dragstart.qingSortable#{@_cid}", @opts.items, (e)=>
      $item = $ e.target
      return unless $.contains @container[0], e.target
      @isDragging = true
      @_cacheContainerDimensions()
      @_cacheItemPositions()
      @_cacheMousePosition(e)
      @_setDragImage e
      $item.addClass 'qing-sortable-placeholder'
      $ACTIVE = $item
      $PLACEHOLDER = $item.clone()
    @scope.on "dragover.qingSortable#{@_cid}",  (e)=>
      e.preventDefault()
      return unless @isDragging
      return if (e.target is $ACTIVE[0]) or ($.contains $ACTIVE[0], e.target)
      itemDimension = @_getItemDimension e
      nearestContainer = @_findNearestContainer itemDimension
      nearItem = @_findNearestItem itemDimension, nearestContainer
      method
      if @opts.axis is 'x'
        method = if nearItem.xDelta>0 then 'before' else 'after'
      else
        method = if nearItem.yDelta>0 then 'before' else 'after'
      $(nearItem.element)[method] $PLACEHOLDER

    @scope.on "dragend.qingSortable#{@_cid}", @opts.items, (e)=>
      return unless @isDragging
      $ACTIVE.removeClass('qing-sortable-placeholder qing-sortable-hide')
      if $PLACEHOLDER and $.contains document,$PLACEHOLDER[0]
        $PLACEHOLDER.replaceWith $ACTIVE
        $PLACEHOLDER = null
      ACTIVE = null
    @scope.on "dragleave.qingSortable#{@_cid}", @opts.items, (e)=>
      return unless @isDragging
      if e.currentTarget is $ACTIVE[0]
        $ACTIVE.removeClass('qing-sortable-placeholder')
          .addClass 'qing-sortable-hide'
  destroy: ->
    allItems = allItems.not @items
    allContainers = allContainers.not @contains
    @scope.off ".qingSortable#{@_cid}"

module.exports = QingSortable
