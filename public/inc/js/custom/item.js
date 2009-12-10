(function() {

    /**
* Class for handling tab layout item collection.
* @namespace YAHOO.Dicty.Item
* @class TabView
* @constructor
* @param {Array} items Array containing layout configurations for tabs. Each element
*   can have the following attributes.        
* @attribute key
* @description Name of tab, should be unique
* @type String
*
* @attribute label
* @description Human readable name of the tab
* @type String
*
* @attribute source
* @description From where the data for the tab will be retrieved. By default, it expects a
* http url to send a XHR request
* @type String
*
* @attribute active
* @description Flag to know which tab will be shown be default 
* @type Boolean
*
* @attribute content
* @description Array containing configurations for other layout, generally appears for
* nested tab display, for the time being source and content being mutually exclusive. 
* @type Array
*
*
* @param {Object} conf Object literal describing configuration attributes for this object. 
*
* @attribute contentSource
* @description Describes the types of source from where the data will be fetched. Default
* is 'remote' and other options are 'local' and 'deadend'. The 'deadend' option is to
* not fetch any data to fill the tab content in spite of the source being defined.
* @type String
*
* @attribute elem
* @description Default value is 'container'
* @type String
*
* @attribute type
* @description Default value is 'content-tab'
* @type String
*
* @attribute contHandler
* @description The object which should handle the data fetched from the tab source. The
* default is 'YAHOO.Dicty.ContentDispatcher'. For details look at its documentation.
* @type Object
*/

    var Dom = YAHOO.util.Dom;
    var Storage = YAHOO.Dicty.Storage;
    var Lang = YAHOO.lang;

    YAHOO.namespace('Dicty.Item');
    YAHOO.Dicty.Item.TabView = function(items, conf) {
        this.constructor.superclass.constructor.call(this, items);

        conf = conf || {};

        this.component = new YAHOO.widget.TabView();
        this.init(conf);
    };

    YAHOO.extend(YAHOO.Dicty.Item.TabView, YAHOO.Dicty.Container);
    YAHOO.lang.augmentProto(YAHOO.Dicty.Item.TabView, YAHOO.util.AttributeProvider);

    YAHOO.Dicty.Item.TabView.prototype.component = null;

    YAHOO.Dicty.Item.TabView.prototype.childElem = new Array;

    YAHOO.Dicty.Item.TabView.prototype.tabId = null;

    YAHOO.Dicty.Item.TabView.prototype.makeId = function(conf) {
        return conf.key + '_' + Math.floor(Math.random() * 2001);
    };

    YAHOO.Dicty.Item.TabView.prototype.label = function(conf) {
        //subtab at this point do not need any help icon,  so .....
        if (this.get('currElem') !== 'container') {
            return conf.label;
        }
        var url = window.location.href;
        var rootPath = url.split("/").splice(3, 1);
        return conf.label + '<span name="/help/' +
        rootPath + '/' + conf.key +
        '" class="accordionHelpItem" title="Click on me to get a hint">&nbsp;</span>';
    };

    YAHOO.Dicty.Item.TabView.prototype.content = function() {
        return this.get('startHtml') +
        this.get('type') + ' dicty-loader"' +
        ' id="' + this.tabId + this.get('endHtml');
    };

    YAHOO.Dicty.Item.TabView.prototype.init = function(conf) {
        this.setAttributeConfig('contentSource', {
            value: conf.contentSource || 'remote'
        });

        this.setAttributeConfig('elem', {
            value: conf.elem || 'container',
            validator: YAHOO.lang.isString
        });

        this.setAttributeConfig('type', {
            value: conf.type || 'content_tab',
            validator: YAHOO.lang.isString
        });

        //for the time being the content handler is global for all tabs in the tab collection.
        //Later on it could be changed to a tab specific property.
        this.setAttributeConfig('contHandler', {
            value: conf.contHandler || new YAHOO.Dicty.ContentDispatcher()
        });

        this.setAttributeConfig('startHtml', {
            value: '<div class="'
        });
        this.setAttributeConfig('endHtml', {
            value: '"></div>'
        });


    };

    YAHOO.Dicty.Item.TabView.prototype.render = function(elem, conf) {
        //pre-process before render
        if (conf) {
            this.util.hideSectionLoader(conf);
        }

        var renderElem = elem ? elem: this.get('elem');
        //set the running element
        this.setAttributeConfig('currElem', {
            value: renderElem
        });
        var tabCollection = this.component;
        var contHandler = this.get('contHandler');
        var nestedCont = [];
        var activeIndex = 0;
        var activeTab;

        for (i in this.container) {
            var item = this.container[i];
            this.tabId = this.makeId(item);

            var tab = new YAHOO.widget.Tab({
                label: this.label(item),
                content: this.content(),
                href: item.href
            });

            tab.setAttributeConfig('tabKey', {
                value: item.key
            });

            tab.setAttributeConfig('tabDomId', {
                value: this.tabId
            });

            tab.setAttributeConfig('click', {
                value: 'tab'
            });

            if (item.active) {
                tab.set('active', true);
                tab.setAttributeConfig('loaded', {
                    value: false
                });
                activeIndex = i;
                activeTab = tab;
            }

            //nested tab delegation
            if (item.content) {
                nestedCont[this.tabId] = [];
                for (y in item.content) {
                    nestedCont[this.tabId].push(item.content[y]);
                }
            }

            if (item.source) {
                tab.setAttributeConfig('source', {
                    value: item.source
                });

                if (item.dispatch) {
                    //should become dispatcher later on
                    tab.setAttributeConfig('fetch', {
                        value: 'dispatcher'
                    });
                }
                else {
                    tab.setAttributeConfig('fetch', {
                        value: 'remote'
                    });
                }
            }
            tabCollection.addTab(tab);
        }
        tabCollection.appendTo(renderElem);


        if (!Lang.isValue(activeTab)) {
            activeTab = tabCollection.getTab(0);
        }

        //This will focus the tab in collection which will be in focus by default
        //tabCollection.on('activeIndexChange', this.onIndexChange, this, true);
        tabCollection.on('activeTabChange', this.onTabChange, this, true);

        //Is this the parent tabcollection
        //in that case the name of render element is 'container'
        if (renderElem !== 'container' && conf.parentLayout === 'tabview') {
            //get the ancestor element in DOM that holds all the subtab
            var ancestor = Dom.getAncestorByClassName(renderElem, 'yui-content');

            //now get the index of its that is active
            var children = Dom.getChildren(ancestor);

            var childIndex;
            for (i in children) {
                if (!Dom.hasClass(children[i], 'yui-hidden')) {
                    childIndex = i;
                    break;
                }
            }

            //now get the same index as being reported by parent tab
            var parent = Storage.get('container');
            var idx = parent.get('activeIndex');
            if (idx === childIndex) {
                tabCollection.set('activeTab', activeTab);
            }
        }
        else {
            tabCollection.set('activeTab', activeTab);
        }

        Storage.addByTag(
        {
            layout: 'tabview',
            id: renderElem,
            element: tabCollection
        });

        //now the nested content
        for (id in nestedCont) {
            for (cont in nestedCont[id]) {
                var innerPanel = new YAHOO.Dicty.Panel(nestedCont[id][cont]);
                innerPanel.render(id, {
                    parentLayout: 'tabview'
                });
            }
        }

    };

    YAHOO.Dicty.Item.TabView.prototype.onTabChange = function(event) {
        var activeTab = event.newValue;
        var contHandler = this.get('contHandler');
        var util = this.util;

        var domId = activeTab.get('tabDomId');
				util.resizeOnTab(domId);

        // the tab is loaded
        if (activeTab.get('loaded')) {
            return;
        }

        //no source no data, no point in getting anything for it
        if (!activeTab.get('source')) {
            var click = activeTab.get('click');
            if (click === 'hyperlink') {
                YAHOO.log('active tab is from hyperlink reseting it to tab', 'warn');
                activeTab.setAttributeConfig('click', {
                    value: 'tab'
                });
                return;
            }
            var childComp = Storage.get(domId);
            if (Lang.isObject(childComp)) {
                childComp.set('activeTab', childComp.getTab(0));
            }

            return;
        }

        //then check using index of the active tab if it is already populated
        var args = ['tabview', activeTab.get('tabDomId')];
        var callback = {
            success: contHandler.setContent,
            failure: contHandler.onFailure,
            //scope: contHanlder: yeah this one caused a lot headache
            argument: args
        };

        switch (activeTab.get('fetch')) {
        case 'local':
            contHandler.setContent({
                responseObject:
                activeTab.get('source'),
                argument: args
            });
            break;
        case 'dispatcher':
        		var iframeUrl = activeTab.get('source');
        		var type = activeTab.get('button');
        		if (type === 'click') { 
        			iframeUrl = activeTab.get('embedUrl');
        			activeTab.setAttributeConfig('button',  { value: 'tab' });
        		}
           //Todo: hardcoded for blast tab,  have to make it generic
            var iframeId = Math.floor(Math.random() * 2001) + '_blast';
            Dom.get(args[1]).innerHTML = '<iframe class="dicty-blast" frameborder="0" scrolling="no"' +
            'id="' + iframeId + '" src="' + iframeUrl + '"></iframe>';
            Event.on(iframeId, 'load',
            function() {
                var iframe = Dom.get(iframeId);
                iframe.style.height = "700px";
                util.hideTabLoader();
            });
            break;
        case 'remote':
            var request = YAHOO.util.Connect.asyncRequest('GET', activeTab.get('source'), callback);
            break;
        default:
            break;
        }
        //mark the tab as loaded
        activeTab.setAttributeConfig('loaded', {
            value: true
        });
    };

    YAHOO.Dicty.Item.TabView.prototype.onIndexChange = function(event) {
        var activeIndex = event.newValue;
        var tabCollection = this.component;
        var contHandler = this.get('contHandler');
        var activeTab = tabCollection.getTab(activeIndex);
        var util = this.util;

        // the tab is loaded
        if (activeTab.get('loaded')) {
            return;
        }

        //no source no data, no point in getting anything for it
        if (!activeTab.get('source')) {
            var domId = activeTab.get('tabDomId');
            var childComp = Storage.get(domId);
            if (Lang.isObject(childComp)) {
                childComp.set('activeIndex', 0);
            }
            return;
        }


        //then check using index of the active tab if it is already populated
        var args = ['tabview', activeTab.get('tabDomId')];
        var callback = {
            success: contHandler.setContent,
            failure: contHandler.onFailure, 
            //scope: contHanlder: yeah this one caused a lot headache
            argument: args
        };

        switch (activeTab.get('fetch')) {
        case 'local':
            contHandler.setContent({
                responseObject:
                activeTab.get('source'),
                argument: args
            });
            break;
        case 'dispatcher':
            //Todo: hardcoded for blast tab,  have to make it generic
            var iframeId = Math.floor(Math.random() * 2001) + '_blast';
            Dom.get(args[1]).innerHTML = '<iframe class="dicty-blast" frameborder="0" scrolling="no"' +
            'id="' + iframeId + '" src="' + activeTab.get('embedUrl') + '"></iframe>';
            Event.on(iframeId, 'load',
            function() {
                var iframe = Dom.get(iframeId);
                iframe.style.height = "700px";
                util.hideTabLoader();
            });
            break;
        case 'remote':
            var request = YAHOO.util.Connect.asyncRequest('GET', activeTab.get('source'), callback);
            break;
        default:
            break;
        }
        //mark the tab as loaded
        activeTab.setAttributeConfig('loaded', {
            value: true
        });
    };
})();

