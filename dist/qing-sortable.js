/**
 * qing-sortable v0.0.1
 * http://mycolorway.github.io/qing-sortable
 *
 * Copyright Mycolorway Design
 * Released under the MIT license
 * http://mycolorway.github.io/qing-sortable/license.html
 *
 * Date: 2016-10-20
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
var QingSortable, active, enter, placeholder, throttle,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

active = null;

placeholder = null;

enter = false;

throttle = function(fn, duration) {
  var timer;
  if (duration == null) {
    duration = 100;
  }
  timer = null;
  return function() {
    var args, context;
    context = this;
    args = arguments;
    window.clearTimeout(timer);
    return timer = window.setTimeout(function() {
      return fn.apply(context, args);
    }, duration);
  };
};

QingSortable = (function(superClass) {
  extend(QingSortable, superClass);

  QingSortable.opts = {
    container: null,
    connect: null,
    sortable: null,
    customDragImage: false
  };

  function QingSortable(opts) {
    QingSortable.__super__.constructor.apply(this, arguments);
    this.sortable = $(this.opts.sortable);
    if (!(this.sortable.length > 0)) {
      throw new Error('QingSortable: option sortable is required');
    }
    this.opts = $.extend({}, QingSortable.opts, this.opts);
    this._render();
    this._bind();
  }

  QingSortable.prototype._render = function() {
    return this.sortable.each(function(index, el) {
      return el.draggable = true;
    });
  };

  QingSortable.prototype._bind = function() {
    this.sortable.on('dragstart.qingSortable', (function(_this) {
      return function(e) {
        var $item, dragImage;
        _this.dragging = true;
        $item = $(e.currentTarget);
        if (_this.opts.customDragImage) {
          dragImage = $item.clone().addClass('qing-sortable-dragimage');
          dragImage.prependTo($item.parent());
          e.originalEvent.dataTransfer.setData('Test', 'some data');
          e.originalEvent.dataTransfer.setDragImage(dragImage[0], e.pageX - $item.offset().left, e.pageY - $item.offset().top);
        }
        _this.relative = {
          x: e.pageX - $item.offset().left,
          y: e.pageY - $item.offset().top
        };
        active = $item;
        $item.addClass('qing-sortable-placeholder');
        return placeholder = $item.clone().attr('data-sort-placeholder', true);
      };
    })(this));
    this.sortable.on('dragend.qingSortable', (function(_this) {
      return function(e) {
        var $item;
        $item = $(e.currentTarget);
        $item.removeClass('qing-sortable-placeholder');
        $item.removeClass('xxx');
        if ($.contains(document, placeholder[0])) {
          $item.insertAfter(placeholder);
          placeholder.detach();
        }
        active = null;
        return _this.dragging = false;
      };
    })(this));
    $(this.opts.container).on('dragenter.qingSortable', function() {
      return enter = true;
    });
    $(this.opts.container).on('dragleave.qingSortable', function() {
      return enter = false;
    });
    $(document).on('dragover.qingSortable', (function(_this) {
      return function(e) {
        var all, center, method, nearest, sorted;
        if (_this.sortable.filter(e.target).length !== 0) {
          return;
        }
        if ($(_this.opts.container).filter(e.target).length > 0) {
          return;
        }
        if ($.contains($(_this.opts.container)[0], e.target)) {
          return;
        }
        if (_this.opts.connect) {
          if ($(_this.opts.connect).filter(e.target).length > 0) {
            return;
          }
          if ($.contains($(_this.opts.connect)[0], e.target)) {
            return;
          }
        }
        if (enter) {
          return;
        }
        if (!_this.dragging) {
          return;
        }
        placeholder.detach();
        center = {
          x: e.pageX - _this.relative.x + active.outerWidth() / 2,
          y: e.pageY - _this.relative.y + active.outerHeight() / 2
        };
        all = _this.sortable.map(function(index, el) {
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
        sorted = all.sort(function(a, b) {
          return a.delta - b.delta;
        });
        nearest = sorted[0].element;
        method;
        if (_this.opts.type === 'inline') {
          method = center.x < sorted[0].center.x ? 'before' : 'after';
        } else {
          method = center.y < sorted[0].center.y ? 'before' : 'after';
        }
        return $(nearest)[method](placeholder).addClass('yyy').siblings().removeClass('yyy').end();
      };
    })(this));
    return this.sortable.on('dragenter.qingSortable', (function(_this) {
      return function(e) {
        var $item, index, inn, method;
        $item = $(e.currentTarget);
        inn = $(_this.opts.container).add(_this.opts.connect).filter(function(index, el) {
          return $.contains(el, e.currentTarget);
        });
        if (!(inn.length > 0)) {
          return;
        }
        index = $.contains(document, placeholder[0]) ? placeholder.index() : active.index();
        method = index < $item.index() ? 'after' : 'before';
        $item[method](placeholder);
        return active.addClass('xxx');
      };
    })(this));
  };

  QingSortable.prototype.destroy = function() {
    this.sortable.off('.qingSortable');
    return placeholder != null ? placeholder.remove() : void 0;
  };

  return QingSortable;

})(QingModule);

module.exports = QingSortable;

},{}]},{},[]);

return b('qing-sortable');
}));
