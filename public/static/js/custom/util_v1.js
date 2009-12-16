YAHOO.namespace('Dicty');

YAHOO.Dicty.Storage = function() {
    var stack = [];
    var keyStack = [];
    var tester;

    return {
        add: function(id, object) {
            stack[id] = object;
        },
        get: function(id) {
            if (stack[id]) {
                return stack[id];
            }
            return false;
        },
        addByTag: function(object) {
            stack[object.id] = object.element;
            if (!keyStack[object.layout]) {
                keyStack[object.layout] = [];
            }
            keyStack[object.layout].push(object.element);
        },
        getAll: function(tag) {
            if (keyStack[tag]) {
                return keyStack[tag];
            }
        }
    };
} ();

(function() {
    var Dom = YAHOO.util.Dom, 
    Selector = YAHOO.util.Selector,
    Storage = YAHOO.Dicty.Storage;

    YAHOO.namespace('Dicty');
    YAHOO.Dicty.Filter = function() {
        return;
    };

    YAHOO.Dicty.Filter.prototype.treeTblFilter = function(id, query) {
        //YAHOO.log("got id and query " + id + " " + query);
        var filter = Selector.query('div.table-filter div.table-filter-text', '', true);
        filter.innerHTML = "Table filtered with " + query;
        Dom.removeClass(filter, 'hidden');

        var dataTable = Storage.get(id).oDT;
        dataTable.getDataSource().sendRequest(query,
        {
            success: dataTable.onDataReturnInitializeTable,
            failure: dataTable.onDataReturnInitializeTabler,
            argument: dataTable.getState(),
            scope: dataTable
        });
    };
})();