(function() {

    /**
* Class for handling accordion layout item collection.
* @namespace YAHOO.Dicty.Item
* @class Accordion
* @constructor
* @param {Array} items Array containing layout configurations for tabs. Each element
*   can have the following attributes.        
* @attribute key
* @description Name of accordion, should be unique
* @type String
*
* @attribute label
* @description Human readable name of the tab
* @type Array containing an object literals that contain the attribute 'text' which holds
* the value of the label
*
* @attribute source
* @description From where the data for the tab will be retrieved. By default, it expects a
* http url to send a XHR request
* @type String
*
* @attribute content
* @description Array containing configurations for other layout.
* @type Array
*
* @param {Object} conf Object literal describing configuration attributes for this object. 
*
* @attribute contentSource
* @description Describes the types of source from where the data will be fetched. Default
* is 'deadend' and other options are 'local' and 'remote'. The default 'deadend' option do
* not fetch any data to fill  the tab content.
* @type String
*
* @attribute elem
* @description Default value is generated by prepending 'accordion-' to a random number
* @type String
*
* @attribute type
* @description Default value is 'accordion-style'
* @type String
*
* @attribute contHandler
* @description The object which should handle the data fetched from the tab source. The
* default is 'YAHOO.Dicty.ContentDispatcher'. For details look at its documentation.
* @type Object
*/

    var Dom = YAHOO.util.Dom,
    Elem = YAHOO.util.Element,
    Lang = YAHOO.lang,
    Storage = YAHOO.Dicty.Storage,
    Event = YAHOO.util.Event,
    Cookie = YAHOO.util.Cookie;

    YAHOO.Dicty.Item.Accordion = function(items, conf) {
        this.constructor.superclass.constructor.call(this, items);

        conf = conf || {};
        this.formatter = new YAHOO.Dicty.Data.Format();
        this.init(conf);
    };

    YAHOO.extend(YAHOO.Dicty.Item.Accordion, YAHOO.Dicty.Container);
    YAHOO.lang.augmentProto(YAHOO.Dicty.Item.Accordion, YAHOO.util.AttributeProvider);

    var Accordion = YAHOO.Dicty.Item.Accordion;

    Accordion.prototype.formatter = null;

    Accordion.prototype.init = function(conf) {

        this.setAttributeConfig('contentSource', {
            value: conf.contentSource || 'remote'
        });

        this.setAttributeConfig('elem', {
            value: conf.elem || 'accordion-' + Math.floor(Math.random() * 2001),
            validator: YAHOO.lang.isString
        });

        this.setAttributeConfig('type', {
            value: conf.type || 'accordion-style',
            validator: YAHOO.lang.isString
        });

        this.setAttributeConfig('contHandler', {
            value: conf.contHandler || new YAHOO.Dicty.ContentDispatcher(),
            validator: YAHOO.lang.isObject,
            method: function(value) {
                var handler = this.get('contHandler');
                if (!handler.parentLayout) {
                    handler.parentLayout('accordion');
                    this.setAttribueConfig('contHandler', {
                        value: handler
                    });
                }
            }
        });


        this.setAttributeConfig('itemtype', {
            value: 'content_table_header'
        });

        this.setAttributeConfig('sectionClass', {
            value: ['yui-cms-accordion', 'multiple', 'fade', 'slow', 'fixIE'],
            validator: Lang.isArray
        });

        this.setAttributeConfig('parentContainer', {
            value: Storage.get('container')
        });

    };

    Accordion.prototype.render = function(elem, conf) {

        if (conf) {
            this.util.hideSectionLoader(conf);
        }


        var renderElem = elem ? elem: this.get('elem');
        var contHandler = this.get('contHandler');
        var nestedCont = [];
        var loaderCont = [];
        var data = {};

        Dom.setStyle(renderElem, 'opacity', 0);
        Dom.setStyle(renderElem, 'filter', "alpha(opacity=0)");
        var parent = new Elem(document.createElement('div'));
        var name = this.get('sectionClass');
        for (i in name) {
            parent.addClass(name[i]);
        }
        parent.appendTo(Dom.get(renderElem));

        this.setAttributeConfig('parentElem', {
            value: parent
        });
        this.setAttributeConfig('currUrl', {
            value: window.location.href
        });
        this.setAttributeConfig('rootPath', {
            value: this.get('currUrl').split('/').splice(3, 1)
        });
        this.setAttributeConfig('tabKey', {
            value: this.get('parentContainer').get('activeTab').get('tabKey')
        });

        for (i in this.container) {
            var item = this.container[i];
            var sectionId = renderElem + '_' + item.key;
            var loaderId = sectionId + '-' + Math.floor(Math.random() * 10001);
            this.setAttributeConfig('cookieId', {
                value: renderElem.split('_')[0] + '_' + item.key
            });

            //setting the label
            var label;
            if (item.label.length == 1) {
                label = item.label[0].text;
                data.label = {
                    text: label,
                    link: false
                };
            }
            else {
                var element = item.label[1];
                element.type = 'section';
                data.label = {
                    text: item.label[0].text,
                    link: this.formatter.formatData(element)
                };
            }

            var itemClass = item.type ? item.type: this.get('itemtype');

            //help icon setup
            var url = window.location.href;
            var rootPath = url.split("/").splice(3, 1);

            data.item = item;
            data.loaderId = loaderId;
            data.className = itemClass;
            data.sectionId = sectionId;

            this.createSection(data);

            if (item.content) {
                nestedCont[sectionId] = [];
                loaderCont[sectionId] = loaderId;
                //next panel
                for (y in item.content) {
                    nestedCont[sectionId].push(item.content[y]);
                }
                this.setAttributeConfig('contentSource', {
                    value: 'direct'
                });
            }

            if (!item.source) {
                continue;
            }

            //if it remain close no need for XHR call
            //But we store the neccessary data for the time being
            if (this.display() === 'close') {
                Storage.add(this.get('cookieId'),
                {
                    layout: 'accordion',
                    section: sectionId,
                    loader: loaderId,
                    source: item.source,
                    loaded: false
                }

                );
                this.util.hideDisplay(loaderId);
                continue;
            }

            var args = ['accordion', sectionId, loaderId];
            switch (this.get('contentSource')) {
            case 'local':
                contHandler.setContent({
                    responseObject:
                    item.source,
                    argument: args
                });
                break;

            case 'remote':
                var callback = {
                    success: contHandler.setContent,
                    failure: contHandler.onFailure,
                    argument: args
                };
                var request = YAHOO.util.Connect.asyncRequest('GET', item.source, callback);
                break;

            default:
                break;
            }
        }

        Event.onAvailable(renderElem,
        function() {
            var fadeIn = new YAHOO.util.Anim(renderElem, {
                opacity: {
                    to: 1
                }
            });
            fadeIn.duration = 3;
            fadeIn.animate();
            //nested content
            for (id in nestedCont) {
                for (cont in nestedCont[id]) {
                    var innerPanel = new YAHOO.Dicty.Panel(nestedCont[id][cont]);
                    innerPanel.render(id, {
                        parentLayout: 'accordion',
                        loaderId: loaderCont[id]
                    });
                }
            }
        });

        //post process handler
        this.util.linkEvent();
        this.util.hideTabLoader();
    };

    Accordion.prototype.display = function() {
        var status = Cookie.get(this.get('cookieId'));
        //YAHOO.log("getting cookie Id status " + this.get('cookieId') + ' ' + status);
        if (!status) {
            return 'open';
        }
        return status;
    };

    Accordion.prototype.createSection = function(conf) {
        var sectionDiv = new Elem(document.createElement('div'));
        var sectionClass = ['yui-cms-item', 'yui-panel'];
        for (z in sectionClass) {
            sectionDiv.addClass(sectionClass[z]);
        }

        var actionDiv = new Elem(document.createElement('div'));
        actionDiv.addClass('actions');

        //now three hypelink elements
        var toggleLink = new Elem(document.createElement('a'));
        toggleLink.addClass('accordionToggleItem');
        toggleLink.set('title', 'Collapse Section');
        toggleLink.set('href', '#');
        toggleLink.appendChild(document.createTextNode(" "));


        var topLink = new Elem(document.createElement('a'));
        topLink.addClass('accordionTopItem');
        topLink.set('title', 'Top');
        topLink.set('href', '#');
        topLink.appendChild(document.createTextNode(" "));

        var helpHref = '/help/' + this.get('rootPath') +
        '/' + this.get('tabKey') + '/' + conf.item.key;

        var helpLink = new Elem(document.createElement('a'));
        helpLink.addClass('accordionHelpItem');
        helpLink.set('title', 'Click on me to get a hint');
        helpLink.set('href', helpHref);
        helpLink.appendChild(document.createTextNode(" "));

        //YAHOO.log("adding bunch of elements");
        actionDiv.appendChild(toggleLink);
        actionDiv.appendChild(topLink);
        actionDiv.appendChild(helpLink);
        sectionDiv.appendChild(actionDiv);


        var contentDiv = new Elem(document.createElement('div'));
        contentDiv.addClass(conf.className);

        var textSpan = new Elem(document.createElement('span'));
        textSpan.addClass('dicty-section-text');
        textSpan.appendChild(document.createTextNode(conf.label.text));
        if (conf.label.link) {
            //YAHOO.log("got link label " + conf.label.text);
            textSpan.appendChild(document.createTextNode("  "));
            textSpan.appendChild(conf.label.link);
            textSpan.appendChild(document.createElement('wbr'));
        }

        var loaderSpan = new Elem(document.createElement('span'));
        loaderSpan.addClass('dicty-section-loader');
        loaderSpan.set('id', conf.loaderId);

        contentDiv.appendChild(textSpan);
        contentDiv.appendChild(loaderSpan);
        sectionDiv.appendChild(contentDiv);


        var anotherDiv = new Elem(document.createElement('div'));
        anotherDiv.addClass('bd');

        var rowDiv = new Elem(document.createElement('div'));
        rowDiv.set('id', conf.sectionId);
        rowDiv.addClass('dicty-section');

        anotherDiv.appendChild(rowDiv);
        sectionDiv.appendChild(anotherDiv);

        this.get('parentElem').appendChild(sectionDiv);

    };
})();

