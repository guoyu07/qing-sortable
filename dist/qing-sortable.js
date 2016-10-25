/**
 * qing-sortable v0.0.1
 * http://mycolorway.github.io/qing-sortable
 *
 * Copyright Mycolorway Design
 * Released under the MIT license
 * http://mycolorway.github.io/qing-sortable/license.html
 *
 * Date: 2016-10-25
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
var QingSortable, allContainers, allItems, cid, compareDimensions, length, theContainer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

allItems = $([]);

allContainers = $([]);

theContainer = null;

cid = 1;

length = function(x, y) {
  return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
};

compareDimensions = function(d1, d2) {
  if (d2.left > d1.right) {
    if (d2.bottom < d1.top) {
      return {
        delta: length(d2.left - d1.right, d1.top - d2.bottom),
        position: 9
      };
    } else if (d2.top > d1.bottom) {
      return {
        delta: length(d2.left - d1.right, d2.top - d1.bottom),
        position: 3
      };
    } else {
      return {
        delta: d2.left - d1.right,
        position: 2
      };
    }
  } else if (d2.right < d1.left) {
    if (d2.bottom < d1.top) {
      return {
        delta: length(d1.left - d2.right, d1.top - d2.bottom),
        position: 7
      };
    } else if (d2.top > d1.bottom) {
      return {
        delta: length(d1.left - d2.right, d2.top - d1.bottom),
        position: 5
      };
    } else {
      return {
        delta: d1.left - d2.right,
        position: 6
      };
    }
  } else if (d2.bottom < d1.top) {
    return {
      delta: d1.top - d2.bottom,
      position: 8
    };
  } else if (d2.top > d1.bottom) {
    return {
      delta: d2.top - d1.bottom,
      position: 4
    };
  } else {
    return {
      delta: 0,
      position: 1
    };
  }
};

QingSortable = (function(superClass) {
  extend(QingSortable, superClass);

  QingSortable.prototype.activeItem = null;

  QingSortable.opts = {
    scope: document,
    container: null,
    items: '[draggable=true]',
    axis: 'x'
  };

  function QingSortable(opts) {
    QingSortable.__super__.constructor.apply(this, arguments);
    this.opts = $.extend({}, QingSortable.opts, this.opts);
    this.groups = $(this.opts.container);
    this.items = this.groups.find(this.opts.items);
    this._checkOptions();
    this._cid = cid++;
    allContainers = allContainers.add(this.groups);
    allItems = allItems.add(this.items);
    this._bind();
  }

  QingSortable.prototype._checkOptions = function() {
    if (!(this.opts.items.length > 0)) {
      throw new Error('QingSortable: option items is required');
    }
    if (!(this.groups.length > 0)) {
      throw new Error('QingSortable: option container is required');
    }
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

  QingSortable.prototype._cacheMousePosition = function(e) {
    var $item;
    $item = $(e.currentTarget);
    return this.mousePosition = {
      x: e.pageX - $item.offset().left,
      y: e.pageY - $item.offset().top
    };
  };

  QingSortable.prototype._cacheContainerDimensions = function() {
    return this.groupsDimensions = allContainers.map((function(_this) {
      return function(index, container) {
        return _this._getElementDimension(container);
      };
    })(this)).get();
  };

  QingSortable.prototype._cacheItemPositions = function() {
    return this.itemCenters = allItems.map(function(index, item) {
      var $el, offset;
      $el = $(item);
      offset = $el.offset();
      return {
        element: item,
        x: offset.left + $el.outerWidth() / 2,
        y: offset.top + $el.outerHeight() / 2
      };
    }).get();
  };

  QingSortable.prototype._getElementDimension = function(element) {
    var offset;
    offset = $(element).offset();
    return {
      top: offset.top,
      left: offset.left,
      bottom: offset.top + $(element).outerHeight(),
      right: offset.left + $(element).outerWidth(),
      element: element
    };
  };

  QingSortable.prototype._findNearestContainer = function(itemDimension) {
    var list;
    list = $.map(this.groupsDimensions, (function(_this) {
      return function(d, index) {
        var diff;
        diff = compareDimensions(d, itemDimension);
        return {
          delta: diff.delta,
          position: diff.position,
          dimension: d,
          element: d.element
        };
      };
    })(this)).sort(function(a, b) {
      return a.delta - b.delta;
    });
    return list[0].element;
  };

  QingSortable.prototype._getItemDimension = function(e) {
    var dimension;
    dimension = {
      left: e.pageX - this.mousePosition.x,
      top: e.pageY - this.mousePosition.y
    };
    dimension.right = dimension.left + this.activeItem.outerWidth();
    dimension.bottom = dimension.top + this.activeItem.outerHeight();
    return dimension;
  };

  QingSortable.prototype._findNearestItem = function(itemDimension, container) {
    var all, center, items;
    items = $(container).find(this.opts.items).not(this.placeholder);
    center = {
      x: (itemDimension.left + itemDimension.right) / 2,
      y: (itemDimension.top + itemDimension.bottom) / 2
    };
    all = items.map(function(index, el) {
      var $el, c, delta, offset;
      $el = $(el);
      offset = $el.offset();
      c = {
        x: offset.left + $el.outerWidth() / 2,
        y: offset.top + $el.outerHeight() / 2
      };
      delta = length(center.x - c.x, center.y - c.y);
      return {
        delta: delta,
        element: el,
        center: c,
        xDelta: c.x - center.x,
        yDelta: c.y - center.y
      };
    }).sort(function(a, b) {
      return a.delta - b.delta;
    });
    return all[0];
  };

  QingSortable.prototype._bind = function() {
    this.scope = $(this.opts.scope);
    this.scope.on("dragstart.qingSortable" + this._cid, this.opts.items, (function(_this) {
      return function(e) {
        var $item;
        $item = $(e.target);
        if (!$.contains(_this.groups[0], e.target)) {
          return;
        }
        _this.isDragging = true;
        _this._cacheContainerDimensions();
        _this._cacheItemPositions();
        _this._cacheMousePosition(e);
        _this._setDragImage(e);
        $item.addClass('qing-sortable-placeholder');
        _this.activeItem = $item;
        return _this.placeholder = $item.clone();
      };
    })(this));
    this.scope.on("dragover.qingSortable" + this._cid, (function(_this) {
      return function(e) {
        var itemDimension, method, nearItem, nearestContainer;
        e.preventDefault();
        if (!_this.isDragging) {
          return;
        }
        if (e.target === _this.activeItem[0]) {
          return;
        }
        if ($.contains(_this.activeItem[0], e.target)) {
          return;
        }
        itemDimension = _this._getItemDimension(e);
        nearestContainer = _this._findNearestContainer(itemDimension);
        nearItem = _this._findNearestItem(itemDimension, nearestContainer);
        method;
        if (_this.opts.axis === 'x') {
          method = nearItem.xDelta > 0 ? 'before' : 'after';
        } else {
          method = nearItem.yDelta > 0 ? 'before' : 'after';
        }
        return $(nearItem.element)[method](_this.placeholder);
      };
    })(this));
    this.scope.on("dragend.qingSortable" + this._cid, this.opts.items, (function(_this) {
      return function(e) {
        var ACTIVE;
        if (!_this.isDragging) {
          return;
        }
        _this.activeItem.removeClass('qing-sortable-placeholder qing-sortable-hide');
        if (_this.placeholder && $.contains(document, _this.placeholder[0])) {
          _this.placeholder.replaceWith(_this.activeItem);
          _this.placeholder = null;
        }
        return ACTIVE = null;
      };
    })(this));
    return this.scope.on("dragleave.qingSortable" + this._cid, this.opts.items, (function(_this) {
      return function(e) {
        if (!_this.isDragging) {
          return;
        }
        if (e.currentTarget === _this.activeItem[0]) {
          return _this.activeItem.removeClass('qing-sortable-placeholder').addClass('qing-sortable-hide');
        }
      };
    })(this));
  };

  QingSortable.prototype.destroy = function() {
    allItems = allItems.not(this.items);
    allContainers = allContainers.not(this.contains);
    return this.scope.off(".qingSortable" + this._cid);
  };

  return QingSortable;

})(QingModule);

module.exports = QingSortable;

},{}]},{},[]);

return b('qing-sortable');
}));
