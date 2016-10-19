/**
 * qing-sortable v0.0.1
 * http://mycolorway.github.io/qing-sortable
 *
 * Copyright Mycolorway Design
 * Released under the MIT license
 * http://mycolorway.github.io/qing-sortable/license.html
 *
 * Date: 2016-10-19
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

  QingSortable.opts = {
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

  QingSortable.prototype.placeholder = null;

  QingSortable.prototype.active = null;

  QingSortable.prototype._render = function() {
    return this.sortable.each(function(index, el) {
      return el.draggable = true;
    });
  };

  QingSortable.prototype._bind = function() {
    this.sortable.on('dragstart.qingSortable', (function(_this) {
      return function(e) {
        var $item, dragImage;
        console.log('start');
        $item = $(e.currentTarget).addClass('qing-sortable-active');
        if (_this.opts.customDragImage) {
          dragImage = $item.clone().addClass('qing-sortable-dragimage');
          console.log(dragImage[0].outerHTML);
          dragImage.appendTo('body');
          e.originalEvent.dataTransfer.setDragImage(dragImage[0], dragImage.width() / 2, dragImage.height() / 2);
        }
        _this.active = $item;
        return _this.placeholder = $item.clone().attr('data-sort-placeholder', true);
      };
    })(this));
    this.sortable.on('dragend.qingSortable', (function(_this) {
      return function(e) {
        var $item;
        console.log('end');
        $item = $(e.currentTarget);
        $item.removeClass('qing-sortable-active');
        if ($.contains(document, _this.placeholder[0])) {
          $(e.currentTarget).show().insertAfter(_this.placeholder);
          _this.placeholder.detach();
        }
        return _this.active = null;
      };
    })(this));
    return this.sortable.on('dragenter.qingSortable', (function(_this) {
      return function(e) {
        var $item, index, method;
        $item = $(e.currentTarget);
        if ($item[0] !== _this.active[0]) {
          index = $.contains(document, _this.placeholder[0]) ? _this.placeholder.index() : _this.active.index();
          method = index < $item.index() ? 'after' : 'before';
          $item[method](_this.placeholder);
          return _this.active.hide();
        }
      };
    })(this));
  };

  QingSortable.prototype.destroy = function() {
    var ref;
    this.sortable.off('.qingSortable');
    return (ref = this.placeholder) != null ? ref.remove() : void 0;
  };

  return QingSortable;

})(QingModule);

module.exports = QingSortable;

},{}]},{},[]);

return b('qing-sortable');
}));