(function() {

    var Dom = YAHOO.util.Dom;
    var Event = YAHOO.util.Event;
    var Storage = YAHOO.Dicty.Storage;

    YAHOO.Dicty.Item.Row = function(items, conf) {
        this.constructor.superclass.constructor.call(this, items);

        conf = conf || {};
        this.setAttributeConfig('parentElem', {
            value: conf.parent || 'content-row'
        });

        this.setAttributeConfig('rowClass', {
            value: conf.type || 'content_table'
        });

        this.setAttributeConfig('baseTbodyId', {
            value: 'content-tbody'
        });

        this.setAttributeConfig('baseRowId', {
            value: 'content-table-row'
        });

        this.setAttributeConfig('startRow', {
            value: '<tr id="'
        });

        this.setAttributeConfig('endRow', {
            value: '"></tr>'
        });

        this.setAttributeConfig('startTblWrapper', {
            value: '<div id="data-table"><table class="'
        });

        this.setAttributeConfig('middleTblWrapper', {
            value: '" width="100%"> <tbody id="'
        });

        this.setAttributeConfig('endTblWrapper', {
            value: '"></tbody></table></div>'
        });

    };

    YAHOO.extend(YAHOO.Dicty.Item.Row, YAHOO.Dicty.Container);
    YAHOO.lang.augmentProto(YAHOO.Dicty.Item.Row, YAHOO.util.AttributeProvider);

    YAHOO.Dicty.Item.Row.prototype.render = function(elem, conf) {

        if (conf) {
            this.util.hideSectionLoader(conf);
        }


        this.setAttributeConfig('renderElem', {
            value: elem || this.get('parentElem')
        });

        Event.onAvailable(this.get('renderElem'), this.renderRows, this, true);
        this.util.linkEvent();
    };

    YAHOO.Dicty.Item.Row.prototype.renderRows = function(ev) {

        var util = this.util;
        var renderElem = this.get('renderElem');

        //pre-process
        this.util.hideDisplay(renderElem);

        var baseId = this.get('baseTbodyId') + '-' + Math.floor(Math.random() * 10001);
        var wrapHTML = this.get('startTblWrapper') + this.get('rowClass') + this.get('middleTblWrapper') + baseId + this.get('endTblWrapper');
        Dom.get(renderElem).innerHTML = wrapHTML;

        var outerHTML = '';
        var nestedCont = new Array;
        var spanCont = [];
        var tbodyElem = Dom.get(baseId);
        for (i in this.container) {
            var item = this.container[i];
            var uniqId = this.get('baseRowId') + '-' + Math.floor(Math.random() * 20001);

            if (item.colspan) {
                spanCont[uniqId] = item.colspan;
            }

            if (item.content) {
                //next panel
                var newRow = tbodyElem.insertRow(i);
                newRow.id = uniqId;
                nestedCont[uniqId] = new Array;
                for (y in item.content) {
                    nestedCont[uniqId].push(item.content[y]);
                }
            }
        }

        Event.onAvailable(baseId,
        function() {
            for (i in nestedCont) {
                for (y in nestedCont[i]) {
                    var innerPanel = new YAHOO.Dicty.Panel(nestedCont[i][y]);
                    if (spanCont[i]) {
                        innerPanel.render(i, {
                            rowspan: spanCont[uniqId],
                            parentLayout: 'row'
                        });
                        continue;
                    }
                    innerPanel.render(i, {
                        parentLayout: 'row'
                    });
                }
            }
            util.showContent(baseId);
        });
        util.hideTabLoader();
    };
})();

