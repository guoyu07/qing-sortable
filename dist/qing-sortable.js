/**
 * qing-sortable v0.0.1
 * http://mycolorway.github.io/qing-sortable
 *
 * Copyright Mycolorway Design
 * Released under the MIT license
 * http://mycolorway.github.io/qing-sortable/license.html
 *
 * Date: 2016-10-24
 */
;(function(root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jquery'),require('qing-module'));
  } else {
    root.QingSortable = factory(root.jQuery,root.QingModule);
  }
}(this, function ($,QingModule) {
var define, module, exports;
var b = require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({"qing-sortable":[function(require,module,exports){
var $active, $placeholder, QingSortable, allItems, theContainer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

$active = null;

$placeholder = null;

allItems = $([]);

theContainer = null;

QingSortable = (function(superClass) {
  extend(QingSortable, superClass);

  QingSortable.opts = {
    container: null,
    items: null,
    axis: 'x'
  };

  function QingSortable(opts) {
    QingSortable.__super__.constructor.apply(this, arguments);
    this.items = $(this.opts.items);
    this.container = $(this.opts.container);
    this._checkOptions();
    this.items.data('qingSortable', this);
    this.container.data('qingSortableItems', this.items);
    allItems = allItems.add(this.items);
    this.opts = $.extend({}, QingSortable.opts, this.opts);
    this._render();
    this._bind();
  }

  QingSortable.prototype._checkOptions = function() {
    if (!(this.items.length > 0)) {
      throw new Error('QingSortable: option items is required');
    }
    if (!(this.container.length > 0)) {
      throw new Error('QingSortable: option container is required');
    }
  };

  QingSortable.prototype._render = function() {
    return this.items.each(function(index, el) {
      return el.draggable = true;
    });
  };

  QingSortable.prototype._setDragImage = function(e) {
    var $item, ref;
    if ((ref = this.dragImage) != null) {
      ref.remove();
    }
    $item = $(e.currentTarget);
    this.dragImage = $item.clone().addClass('qing-sortable-dragimage');
    this.dragImage.css({
      width: $item.width(),
      height: $item.height()
    });
    this.dragImage.prependTo($item.parent());
    return e.originalEvent.dataTransfer.setDragImage(this.dragImage[0], e.pageX - $item.offset().left, e.pageY - $item.offset().top);
  };

  QingSortable.prototype._getMousePosition = function(e) {
    var $item;
    $item = $(e.currentTarget);
    return {
      x: e.pageX - $item.offset().left,
      y: e.pageY - $item.offset().top
    };
  };

  QingSortable.prototype._onStart = function($item) {
    this.dragging = true;
    return $active = $item;
  };

  QingSortable.prototype._onEnd = function() {
    this.dragging = false;
    return $active = null;
  };

  QingSortable.prototype._shouldCalculatePosition = function(e) {
    if (!this.dragging) {
      return false;
    }
    if ($(e.target).data('qingSortable')) {
      return false;
    }
    if (e.target === $placeholder[0]) {
      return false;
    }
    if (e.target === $active[0]) {
      return false;
    }
    return true;
  };

  QingSortable.prototype._bind = function() {
    this.items.on('dragstart.qingSortable', (function(_this) {
      return function(e) {
        var $item;
        _this._setDragImage(e);
        _this.mousePosition = _this._getMousePosition(e);
        $item = $(e.currentTarget).addClass('qing-sortable-placeholder');
        $placeholder = $item.clone().attr('qing-sortable-placeholder', true);
        return _this._onStart($item);
      };
    })(this));
    this.items.on('dragend.qingSortable', (function(_this) {
      return function(e) {
        var $item;
        $item = $(e.currentTarget).removeClass('qing-sortable-placeholder qing-sortable-hide');
        if ($.contains(document, $placeholder[0])) {
          $item.insertAfter($placeholder);
          $placeholder.detach();
        }
        return _this._onEnd();
      };
    })(this));
    this.container.on('dragenter.qingSortable', (function(_this) {
      return function(e) {
        _this.inContainer = true;
        return theContainer = _this.container;
      };
    })(this));
    this.container.on('dragleave.qingSortable', (function(_this) {
      return function(e) {
        if (e.target === e.currentTarget) {
          _this.inContainer = false;
          return theContainer = null;
        }
      };
    })(this));
    $(document).on('dragover.qingSortable', (function(_this) {
      return function(e) {
        var center, nearest, scope, sorted;
        if (!_this._shouldCalculatePosition(e)) {
          return;
        }
        $placeholder.detach();
        center = {
          x: e.pageX - _this.mousePosition.x + $active.outerWidth() / 2,
          y: e.pageY - _this.mousePosition.y + $active.outerHeight() / 2
        };
        scope = theContainer ? theContainer.data('qingSortableItems') : allItems;
        sorted = _this._getSortedCenters(scope, center);
        nearest = sorted[0].element;
        if (center[_this.opts.axis] < sorted[0].center[_this.opts.axis]) {
          $(nearest).before($placeholder);
        } else {
          $(nearest).after($placeholder);
        }
        return $active.addClass('qing-sortable-hide');
      };
    })(this));
    return this.items.on('dragenter.qingSortable', (function(_this) {
      return function(e) {
        var $item, index;
        if (!_this.inContainer) {
          return;
        }
        $item = $(e.currentTarget);
        index = $.contains(document, $placeholder[0]) ? $placeholder.index() : $active.index();
        if (index < $item.index()) {
          $item.after($placeholder);
        } else {
          $item.before($placeholder);
        }
        return $active.addClass('qing-sortable-hide');
      };
    })(this));
  };

  QingSortable.prototype._getSortedCenters = function(items, center) {
    var all;
    all = items.map(function(index, el) {
      var $el, c, delta, offset;
      $el = $(el);
      offset = $el.offset();
      c = {
        x: offset.left + $el.outerWidth() / 2,
        y: offset.top + $el.outerHeight() / 2
      };
      delta = Math.sqrt(Math.pow(center.x - c.x, 2) + Math.pow(center.y - c.y, 2));
      return {
        delta: delta,
        element: el,
        center: c
      };
    });
    return all.sort(function(a, b) {
      return a.delta - b.delta;
    });
  };

  QingSortable.prototype.destroy = function() {
    var ref;
    allItems = allItems.not(this.items);
    this.items.off('.qingSortable');
    if ($placeholder != null) {
      $placeholder.remove();
    }
    return (ref = this.dragImage) != null ? ref.remove() : void 0;
  };

  return QingSortable;

})(QingModule);

module.exports = QingSortable;

},{}]},{},[]);

return b('qing-sortable');
}));
