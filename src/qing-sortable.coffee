class QingSortable extends QingModule
  @id: 1

  @opts:
    el: document
    groups: null
    items: null
    plugins: []

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

  _init: ->
    @el = $ @opts.el

    @el.addClass "qing-sortable"
    @id = QingSortable.id++
    @_bind()

  _appendHelper: ($item)->
    @helper = $item.clone()
      .addClass('qing-sortable-helper')
      .outerWidth $item.outerWidth()
      .outerHeight $item.outerHeight()
      .prependTo $item.parent()

  _bind: ->
    itemSelector = @opts.items

    @el.on "dragstart.qingSortable#{@id}", itemSelector, (e)=>
      $item = $ e.currentTarget
      offset = $item.offset()
      @_onDragStart($item)
      e.originalEvent.dataTransfer.setDragImage(
        @helper.get(0),
        e.pageX-offset.left,
        e.pageY-offset.top
      )
      e.stopPropagation()

    @el.on "dragover.qingSortable#{@id}", (e) =>
      @_onDragOver(e.pageX, e.pageY)
      e.stopPropagation()

    @el.on "dragend.qingSortable#{@id}", (e) =>
      @_onDragEnd()
      e.stopPropagation()

  _onDragStart: ($item)->
    @el.addClass "qing-sortable-sorting"
    @activeItem = $item
    @trigger "sortstart", [@activeItem]
    @_appendHelper($item)
    @_generatePlaceholder($item)
    @_cacheDimensions()

  _lastDrag: null
  _lastNear: null
  _onDragOver: (x,y)->
    return unless @activeItem
    return if @_lastDrag and x is @_lastDrag[0] and y is @_lastDrag[1]
    @_lastDrag = [x,y]
    near = @_findNearest(x,y)
    return unless near.dimension
    return if @_placeholderDistance([x,y]) < near.dimension.delta

    if near.type is 'item'
      @_movePlaceholderTo near.dimension, [x,y]
    else
      $(near.dimension.element).append @placeholder
    @activeItem.removeClass('qing-sortable-placeholder')
    @activeItem.addClass 'qing-sortable-hide'
    @_updateDimensions()

  _placeholderDistance: (mouse, delta)->
    return Infinity unless @placeholder
    d = QingSortable.getElementDimension(@placeholder)
    QingSortable.pointToDimension(mouse, d)

  _onDragEnd: ()->
    @el.removeClass "qing-sortable-sorting"
    return unless @activeItem
    @activeItem.removeClass 'qing-sortable-placeholder qing-sortable-hide'
    @placeholder.replaceWith @activeItem
    @helper.remove()
    @trigger "sortend", [@activeItem]
    @helper = null
    @activeItem = null
    @placeholder = null
    @_lastDrag = null

  destroy: ->
    @el.removeClass 'qing-sortable'
      .off ".qingSortable#{@id}"
    @helper?.remove()
    @helper = null
    @activeItem = null
    @placeholder?.remove()
    @placeholder = null
    @_lastDrag = null

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

  _generatePlaceholder: ($item)->
    @placeholder = $item.clone().addClass 'qing-sortable-placeholder'

  _findNearest: (x,y)->
    nearest = (dimensions)->
      dimensions.map((d)->
        d.delta = QingSortable.pointToDimension [x,y], d
        d
      ).sort((a,b)->
        a.delta - b.delta
      )[0]
    if @opts.groups
      group = nearest(@dimensions)
      if group.children and group.children.length > 0
        type: 'item'
        dimension: nearest(group.children)
      else
        type: 'group'
        dimension: group
    else
      type: 'item'
      dimension: nearest(@dimensions)

  _cacheDimensions: ()->
    collectItemDimensions = ($el)=>
      $el.find(@opts.items).not('.qing-sortable-helper').map((index, item)=>
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

  _updateDimensions: ->
    # 默认 drag 过程中 items 不会增加或减少
    update = (i,index)->
      offset = $(i.element).offset()
      i.left = offset.left
      i.top = offset.top
      if i.children
        i.children.map update

    @dimensions.map update

module.exports = QingSortable