(function() {

    var Dom = YAHOO.util.Dom;
    var Event = YAHOO.util.Event;

    YAHOO.Dicty.Item.Column = function(items, conf) {
        this.constructor.superclass.constructor.call(this, items);

        conf = conf || {};

        this.setAttributeConfig('parentElem', {
            value: conf.parent || ''
        });

        this.setAttributeConfig('closeQuote', {
            value: '"'
        });
        this.setAttributeConfig('startCol', {
            value: '<td class="'
        });
        this.setAttributeConfig('middleCol', {
            value: ' id="'
        });
        this.setAttributeConfig('endCol', {
            value: '></td>'
        });
        this.setAttributeConfig('colClass', {
            value: 'content_table_data'
        });
        this.setAttributeConfig('baseColId', {
            value: 'content-table-col'
        });
        this.setAttributeConfig('colSpan', {
            value: ' colspan="'
        });
        this.setAttributeConfig('rowSpan', {
            value: ' rowspan="'
        });

    };

    YAHOO.extend(YAHOO.Dicty.Item.Column, YAHOO.Dicty.Container);
    YAHOO.lang.augmentProto(YAHOO.Dicty.Item.Column, YAHOO.util.AttributeProvider);

    YAHOO.Dicty.Item.Column.prototype.render = function(elem, conf) {
        var renderElem = elem ? elem: this.get('parentElem');

        var outerHTML = '';
        var nestedCont = [];
        var rowElem = Dom.get(renderElem);

        var colSpan = '';
        var rowSpan = '';
        if (conf) {
            this.util.hideSectionLoader(conf);
            if (conf.colspan) {
                colSpan = this.get('colSpan') + conf.colspan + this.get('closeQuote');
            }
        }

        if (conf.parentLayout != 'row') {
            var tbl = document.createElement('TABLE');
            tbl.width = "100%";
            var tbody = document.createElement('TBODY');
            var trow = document.createElement('TR');

            tbl.appendChild(tbody);
            tbody.appendChild(trow);
            rowElem.appendChild(tbl);

            rowElem = trow;

        }

        for (i in this.container) {
            var item = this.container[i];
            var colClass = item.type ? item.type: this.get('colClass');

            if (item.rowspan) {
                rowSpan = this.get('rowSpan') + item.rowspan + this.get('closeQuote');
            }
            if (item.colspan) {
                colSpan = this.get('colSpan') + item.colspan + this.get('closeQuote');
            }

            var uniqId = this.get('baseColId') + '-' + Math.floor(Math.random() * 200001);
            //for some reason if i try to insert markup on every iteration, the current one never
            //finds the one inserted before
            //So for the time being i have decided to insert them in batch
            var colElem = rowElem.insertCell(i);
            colElem.className = colClass;
            colElem.id = uniqId;

            if (item.rowspan) {
                colElem.rowSpan = item.rowspan;
            }
            if (item.colspan) {
                colElem.colSpan = item.colspan;
            }
            if (item.content) {
                //next panel
                for (y in item.content) {
                    nestedCont[uniqId] = item.content[y];
                }
            }
        }

        Event.onAvailable(renderElem,
        function() {
            for (i in nestedCont) {
                var innerPanel = new YAHOO.Dicty.Panel(nestedCont[i]);
                innerPanel.render(i, {
                    parentLayout: 'column'
                });
            }
        });
        this.util.linkEvent();
    };
})();

