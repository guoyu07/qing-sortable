class QingSortable extends QingModule
  @opts:
    el: document
    groups: null
    items: null
    plugins: []
  @id: 1
  @getElementDimension: (el)->
    $el = $(el)
    offset = $el.offset()
    width = $el.outerWidth()
    height = $el.outerHeight()
    left: offset.left
    top: offset.top
    width: width
    height: height
    center:
      left: offset.left + height / 2
      top: offset.top + height / 2
    element: el
  @excluded: '[data-qing-sortable-excluded]'
  @pointToDimension: (p, d)->
    max = Math.max
    abs = Math.abs
    sqrt = Math.sqrt
    center =
      left: d.left + d.width / 2
      top: d.top + d.height / 2
    dx = max(abs(p[0] - center.left) - d.width/2, 0)
    dy = max(abs(p[1] - center.top) - d.height/2, 0)

    return sqrt dx * dx + dy * dy

  activeItem: null
  placeholder: null
  _setOptions: (opts)->
    @opts = $.extend {}, QingSortable.opts, opts
    unless @opts.items
      throw new Error 'option items is required'
  _init: ()->
    @el = $ @opts.el
    @id = QingSortable.id++
    @_bind()

  _generateHelper: ($item)->
    @helper = $item.clone().addClass('qing-sortable-helper')
    @helper.outerWidth $item.outerWidth()
    @helper.outerHeight $item.outerHeight()
    @helper.attr('data-qing-sortable-excluded', true)
    @helper.prependTo $item.parent()

  _bind: ()->
    itemSelector = @opts.items
    @el.on "dragstart.qingSortable#{@id}", itemSelector, (e)=>
      $item = $ e.currentTarget
      offset = $item.offset()
      e.originalEvent.dataTransfer.setDragImage(
        @_generateHelper($item).get(0),
        e.pageX-offset.left,
        e.pageY-offset.top
      )
      @_onDragStart($item)
    @el.on "dragover.qingSortable#{@id}", (e)=>
      @_onDragOver(e.pageX, e.pageY)
    @el.on "dragend.qingSortable#{@id}", (e)=>
      @_onDragEnd()

  _cacheMousePosition: (pageX, pageY)->
    offset = @activeItem.offset()
    @mousePosition =
      x: pageX - offset.left
      y: pageY - offset.top
  _onDragStart: ($item)->
    @activeItem = $item
    $item.addClass 'qing-sortable-placeholder'
    @_cacheDimensions()
    @_cacheMousePosition()
    @_generatePlaceholder()

  _onDragOver: (x,y)->
    return unless @activeItem
    @nearDimension = @_findNearItemDimension(x,y)
    $(@nearDimension.element).addClass('qing-sortable-near')
      .siblings().removeClass('qing-sortable-near')
    @_movePlaceholderTo @nearDimension, [x,y]
    @activeItem.removeClass('qing-sortable-placeholder')
    @activeItem.addClass 'qing-sortable-hide'
    @_updateDimensions()

  _onDragEnd: ()->
    return unless @activeItem
    @activeItem.removeClass 'qing-sortable-placeholder qing-sortable-hide'
    $(@nearDimension.element).removeClass 'qing-sortable-near'
    @placeholder.replaceWith @activeItem
    @helper.remove()
    @helper = null
    @activeItem = null
    @placeholder = null
    @nearDimension = null

  _reset: ()->

  destroy: ->
    @el.off ".qingSortable#{@id}"
    @helper?.remove()
    @activeItem = null
    @placeholder?.remove()
    @nearDimension = null

  _movePlaceholderTo: (dimension, mousePoint)->
    $el = $(dimension.element)
    if @opts.axis is 'x'
      if mousePoint[0] < dimension.center.left
        $el.before @placeholder
      else
        $el.after @placeholder
    else
      if mousePoint[1] < dimension.center.top
        $el.before @placeholder
      else
        $el.after @placeholder

  _generatePlaceholder: ()->
    @placeholder = @activeItem.clone()

  _findNearItemDimension: (x,y)->
    if @opts.groups
      @_findNearGroup(x,y)
    else
      @dimensions.sort((a,b)->
        deltaA = QingSortable.pointToDimension [x,y], a
        deltaB = QingSortable.pointToDimension [x,y], b
        deltaA - deltaB
      )[0]

  _cacheDimensions: ()->
    collectItemDimensions = ($el)=>
      $el.find(@opts.items).not(QingSortable.excluded).map((index, item)=>
        QingSortable.getElementDimension item
      ).get()
    @dimensions = if @opts.groups
      @el.find(@opts.groups).map((index, group)=>
        d = QingSortable.getElementDimension group
        d.children = collectItemDimensions $(group), d.children
        d
      ).get()
    else
      collectItemDimensions @el

  _updateDimensions: ()->
    update = (i,index)->
      offset = $(i.element).offset()
      i.left = offset.left
      i.top = offset.top
      if i.children
        i.children.map update

    @dimensions.map update