(function() {
    var Selector = YAHOO.util.Selector,
    Event = YAHOO.util.Event,
    Dom = YAHOO.util.Dom,
    Storage = YAHOO.Dicty.Storage,
    Cookie = YAHOO.util.Cookie,
    path = '/gene';

    YAHOO.namespace('Dicty');
    YAHOO.Dicty.Util = function() {
        this.formatter = new YAHOO.Dicty.Data.Format();
        this.dispatcher = new YAHOO.Dicty.ContentDispatcher();
        return;
    };

    YAHOO.Dicty.Util.prototype = {
        outerLink: 'outer_link',
        tabLink: 'tab_link',
        addToCartLink: 'add_to_cart',
        selectBtn: 'selector_button',
        helpItem: 'accordionHelpItem',
        toggleItem: 'accordionToggleItem',
        formatter: null,
        currId: null,


        futureDate: function() {
            var d = new Date;
            return new Date(d.getFullYear() + 5, d.getMonth(), d.getDay());
        },

        showContent: function(id) {
            this.currId = id;
            Event.onContentReady(id, this.toggleContent, this, true);
        },

        toggleContent: function() {
            var ancestor = Dom.getAncestorByClassName(this.currId, 'yui-cms-item');
            //YAHOO.log("the current Id is " + this.currId);
            if (!ancestor) {
                //this content need not to be handled by cookies
                //no cookie for you
                //however we need to remove the hidden element from any one of its ancestor if any
                var hiddenAncestor = Dom.getAncestorByClassName(this.currId, 'hidden');
                if (hiddenAncestor) {
                    Dom.removeClass(hiddenAncestor, 'hidden');
                }
                return;
            }

            var cookieId = this.makeCookieId(ancestor);
            var status = Cookie.get(cookieId);
            var spinnerElem = Selector.query('div.bd div', ancestor, 'true');
            var elem = Selector.query('div.bd', ancestor, 'true');
            //YAHOO.log("cookie id " + cookieId);

            if (!status) {
                setTimeout(openSection, 1000);
                Cookie.set(cookieId, 'open', {
                    expires: this.futureDate(), 
                    path: path
                });
            }
            else if (status === 'close') {
                //YAHOO.log("close cookie " + cookieId);
                return;
                //nothing to do here
            }
            else {
                //open status
                //YAHOO.log("open cookie " + cookieId);
                setTimeout(openSection, 1000);
                //for fun change it to setInterval ,  then the magic begins
            }

            function openSection() {

                //remove the element that gives the height to the spinner
                if (Dom.hasClass(spinnerElem, 'dicty-section')) {
                    Dom.removeClass(spinnerElem, 'dicty-section');
                }
                //remove the spinner itself
                if (Dom.hasClass(elem, 'dicty-content-loader')) {
                    Dom.removeClass(elem, 'dicty-content-loader');
                }
                var scrollHeight = elem.scrollHeight;
                if (scrollHeight > spinnerElem.scrollHeight) {
                    //this set the correct height; don't ask me why
                    scrollHeight = spinnerElem.scrollHeight;
                }
                Dom.addClass(ancestor, 'selected');

                if (scrollHeight !== 0) {
                    Dom.setStyle(elem, 'height', scrollHeight);
                }
                if (Dom.hasClass(spinnerElem, 'hidden')) {
                    Dom.removeClass(spinnerElem, 'hidden');
                }
                else {
                    //might be nested content,  so dig deeper
                    var hidden = Selector.query('div div.hidden', spinnerElem, 'true');
                    Dom.removeClass(hidden, 'hidden');
                }
            }

            function displaySection() {
                Dom.removeClass(spinnerElem, 'hidden');
            }
        },

        hideDisplay: function(elem) {
            Dom.addClass(elem, 'hidden');
        },
        //To do:Currently both the loading mask hiding routine uses a different function
        //signatures. Need to standardize them and probably use a proxy function to
        //delegate to specific hiding routine.

        //Removes the loading spinner associated with every tab content
        //It removes the class before it interferes with the positioning of our legacy
        //footer html markup.
        hideTabLoader: function() {
            var tabViews = Storage.getAll('tabview');
            for (i in tabViews) {
                var activeTab = tabViews[i].get('activeTab');
                if (!activeTab) {
                    continue;
                }
                var elem = Dom.get(activeTab.get('tabDomId'));
                if (Dom.hasClass(elem, 'dicty-loader')) {
                    Dom.removeClass(elem, 'dicty-loader');
                }
            }
        },

        //Hide the loading spinner displayed on top of every section
        hideSectionLoader: function(conf) {
            if (conf.parentLayout == 'accordion') {
                if (conf.loaderId) {
                    var fadeOut = new YAHOO.util.Anim(conf.loaderId, {
                        opacity: {
                            to: 0
                        }
                    });
                    fadeOut.duration = 5;
                    fadeOut.animate();
                }
            }
        },

        showLoader: function(id) {
            Event.onAvailable(id,
            function() {
                Dom.addClass(id, 'dicty-loader');
            });
        },

        //this gets called everytime somebody clicks to open the section
        cookieHandler: function(ev) {
            var elem = Event.getTarget(ev);
            var ancestor = Dom.getAncestorByClassName(elem, 'yui-cms-item');
            if (!ancestor) {
                return;
            }
            var cookieId = this.makeCookieId(ancestor);

            //try to fetch the cookie associated with cookie id
            var value = Cookie.get(cookieId);
            if (value) {
                if (value === 'open') {
                    Cookie.set(cookieId, 'close', {
                        expires: this.futureDate(),
                        path: path
                    });
                }
                else {
                    Cookie.set(cookieId, 'open', {
                        expires: this.futureDate(), 
                        path: path
                    });
                    //YAHOO.log("cookie id before open " + cookieId );
                    var conf = Storage.get(cookieId);
                    if (conf) {
                        if (conf.loaded) {
                            return;
                        }
                        var request = YAHOO.util.Connect.asyncRequest('GET', conf.source,
                        {
                            success: this.dispatcher.setContent,
                            failure: this.dispatcher.onFailure,
                            argument: [conf.layout, conf.section, conf.loader]
                        });

                        //display spinner here
                        var spinnerElem = Selector.query('div.bd', ancestor, 'true');
                        Dom.addClass(spinnerElem, 'dicty-content-loader');
                        conf.loaded = true;
                        Storage.add(cookieId, conf);
                    }
                }
            }
            else {
                Cookie.set(cookieId, 'open', {
                    expires: this.futureDate(),
                    path: path
                });
            }
        },

				//this one adds browser resize events
        handleResize: function() {
          	var nodes = Selector.query('div.bd');
          	for (i in nodes) {
        			var children = Dom.getFirstChild(nodes[i]);
        			var scrollHeight = nodes[i].scrollHeight;
        			if (scrollHeight > children.scrollHeight) {
        				scrollHeight = children.scrollHeight;
        			}
        			if (scrollHeight !== 0) { 
        				var cookieStatus = this.getCookieStatus(nodes[i]); 
        				if (cookieStatus === 'open') { 
          				Dom.setStyle(nodes[i], 'height', scrollHeight);
          			}
          		}
          	}
        }, 

        getCookieStatus: function(elem) { 
        		var idArray = elem.id.split("_");
        		var cookieId = idArray[0] + '_' + idArray.slice(2).join('_');
        		var status = Cookie.get(cookieId);
        		if (!status) { 
        			status = 'open';
        		}
        		return status;

        }, 

				resizeOnTab: function(id) {
          	var tabNode = Dom.get(id);
          	var nodes = Selector.query('div.bd', tabNode);
          	for (i in nodes) {
        			var children = Dom.getFirstChild(nodes[i]);
        			var scrollHeight = nodes[i].scrollHeight;
        			if (scrollHeight > children.scrollHeight) {
        				scrollHeight = children.scrollHeight;
        			}
							if (scrollHeight !== 0) { 
        				var cookieStatus = this.getCookieStatus(nodes[i]); 
        				if (cookieStatus === 'open') { 
          				Dom.setStyle(nodes[i], 'height', scrollHeight);
          			}
          		}
          	}
        },


        //The given element should be the parent element(currently div) holding
        //that particular section
        makeCookieId: function(elem) {
            var child = Selector.query('div.bd div', elem, 'true');
            var idArray = child.id.split("_");
            var cookieId = idArray[0] + '_' + idArray.slice(2).join('_');
            return cookieId;
        }
    };

    YAHOO.Dicty.Util.prototype.linkEvent = function() {
        var fmt = this.formatter;
        var outerNodes = Dom.getElementsByClassName(this.outerLink);
        var tabNodes = Dom.getElementsByClassName(this.tabLink);
        var helpNodes = Dom.getElementsByClassName(this.helpItem);
        var toggleNodes = Dom.getElementsByClassName(this.toggleItem);
        var addToCartNodes = Dom.getElementsByClassName(this.addToCartLink);
        
        for (i in outerNodes) {
            if (!Event.getListeners(outerNodes[i], 'click')) {
                Event.on(outerNodes[i], 'click', fmt.newWindow, fmt, true);
            }
        }
        for (y in tabNodes) {
            if (!Event.getListeners(tabNodes[y], 'click')) {
                Event.on(tabNodes[y], 'click', fmt.newTab, fmt, true);
            }
        }
        for (l in helpNodes) {
            if (!Event.getListeners(helpNodes[l], 'click')) {
                Event.on(helpNodes[l], 'click', fmt.helpHint, fmt, true);
            }
        }
        for (k in addToCartNodes) {
            if (!Event.getListeners(addToCartNodes[k], 'click')) {
                Event.on(addToCartNodes[k], 'click', fmt.addItemToCart, fmt, true);
            }
        }

        //event handler for section toggler
        //section toogling events are stored in cookie
        for (z in toggleNodes) {
            if (!Event.getListeners(toggleNodes[z], 'click')) {
                Event.on(toggleNodes[z], 'click', this.cookieHandler, this, true);
            }
        }
    };

    //Creates event handler for datatable filtering
    //button parameter should have two properties, filter and clear, each of which should
    //contain a reference to YAHOO.widget.Button object.
    YAHOO.Dicty.Util.prototype.linkTblFilter = function(id, button) {
        var Id = id;
        var input = Dom.get(button.input);
        var ancestor = Dom.getAncestorByClassName(input, 'table-filter');
        var filter = Dom.getFirstChild(ancestor);
        //YAHOO.log("got ancestor " + ancestor.id);
        //var first = Dom.getFirstChild(ancestor);
        //YAHOO.log("got child " + YAHOO.lang.dump(first));
        button.filter.on('click',
        function() {
            var query = input.value;
            if (query.match(/^\s*$/)) {
                return;
            }
            var dataTable = Storage.get(Id).oDT;
            filter.innerHTML = "Table filtered with " + query;
            Dom.removeClass(filter, 'hidden');
            dataTable.getDataSource().sendRequest(query,
            {
                success: dataTable.onDataReturnInitializeTable,
                failure: dataTable.onDataReturnInitializeTabler,
                argument: dataTable.getState(),
                scope: dataTable
            });
        });

        button.clear.on('click',
        function() {

            input.value = '';
            Dom.addClass(filter, 'hidden');
            var dataTable = Storage.get(Id).oDT;
            dataTable.getDataSource().sendRequest('',
            {
                success: dataTable.onDataReturnInitializeTable,
                failure: dataTable.onDataReturnInitializeTabler,
                argument: dataTable.getState(),
                scope: dataTable
            });
        });
    };

})();



