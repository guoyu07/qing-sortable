active = null
placeholder = null
enter = false
throttle = (fn, duration=100) ->
  timer = null
  return ()->
    context = @
    args = arguments
    window.clearTimeout timer
    timer = window.setTimeout ()->
      fn.apply context, args
    , duration

class QingSortable extends QingModule

  @opts:
    container: null
    connect: null
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
      @dragging = true
      $item = $(e.currentTarget)
      if @opts.customDragImage
        dragImage = $item.clone().addClass('qing-sortable-dragimage')
        dragImage.prependTo $item.parent()
        e.originalEvent.dataTransfer.setDragImage(
          dragImage[0],
          e.pageX-$item.offset().left,
          e.pageY-$item.offset().top
        )

      @relative =
        x: e.pageX-$item.offset().left
        y: e.pageY-$item.offset().top
      active = $item
      $item.addClass('qing-sortable-placeholder')
      placeholder = $item.clone().attr('data-sort-placeholder', true)

    @sortable.on 'dragend.qingSortable', (e) =>
      $item = $(e.currentTarget)
      $item.removeClass('qing-sortable-placeholder')
      $item.removeClass 'xxx'
      if $.contains document, placeholder[0]
        $item.insertAfter(placeholder)
        placeholder.detach()
      active = null
      @dragging = false


    $(@opts.container).on 'dragenter.qingSortable', ()->
      enter = true
    $(@opts.container).on 'dragleave.qingSortable', ()->
      enter = false

    $(document).on 'dragover.qingSortable', (e)=>
      return if @sortable.filter(e.target).length isnt 0
      return if $(@opts.container).filter(e.target).length > 0
      return if $.contains($(@opts.container)[0], e.target)
      if @opts.connect
        return if $(@opts.connect).filter(e.target).length > 0
        return if $.contains($(@opts.connect)[0], e.target)
      return if enter
      return unless @dragging

      placeholder.detach()
      center =
        x: e.pageX - @relative.x + active.outerWidth() / 2
        y: e.pageY - @relative.y + active.outerHeight() / 2


      all =  @sortable.map (index, el)->
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
      sorted = all.sort (a,b)->
        a.delta - b.delta
      nearest = sorted[0].element

      method
      if @opts.type is 'inline'
        method = if center.x < sorted[0].center.x then 'before' else 'after'
      else
        method = if center.y < sorted[0].center.y then 'before' else 'after'

      $(nearest)[method](placeholder).addClass('yyy')
      .siblings().removeClass('yyy').end()

    @sortable.on 'dragenter.qingSortable', (e)=>
      $item = $ e.currentTarget

      inn = $(@opts.container).add(@opts.connect).filter (index, el)->
        $.contains(el, e.currentTarget)

      return unless inn.length > 0

      index = if $.contains document, placeholder[0]
      then placeholder.index()
      else active.index()

      method = if index < $item.index()
      then 'after' else 'before'
      $item[method] placeholder

      active.addClass('xxx')

  destroy: ->
    @sortable.off('.qingSortable')
    placeholder?.remove()

module.exports = QingSortable