#allItems = $ []
#allContainers = $ []
#theContainer = null
#cid = 1
#length = (x,y)->
  #Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
#compareDimensions = (d1, d2)->
  ## 7   8   9
  ##   +---+
  ## 6 |d1 | 2
  ##   +---+
  ## 5   4   3
  #if d2.left > d1.right # 9 2 3
    #if d2.bottom < d1.top # 9
      #delta: length d2.left-d1.right, d1.top - d2.bottom
      #position: 9
    #else if d2.top > d1.bottom # 3
      #delta: length d2.left-d1.right, d2.top-d1.bottom
      #position: 3
    #else #2
      #delta: d2.left - d1.right
      #position: 2
  #else if d2.right < d1.left # 5 6 7
    #if d2.bottom < d1.top # 7
      #delta: length d1.left-d2.right, d1.top - d2.bottom
      #position: 7
    #else if d2.top > d1.bottom # 5
      #delta: length d1.left-d2.right, d2.top - d1.bottom
      #position: 5
    #else #6
      #delta: d1.left - d2.right
      #position: 6
  #else if d2.bottom < d1.top #8
    #delta: d1.top - d2.bottom
    #position: 8
  #else if d2.top > d1.bottom #4
    #delta: d2.top - d1.bottom
    #position: 4
  #else # 部分重合
    #delta: 0
    #position: 1