(function() {

    var Dom = YAHOO.util.Dom;
    var Event = YAHOO.util.Event;
    var Storage = YAHOO.Dicty.Storage;

    YAHOO.Dicty.Item.Json = function(items, conf) {
        this.constructor.superclass.constructor.call(this, items);

        conf = conf || {};
        this.setAttributeConfig('parentElem', {
            value: conf.parent || 'content-table-json'
        });

        this.formatter = new YAHOO.Dicty.Data.Format();
    };

    YAHOO.extend(YAHOO.Dicty.Item.Json, YAHOO.Dicty.Container);
    YAHOO.lang.augmentProto(YAHOO.Dicty.Item.Json, YAHOO.util.AttributeProvider);

    YAHOO.Dicty.Item.Json.prototype.formatter = null;

    YAHOO.Dicty.Item.Json.prototype.render = function(elem, conf) {
        if (conf) {
            this.util.hideSectionLoader(conf);
        }

        var renderElem = elem ? elem: this.get('parentElem');

        var html = '';
        var deferedRender = [];
        var formatter = this.formatter;
        var util = this.util;
        var length = this.container.length;
        var previousType = '';

        for (i in this.container) {
            var item = this.container[i];
            var data = formatter.formatData(item);

            if (item.type == 'table' || item.type == 'tree') {
                deferedRender[item.type] = data;
                html += data.html;
                continue;
            }
            if (((item.type == 'outer') || (item.type == 'tab')) && (item.type == previousType)) {
                html += '&nbsp;&nbsp;&nbsp;';
            }
            html += data;
            previousType = item.type;
        }

        Event.onAvailable(renderElem,
        function() {
            var innerElem = Dom.get(renderElem);
            if (conf.parentLayout === 'row') {
                var cell = innerElem.insertCell(0);
                cell.colSpan = 2;
                cell.innerHTML = html;
            }
            else {
                innerElem.innerHTML = html;
            }
            for (type in deferedRender) {
                var config = deferedRender[type];
                if (type == 'tree') {
                    formatter.displayTreeData(config);
                }
                else if (type == 'table') {
                    var tblData = formatter.displayTableData(config);
                    Storage.add(tblData.id, tblData);
                    if (config.filter) {
                        util.linkTblFilter(tblData.id, config);
                    }
                }
            }
            util.linkEvent();
            //this is in case the json is called from accordion
            if (conf.parentLayout === 'accordion') {
                util.showContent(renderElem);
            }
            //this case if it is called from tabview
            if (conf.parentLayout == 'tabview') {
                util.hideTabLoader();
            }
        });
    };
})();

(function() {

    Event = YAHOO.util.Event;
    Dom = YAHOO.util.Dom;

    YAHOO.Dicty.Item.Generic = function(items) {
        this.setAttributeConfig('content', {
            value: items
        });
        this.setAttributeConfig('parenElem', {
            value: 'container'
        });
        this.setAttributeConfig('util', {
            value: new YAHOO.Dicty.Util
        });
    };

    YAHOO.lang.augmentProto(YAHOO.Dicty.Item.Generic, YAHOO.util.AttributeProvider);

    YAHOO.Dicty.Item.Generic.prototype.render = function(elem, conf) {
        if (conf) {
            this.get('util').hideSectionLoader(conf);
        }

        var renderElem = elem ? elem: this.get('parentElem');
        var content = this.get('content');
        Event.onAvailable(renderElem,
        function() {
            YAHOO.plugin.Dispatcher.process(renderElem, content, {
                action: 'update'
            });
        });
    };
})();
