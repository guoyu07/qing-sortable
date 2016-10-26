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

  _appendHelper: ($item)->
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
      @_onDragStart($item)
      e.originalEvent.dataTransfer.setDragImage(
        @helper.get(0),
        e.pageX-offset.left,
        e.pageY-offset.top
      )
    @el.on "dragover.qingSortable#{@id}", (e)=>
      @_onDragOver(e.pageX, e.pageY)
    @el.on "dragend.qingSortable#{@id}", (e)=>
      @_onDragEnd()

  _onDragStart: ($item)->
    @activeItem = $item
    @_appendHelper($item)
    @_generatePlaceholder($item)
    @_cacheDimensions()

  _lastDrag: null
  _lastNear: null
  _onDragOver: (x,y)->
    return unless @activeItem
    return if @_lastDrag and x is @_lastDrag[0] and y is @_lastDrag[1]
    @_lastDrag = [x,y]
    @nearDimension = @_findNearItemDimension(x,y)
    return unless @nearDimension
    return if @_nearPlaceholder([x,y], @nearDimension)

    @_movePlaceholderTo @nearDimension, [x,y]
    @activeItem.removeClass('qing-sortable-placeholder')
    @activeItem.addClass 'qing-sortable-hide'
    @_updateDimensions()

  _nearPlaceholder: (mouse, nearDimension)->
    if @placeholder
      d = QingSortable.getElementDimension(@placeholder)
      QingSortable.pointToDimension(mouse, d) < nearDimension.delta

  _onDragEnd: ()->
    return unless @activeItem
    @activeItem.removeClass 'qing-sortable-placeholder qing-sortable-hide'
    @placeholder.replaceWith @activeItem
    @helper.remove()
    @helper = null
    @activeItem = null
    @placeholder = null
    @nearDimension = null
    @_lastDrag = null

  destroy: ->
    @el.off ".qingSortable#{@id}"
    @helper?.remove()
    @helper = null
    @activeItem = null
    @placeholder?.remove()
    @placeholder = null
    @nearDimension = null
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

  _findNearItemDimension: (x,y)->
    nearest = (dimensions)->
      dimensions.map((d)->
        d.delta = QingSortable.pointToDimension [x,y], d
        d
      ).sort((a,b)->
        a.delta - b.delta
      )[0]
    if @opts.groups
      nearest(nearest(@dimensions).children)
    else
      nearest(@dimensions)

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
    # 默认 drag 过程中 items 不会增加或减少
    update = (i,index)->
      offset = $(i.element).offset()
      i.left = offset.left
      i.top = offset.top
      if i.children
        i.children.map update

    @dimensions.map update

module.exports = QingSortable
