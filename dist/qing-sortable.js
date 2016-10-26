/**
 * qing-sortable v0.0.1
 * http://mycolorway.github.io/qing-sortable
 *
 * Copyright Mycolorway Design
 * Released under the MIT license
 * http://mycolorway.github.io/qing-sortable/license.html
 *
 * Date: 2016-10-26
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
var QingSortable,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

QingSortable = (function(superClass) {
  extend(QingSortable, superClass);

  function QingSortable() {
    return QingSortable.__super__.constructor.apply(this, arguments);
  }

  QingSortable.opts = {
    el: document,
    groups: null,
    items: null,
    plugins: []
  };

  QingSortable.id = 1;

  QingSortable.getElementDimension = function(el) {
    var $el, height, offset, width;
    $el = $(el);
    offset = $el.offset();
    width = $el.outerWidth();
    height = $el.outerHeight();
    return {
      left: offset.left,
      top: offset.top,
      width: width,
      height: height,
      center: {
        left: offset.left + height / 2,
        top: offset.top + height / 2
      },
      element: el
    };
  };

  QingSortable.excluded = '[data-qing-sortable-excluded]';

  QingSortable.pointToDimension = function(p, d) {
    var abs, center, dx, dy, max, sqrt;
    max = Math.max;
    abs = Math.abs;
    sqrt = Math.sqrt;
    center = {
      left: d.left + d.width / 2,
      top: d.top + d.height / 2
    };
    dx = max(abs(p[0] - center.left) - d.width / 2, 0);
    dy = max(abs(p[1] - center.top) - d.height / 2, 0);
    return sqrt(dx * dx + dy * dy);
  };

  QingSortable.prototype.activeItem = null;

  QingSortable.prototype.placeholder = null;

  QingSortable.prototype._setOptions = function(opts) {
    this.opts = $.extend({}, QingSortable.opts, opts);
    if (!this.opts.items) {
      throw new Error('option items is required');
    }
  };

  QingSortable.prototype._init = function() {
    this.el = $(this.opts.el);
    this.id = QingSortable.id++;
    return this._bind();
  };

  QingSortable.prototype._appendHelper = function($item) {
    this.helper = $item.clone().addClass('qing-sortable-helper');
    this.helper.outerWidth($item.outerWidth());
    this.helper.outerHeight($item.outerHeight());
    this.helper.attr('data-qing-sortable-excluded', true);
    return this.helper.prependTo($item.parent());
  };

  QingSortable.prototype._bind = function() {
    var itemSelector;
    itemSelector = this.opts.items;
    this.el.on("dragstart.qingSortable" + this.id, itemSelector, (function(_this) {
      return function(e) {
        var $item, offset;
        $item = $(e.currentTarget);
        offset = $item.offset();
        _this._onDragStart($item);
        return e.originalEvent.dataTransfer.setDragImage(_this.helper.get(0), e.pageX - offset.left, e.pageY - offset.top);
      };
    })(this));
    this.el.on("dragover.qingSortable" + this.id, (function(_this) {
      return function(e) {
        return _this._onDragOver(e.pageX, e.pageY);
      };
    })(this));
    return this.el.on("dragend.qingSortable" + this.id, (function(_this) {
      return function(e) {
        return _this._onDragEnd();
      };
    })(this));
  };

  QingSortable.prototype._onDragStart = function($item) {
    this.activeItem = $item;
    this._appendHelper($item);
    this._generatePlaceholder($item);
    return this._cacheDimensions();
  };

  QingSortable.prototype._lastDrag = null;

  QingSortable.prototype._lastNear = null;

  QingSortable.prototype._onDragOver = function(x, y) {
    if (!this.activeItem) {
      return;
    }
    if (this._lastDrag && x === this._lastDrag[0] && y === this._lastDrag[1]) {
      return;
    }
    this._lastDrag = [x, y];
    this.nearDimension = this._findNearItemDimension(x, y);
    if (!this.nearDimension) {
      return;
    }
    if (this._nearPlaceholder([x, y], this.nearDimension)) {
      return;
    }
    this._movePlaceholderTo(this.nearDimension, [x, y]);
    this.activeItem.removeClass('qing-sortable-placeholder');
    this.activeItem.addClass('qing-sortable-hide');
    return this._updateDimensions();
  };

  QingSortable.prototype._nearPlaceholder = function(mouse, nearDimension) {
    var d;
    if (this.placeholder) {
      d = QingSortable.getElementDimension(this.placeholder);
      return QingSortable.pointToDimension(mouse, d) < nearDimension.delta;
    }
  };

  QingSortable.prototype._onDragEnd = function() {
    if (!this.activeItem) {
      return;
    }
    this.activeItem.removeClass('qing-sortable-placeholder qing-sortable-hide');
    this.placeholder.replaceWith(this.activeItem);
    this.helper.remove();
    this.helper = null;
    this.activeItem = null;
    this.placeholder = null;
    this.nearDimension = null;
    return this._lastDrag = null;
  };

  QingSortable.prototype.destroy = function() {
    var ref, ref1;
    this.el.off(".qingSortable" + this.id);
    if ((ref = this.helper) != null) {
      ref.remove();
    }
    this.helper = null;
    this.activeItem = null;
    if ((ref1 = this.placeholder) != null) {
      ref1.remove();
    }
    this.placeholder = null;
    this.nearDimension = null;
    return this._lastDrag = null;
  };

  QingSortable.prototype._movePlaceholderTo = function(dimension, mousePoint) {
    var $el;
    $el = $(dimension.element);
    if (this.opts.axis === 'x') {
      if (mousePoint[0] < dimension.center.left) {
        return $el.before(this.placeholder);
      } else {
        return $el.after(this.placeholder);
      }
    } else {
      if (mousePoint[1] < dimension.center.top) {
        return $el.before(this.placeholder);
      } else {
        return $el.after(this.placeholder);
      }
    }
  };

  QingSortable.prototype._generatePlaceholder = function($item) {
    return this.placeholder = $item.clone().addClass('qing-sortable-placeholder');
  };

  QingSortable.prototype._findNearItemDimension = function(x, y) {
    var nearest;
    nearest = function(dimensions) {
      return dimensions.map(function(d) {
        d.delta = QingSortable.pointToDimension([x, y], d);
        return d;
      }).sort(function(a, b) {
        return a.delta - b.delta;
      })[0];
    };
    if (this.opts.groups) {
      return nearest(nearest(this.dimensions).children);
    } else {
      return nearest(this.dimensions);
    }
  };

  QingSortable.prototype._cacheDimensions = function() {
    var collectItemDimensions;
    collectItemDimensions = (function(_this) {
      return function($el) {
        return $el.find(_this.opts.items).not(QingSortable.excluded).map(function(index, item) {
          return QingSortable.getElementDimension(item);
        }).get();
      };
    })(this);
    return this.dimensions = this.opts.groups ? this.el.find(this.opts.groups).map((function(_this) {
      return function(index, group) {
        var d;
        d = QingSortable.getElementDimension(group);
        d.children = collectItemDimensions($(group), d.children);
        return d;
      };
    })(this)).get() : collectItemDimensions(this.el);
  };

  QingSortable.prototype._updateDimensions = function() {
    var update;
    update = function(i, index) {
      var offset;
      offset = $(i.element).offset();
      i.left = offset.left;
      i.top = offset.top;
      if (i.children) {
        return i.children.map(update);
      }
    };
    return this.dimensions.map(update);
  };

  return QingSortable;

})(QingModule);

module.exports = QingSortable;

},{}]},{},[]);

return b('qing-sortable');
}));