#class QingSortable extends QingModule

  #activeItem: null

  #@opts:
    #scope: document
    #container: null
    #items: '[draggable=true]'
    #axis: 'x' # 'y'

  #constructor: (opts) ->
    #super
    #@opts = $.extend {}, QingSortable.opts, @opts
    #@groups = $(@opts.container)
    #@items = @groups.find(@opts.items)
    #@_checkOptions()
    #@_cid = cid++
    #allContainers = allContainers.add @groups
    #allItems = allItems.add @items
    #@_bind()
  #_checkOptions: ->
    #unless @opts.items.length > 0
      #throw new Error 'QingSortable: option items is required'
    #unless @groups.length > 0
      #throw new Error 'QingSortable: option container is required'
  #_setDragImage: (e)->
    #@dragImage?.remove()
    #$item = $(e.currentTarget)
    #@dragImage = $item.clone().addClass('qing-sortable-dragimage')
    #@dragImage.css
      #width: $item.width()
      #height: $item.height()
    #@dragImage.prependTo $item.parent()
    #e.originalEvent.dataTransfer.setDragImage(
      #@dragImage[0],
      #e.pageX-$item.offset().left,
      #e.pageY-$item.offset().top
    #)
  #_cacheMousePosition: (e)->
    #$item = $(e.currentTarget)
    #@mousePosition =
      #x: e.pageX-$item.offset().left
      #y: e.pageY-$item.offset().top
  #_cacheContainerDimensions: ()->
    #@groupsDimensions = allContainers.map((index, container)=>
      #@_getElementDimension container
    #).get()
  #_cacheItemPositions: ()->
    #@itemCenters = allItems.map((index, item)->
      #$el = $(item)
      #offset = $el.offset()
      #element: item
      #x: offset.left + $el.outerWidth()/2
      #y: offset.top + $el.outerHeight()/2
    #).get()
  #_getElementDimension: (element)->
    #offset = $(element).offset()
    #top: offset.top
    #left: offset.left
    #bottom: offset.top + $(element).outerHeight()
    #right: offset.left + $(element).outerWidth()
    #element: element
  #_findNearestContainer: (itemDimension)->
    #list = $.map(@groupsDimensions, (d, index)=>
      #diff = compareDimensions(d, itemDimension)
      #delta: diff.delta
      #position: diff.position
      #dimension: d
      #element: d.element
    #).sort((a,b)-> a.delta - b.delta)
    #list[0].element
  #_getItemDimension: (e)->
    #dimension =
      #left: e.pageX - @mousePosition.x
      #top: e.pageY - @mousePosition.y
    #dimension.right = dimension.left + @activeItem.outerWidth()
    #dimension.bottom = dimension.top + @activeItem.outerHeight()
    #dimension
  #_findNearestItem: (itemDimension, container)->
    #items = $(container).find(@opts.items).not(@placeholder)
    #center =
      #x: (itemDimension.left + itemDimension.right) /2
      #y: (itemDimension.top + itemDimension.bottom) /2

    #all = items.map((index, el)->
      #$el = $(el)
      #offset = $el.offset()
      #c =
        #x: offset.left + $el.outerWidth()/2
        #y: offset.top + $el.outerHeight()/2
      #delta = length(center.x - c.x, center.y - c.y)
      #delta: delta
      #element: el
      #center: c
      #xDelta: c.x - center.x
      #yDelta: c.y - center.y
    #).sort (a,b)->
      #a.delta - b.delta

    #all[0]

  #_bind: ->
    #@scope = $ @opts.scope

    #@scope.on "dragstart.qingSortable#{@_cid}", @opts.items, (e)=>
      #$item = $ e.target
      #return unless $.contains @groups[0], e.target
      #@isDragging = true
      #@_cacheContainerDimensions()
      #@_cacheItemPositions()
      #@_cacheMousePosition(e)
      #@_setDragImage e
      #$item.addClass 'qing-sortable-placeholder'
      #@activeItem = $item
      #@placeholder = $item.clone()
    #@scope.on "dragover.qingSortable#{@_cid}",  (e)=>
      #e.preventDefault()
      #return unless @isDragging
      #return if e.target is @activeItem[0]
      #return if $.contains @activeItem[0], e.target
      #itemDimension = @_getItemDimension e
      #nearestContainer = @_findNearestContainer itemDimension
      #nearItem = @_findNearestItem itemDimension, nearestContainer
      #method
      #if @opts.axis is 'x'
        #method = if nearItem.xDelta>0 then 'before' else 'after'
      #else
        #method = if nearItem.yDelta>0 then 'before' else 'after'
      #$(nearItem.element)[method] @placeholder

    #@scope.on "dragend.qingSortable#{@_cid}", @opts.items, (e)=>
      #return unless @isDragging
      #@activeItem.removeClass('qing-sortable-placeholder qing-sortable-hide')
      #if @placeholder and $.contains document,@placeholder[0]
        #@placeholder.replaceWith @activeItem
        #@placeholder = null
      #ACTIVE = null
    #@scope.on "dragleave.qingSortable#{@_cid}", @opts.items, (e)=>
      #return unless @isDragging
      #if e.currentTarget is @activeItem[0]
        #@activeItem.removeClass('qing-sortable-placeholder')
          #.addClass 'qing-sortable-hide'
  #destroy: ->
    #allItems = allItems.not @items
    #allContainers = allContainers.not @contains
    #@scope.off ".qingSortable#{@_cid}"

module.exports = QingSortable
