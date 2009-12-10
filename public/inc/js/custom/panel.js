(function() {

/**
* Class for handling object collection.
* @namespace YAHOO.Dicty
* @class Container
* @constructor
* @param hash {Object}  
*/

    YAHOO.namespace('Dicty');
    YAHOO.Dicty.Container = function(component) {
        this.container = component;
        this.end = this.container.length - 1;
        this.current = 0;

        this.util = new YAHOO.Dicty.Util;
    };

    YAHOO.lang.augmentProto(YAHOO.Dicty.Container, YAHOO.util.AttributeProvider);

    YAHOO.Dicty.Container.prototype.util = null;

    /**
 * The attribute that holds the collection.
* @property container
* @type Array
*/
    YAHOO.Dicty.Container.prototype.container = [];

    YAHOO.Dicty.Container.prototype.innerContainer = [];

    YAHOO.Dicty.Container.prototype = {
        end: 0,
        start: 0
    };

    /**
 * Add item to collection
* @method add
* @param Object literal
*/
    YAHOO.Dicty.Container.prototype.add = function(item) {
        this.container.push(item);
        this.end = this.container.length;
    };

    /**
 * Gets a particular item from collection
* @method getitem
* @param  {Integer} The integer should be within the index of item collection
* @return One item from the collection
*/
    YAHOO.Dicty.Container.prototype.getItem = function(index) {
        if (index < this.end) {
            return this.container[index - 1];
        }
    };

    /**
 * Gets all items from collection
* @method getAll
* @return All items from the collection
*/
    YAHOO.Dicty.Container.prototype.getAll = function() {
        return this.container;
    };

    /**
 * Gets the number of items in collection
* @method count
* @return {Interger}
*/
    YAHOO.Dicty.Container.prototype.count = function() {
        return this.container.length;
    };
})();

 (function() {

    /**
* @description <p>The Panel class is a container for holding layout, item and content
* properties. The render method returns HTML after delegating it to appropiate layout
* objects</p>
* @namespace YAHOO.Dicty
* @class Panel
* @constructor
* @param {Object} conf Object literal containing layout, item and content properties,
* mandatory.
* @param {String/HTMLElement} el HTML element where the HTML will be rendered, optional. The
* default is <b>body</b>.
*/

    YAHOO.Dicty.Panel = function(config, elem) {
        this.constructor.superclass.constructor.call(this, config.items);
        if (config) {
            this.setAttributeConfig('layout', {
                value: config.layout || null
            });

            this.setAttributeConfig('type', {
                value: config.type || null
            });
        }

        this.setAttributeConfig('elem', {
            value: elem || 'body'
        });

    };

    YAHOO.lang.extend(YAHOO.Dicty.Panel, YAHOO.Dicty.Container);
    YAHOO.lang.augmentProto(YAHOO.Dicty.Panel, YAHOO.util.AttributeProvider);

    /**
 * Generates and appends HTML to the given element
* @method render
* @param {String/HTMLElement} elem HTML element where the HTML will be rendered, optional. The
*/
    YAHOO.Dicty.Panel.prototype.render = function(elem, conf) {

        //the element(id or node object) that should be passed to item object
        var renderElem = elem ? elem: this.get('elem');

        var item;
        switch (this.get('layout')) {
        case 'tabview':
            item = new YAHOO.Dicty.Item.TabView(this.container);
            break;
        case 'accordion':
            item = new YAHOO.Dicty.Item.Accordion(this.container);
            break;
        case 'row':
            item = new YAHOO.Dicty.Item.Row(this.container);
            break;
        case 'column':
            item = new YAHOO.Dicty.Item.Column(this.container);
            break;
        case 'json':
            item = new YAHOO.Dicty.Item.Json(this.container);
            break;
        default:
            item = this.container;
            break;
        }

        conf ? item.render(renderElem, conf) : item.render(renderElem);
    };

    YAHOO.Dicty.Panel.prototype.eventHandler = function() {
        this.util.linkEvent();
    };
})();
