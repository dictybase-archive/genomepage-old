(function() {

    var Storage = YAHOO.Dicty.Storage,
    Dom = YAHOO.util.Dom,
    Selector = YAHOO.util.Selector,
    Event = YAHOO.util.Event,
    Elem = YAHOO.util.Element,
    Appender = '&sequence=';

    YAHOO.namespace('Dicty.Data');
    YAHOO.Dicty.Data.Format = function() {
        this.outerLink = 'outer_link';
        this.tabLink = 'tab_link';
        this.addToCartLink = 'add_to_cart';
        this.filter = new YAHOO.Dicty.Filter();
    };

    YAHOO.Dicty.Data.Format.prototype.formatData = function(rawData) {
        switch (rawData.type) {
        case 'outer':
            return this.formatOuterLink(rawData.url, rawData.caption, rawData.style, rawData.title, rawData.id, rawData.name) + "<wbr/>";
        case 'gbrowse':
            return this.formatGbrowseLink(rawData.url, rawData.caption, rawData.style) + "<wbr/>";
        case 'tab':
            return this.formatTabLink(rawData.url, rawData.caption, rawData.style) + "<wbr/>";
        case 'gbrowse_domain':
            return this.formatDomainLink(rawData.url, rawData.caption, rawData.style) + "<wbr/>";
        case 'selector':
            return this.formatSelector(rawData.options, rawData.action_link, rawData.selector_class);
        case 'table':
            return this.formatTable(rawData);
        case 'tree':
            return this.formatTree(rawData);
        case 'addToCart':
            return this.formatAddToCart(rawData.name, rawData.id, rawData.title);
        case 'section':
            return this.formatSectionLink(rawData.url, rawData.caption, rawData.style);
        default:
            return rawData.text;
        }
    };

    YAHOO.Dicty.Data.Format.prototype.formatOuterLink = function(url, caption, style, title, id, name) {
        var html = '<a href="' + url +
        '" class="' + this.outerLink + '"';
        
        if(style !== undefined) { html += ' style="' + style + '"';}
        if(title !== undefined) { html += ' title="' + title + '"';}
        if(id !== undefined)    { html += ' id="' + id + '"';}
        if(name !== undefined) { html += ' name="' + name + '"';}        
        
        html += '>' + caption + '</a>';
        return html;
    };

    YAHOO.Dicty.Data.Format.prototype.formatTabLink = function(url, caption, style) {
        var html = '<a href="' + url + '" class="' + this.tabLink + '" style="' + style + '">' + caption + '</a>';
        return html;
    };

    YAHOO.Dicty.Data.Format.prototype.formatSectionLink = function(url, caption, style) {
        var link = new Elem(document.createElement('a'));
        link.set('href', url);
        link.addClass(this.tabLink);
        link.appendChild(document.createTextNode(caption));
        return link;

    };

    YAHOO.Dicty.Data.Format.prototype.formatGbrowseLink = function(url, caption, style) {
        var imageId = Math.floor(Math.random() * 2001) + '_image';
        var gbrowseDiv = Math.floor(Math.random() * 2001) + '_div';
        var gbrowseImg = new Image();
        gbrowseImg.src = caption;

        gbrowseImg.onload = function() {
            var fadeOut = new YAHOO.util.Anim(imageId, {
                opacity: {
                    to: 0
                }
            });

            //YAHOO.log("inside image onload event ");
            fadeOut.duration = 3;
            fadeOut.onComplete.subscribe(function() {
                Dom.get(imageId).src = gbrowseImg.src;
                var fadeIn = new YAHOO.util.Anim(imageId, {
                    opacity: {
                        to: 1
                    }
                });
                var ancestor = Dom.getAncestorByClassName(gbrowseDiv, 'bd');
                var prevHeight = ancestor.scrollHeight;

                fadeIn.duration = 5;
                fadeIn.animate();
                Dom.setStyle(imageId + '_blink', 'visibility', 'hidden');
                Dom.get(imageId).border = 1;
                Dom.setStyle(imageId, 'visibility', 'visible');
                Dom.setStyle(imageId, 'width', gbrowseImg.width);

                Dom.setStyle(imageId, 'height', gbrowseImg.height + px);
                Dom.setStyle(gbrowseDiv, 'height', gbrowseImg.height + px);
                var currHeight = ancestor.scrollHeight;

                //in case of decrease the scroll height of parent element did not capture
                //it so use the scroll height of its child element
                if (prevHeight === currHeight) {
                    var first = Dom.getFirstChild(ancestor);
                    Dom.setStyle(ancestor, 'height', first.scrollHeight + 'px');
                }
                else {
                    Dom.setStyle(ancestor, 'height', currHeight + 'px');
                }
                Dom.setStyle(gbrowseDiv, 'visibility', 'hidden');
            });

            fadeOut.animate();

        };

        var html = '<p id="' + imageId + '_blink">Loading Image, please wait ........ </p>' +
        '<div class="dicty-gbrowse-div" id="' + gbrowseDiv + '">' +
        '<a href="' + url + '" class="' + this.outerLink + '" style="' + style + '">' +
        '<img border="0" class="dicty-gbrowse-image" id="' + imageId + '"' +
        '</a></div>';
        return html;
    };

    YAHOO.Dicty.Data.Format.prototype.formatDomainLink = function(url, caption, style) {
        var domainId = Math.floor(Math.random() * 8001) + '_domains';
        Event.on(domainId, 'load', this.loadDomainGbrowse, domainId);
        var html = '<p id="' + domainId + '_blink">Loading Image, please wait ........ </p>' +
        '<div id="dicty-domain-div">' +
        '<iframe id="' + domainId + '" src="' + caption + '"' + ' class="dicty-domain"' +
        'frameborder="0" scrolling="no" marginheight="0px" marginwidth="0px">' +
        '</iframe></div><br>';
        return html;
    };

    YAHOO.Dicty.Data.Format.prototype.loadDomainGbrowse = function(e, id) {
        var iframe = Dom.get(id);
        var idoc = iframe.contentWindow.document;
        var iframeBody = iframe.contentWindow.document.body;
        iframeBody.style.backgroundColor = '#ffffe0';
        var height = iframeBody.offsetHeight;


        iframe.style.height = height + 5 + "px";
        iframe.style.visibility = 'visible';

        Dom.setStyle('dicty-domain-div', 'width', '640px');
        Dom.setStyle('dicty-domain-div', 'border-width', '1px');
        Dom.setStyle('dicty-domain-div', 'background-color', '#ffffe0');
        Dom.setStyle('dicty-domain-div', 'border-style', 'solid');
        Dom.setStyle('dicty-domain-div', 'border-color', 'black');
        Dom.setStyle(id + '_blink', 'visibility', 'hidden');

        //Lets try to reset the height of section after the image is being loaded
        //this is the body element for section which should receive the height
        var ancestor = Dom.getAncestorByClassName(iframe, 'bd');

        //add the scaling that is needed for the height
        var scrollHeight = height + 105;
        Dom.setStyle(ancestor, 'height', scrollHeight + 'px');
    };

    YAHOO.Dicty.Data.Format.prototype.newWindow = function(ev) {
        Event.preventDefault(ev);
        var elem = Event.getTarget(ev);
        var tagName = elem.tagName;
        var url;
        //YAHOO.log("type of element " + elem.tagName);
        if (tagName === 'IMG') {
            url = elem.parentNode.href;
        }
        else if (tagName == 'INPUT' && elem.type === 'button') {
            url = this.appendSelectorValue(elem);
        }
        else if (tagName == 'I') {
            url = Dom.getAncestorByClassName(elem, 'outer_link').href;
        }
        else {
            url = elem.href;
        }
        //YAHOO.log("the url " + url);
        window.open(url);
    };

    YAHOO.Dicty.Data.Format.prototype.newTab = function(ev) {
        Event.preventDefault(ev);
        var elem = Event.getTarget(ev);
        var regExp = new RegExp("\\?");
        var pathCheck = new RegExp("^/");
        var url,
        pathPart,
        mainPath,
        tabLink;

        //1. gets everything expect the hostname and first part of url
        //2. removes the first leading slash
        //3. gets the HTML(HREF) element that matches url of the tab to be selected or
        //created
        if (elem.tagName == 'INPUT' && elem.type == 'button') {
        		//this section is mainly 
            url = elem.name;
            pathPart = url.split("/");
            //here mainPath get the var appended with sequence type
            mainPath = this.appendSelectorValue(elem);
            var checkPath = mainPath;
            if (regExp.test(url)) {
                checkPath = url.split("?")[0];
                url = mainPath;
            }
            tabLink = Selector.query("li a[href=" + checkPath + "]");
        }
        else {
            url = elem.pathname;
        		YAHOO.log("got url " + url);
            if (!pathCheck.test(url)) {
                url = '/'.concat(elem.pathname);
            }
            pathPart = url.split("/");
            tabLink = Selector.query("li a[href=" + url + "]");
        }

        //now to get the id of the  tabview object this element belong to
        //main tabview object
        var parent = Storage.get('container');
        var parentTabs = parent.get('tabs');

        if (tabLink.length > 0) {
            var first = Dom.getAncestorByClassName(tabLink[0], 'content_tab');
            //If there are nested tabs focus it first
            if (first) {
                //YAHOO.log("got first child " + first.id);
                var tabId = first.id;
                var child = Storage.get(tabId);
                var tabs = child.get('tabs');
                for (i in tabs) {
                    var tabPath = tabs[i].get('href');
                    if (tabPath === url) {
                        child.set('activeTab', tabs[i]);
                        break;
                    }
                }
            }
            //change the focus of the main tab
            var parentPath = first ? pathPart.splice(0, pathPart.length - 1).join("/") + "/": url;
            for (y in parentTabs) {
                var parentTabUrl = parentTabs[y].get('href');
                if (tryActiveTab(parentTabUrl, parentPath, parent, y, regExp)) {
                    return;
                }
                //YAHOO.log("tab url " + parentUrl + " expected url " + parentPath);
            }
        }

        //if we are here means we have to create a new tab
        YAHOO.log('creating new tab');
        //YAHOO.log("value of pathpart " + pathPart[2]);
        var label = ucFirst(pathPart.pop());
        var tabDomId = label + '_' + Math.floor(Math.random() * 2001);
        

        var rootPath = window.location.href.split("/").splice(3, 1);
        label +=  '<span name="/help/' + 
             rootPath + '/' + pathPart[1] + 
             '" class="accordionHelpItem" title="Click on me to get a hint">&nbsp;</span>';
            
        var newTab = new YAHOO.widget.Tab({
            label: label,
            content: '<div class="content_tab dicty-loader" id="' + tabDomId + '" </div>',
            href: url
        });

        newTab.setAttributeConfig('tabDomId', {
            value: tabDomId
        });

        newTab.setAttributeConfig('source', {
            value: url + '.json'
        });

        newTab.setAttributeConfig('fetch', {
            value: 'remote'
        });
        newTab.setAttributeConfig('tabKey', {
            value: pathPart[1]
        });
        
        //YAHOO.log('added new tab');
        parent.addTab(newTab);
        //YAHOO.log(parentTabs.length + " tab length after" );
        parent.set('activeTab', newTab);

        function ucFirst(str) {
            var first = str.substr(0, 1).toUpperCase();
            var rest = str.substring(1);
            return first.concat(rest);
        }

        function tryActiveTab(tabUrl, tabPath, tabView, index, regExp) {
            //YAHOO.log("in active tab");
            var appender = false;
            var url = tabUrl;
            var path = tabPath;

            if (regExp.test(url)) {
                url = tabUrl.split("?")[0];
            }

            if (regExp.test(path)) {
                path = tabPath.split("?")[0];
                appender = true;
            }

            if (url === path) {
                //YAHOO.log("match is " + path)	;
                var activeTab = tabView.getTab(index);
                if (appender) {
                		//this logic mostly for blast loader
                		//it gets the basic url and appends the primary and sequence type
                		//e.g: /tools/blast?noheader=true& : primary_id=DDB0231257&sequence=Protein
                    var values = tabPath.split('&');
                    var embedSrc = activeTab.get('source').split('&')[0] + '&' + values[1] + '&' + values[2]; 
                    activeTab.setAttributeConfig('embedUrl', {
                        value:  embedSrc
                    });

                    activeTab.setAttributeConfig('button', {
                        value:  'click'
                    });
                    activeTab.setAttributeConfig('loaded', {
                        value: false
                    });
                }
                activeTab.setAttributeConfig('click', {
                    value: 'hyperlink'
                });
                tabView.set('activeTab', activeTab);
                return true;
            }

            return false;
        }

    };

    YAHOO.Dicty.Data.Format.prototype.formatSelector = function(options, action, selectorClass) {
        var selectOptions = options,
        optionSt = '<option value=',
        optionEnd = ' </option>',
        ID = Math.random(),
        selectID = ID + '_select',
        selectorHTML = '<select id="' + selectID + '">';

        for (i in selectOptions) {
            selectorHTML += optionSt + '"' + selectOptions[i] + '">' + selectOptions[i] + optionEnd;
        }
        selectorHTML += '</select>';

        var buttonHTML = '';

        for (y in action) {

            var buttonID = Math.floor(Math.random() * 2001) + '_button';
            buttonHTML += '<input id="' + buttonID + '" ' +
            'class="' + action[y].type + '_link"' +
            'type="button" value="' + action[y].caption + '" ' +
            'name="' + action[y].url + '" />';
        }

        var HTML = '<div class="' + selectorClass + '">';
        HTML += selectorHTML + "&nbsp;&nbsp;" + buttonHTML + '</div>';
        return HTML;
    };

    YAHOO.Dicty.Data.Format.prototype.appendSelectorValue = function(elem) {
        var parent = Dom.getAncestorByClassName(elem, 'sequence_selector');
        var selector = Dom.getFirstChild(parent);
        var value = selector.options[selector.selectedIndex].value;
        return elem.name + Appender + encodeURIComponent(value);
    };

    YAHOO.Dicty.Data.Format.prototype.formatTable = function(data) {
        var ID = data.id ? data.id: Math.floor(Math.random() * 2001) + '-table',
        pageId = 'dicty-' + Math.floor(Math.random() * 1001) + '-paginator',
        boxId = 'dicty-' + Math.floor(Math.random() * 1001) + '-box',
        inputId = 'dicty-' + Math.floor(Math.random() * 1001) + '-input',
        filterId = 'dicty-' + Math.floor(Math.random() * 1001) + '-filter-datatable',
        clearId = 'dicty-' + Math.floor(Math.random() * 1001) + '-clear-datatable',
        rawData = data,
        dataColumns = new Array(),
        dataRecords = new Array(),
        tableData = new Array();


        for (i in rawData.columns) {
            dataColumns.push(rawData.columns[i].key);
        }
        for (i in rawData.records) {
            var record = rawData.records[i],
            previousType = '';

            for (j in dataColumns) {
                var column = dataColumns[j],
                innerHTML = '',
                columnData;

                if (record[column] === undefined) {
                    break;
                }
                for (l in record[column]) {
                    if (record[column][l] === null) {
                        continue;
                    }
                    if ((record[column][l].type == 'outer') && (record[column][l].type == previousType)) {
                        innerHTML += '&nbsp;&nbsp;';
                    }
                    innerHTML += this.formatData(record[column][l]);
                    previousType = record[column][l].type;
                }
                rawData.records[i][column] = innerHTML;
            }
        }
        tableData = {
            columns: dataColumns,
            columnDefs: rawData.columns,
            records: rawData.records,
            caption: rawData.caption
        };

        //Stuffs left: Here the filter controls should only be displayed in case of a filter table flag
        var HTML = '<div class="table-controllers"><div class="table-paginator" id="' + pageId + '"></div>';
        var tdata = {};
        if (data.filter) {
            HTML += '<div class="table-filter" id="' + boxId + '">' +
            '<div class="table-filter-text hidden warning"></div>' +
            '<b>Filter results:</b>&nbsp;<input type="text" name="filter" id="' + inputId + '">&nbsp;' +
            '<span id="' + filterId + '"></span>' +
            '<span id="' + clearId + '"></span>' +
            '</div>';
            tdata.filter = new YAHOO.widget.Button({
                container: filterId,
                label: 'Filter',
                type: 'button'
            });
            tdata.clear = new YAHOO.widget.Button({
                container: clearId,
                label: 'Clear',
                type: 'button'
            });
            tdata.input = inputId;
        }
        HTML += '</div>';
        HTML += '<div style="clear:both;" class="yui_table ' +
        rawData.table_class + '" id="' + ID + '"></div>';

        tdata.html = HTML;
        tdata.id = ID;
        tdata.pageId = pageId;
        tdata.page = data.paginator;
        tdata.json = escape(YAHOO.lang.JSON.stringify(tableData));

        return tdata;
    };

    YAHOO.Dicty.Data.Format.prototype.displayTableData = function(tdata) {
        var el = YAHOO.util.Dom.get(tdata.id),
        json = el.innerHTML,
        data = YAHOO.lang.JSON.parse(unescape(tdata.json));

        // Stores the previous values of the row to find out when they change
        var previousRow = {};
        // When a cell receives a new value,
        var dirty = false,
        even = true,
        odd = false;
        // Row always start in a clean state
        var resetDirty = function(elRow, oRecord) {
            dirty = false;
            even = true;
            odd = false;
            return true;
        };

        // This is the function doing the groupping.
        // It is set as a formatter for the DataTable.
        // It can be set on any or all columns
        var grouper = function(elCell, oRecord, oColumn, value) {
            var k = oColumn.key,
            // this.getTdEl() doesn't work at this point.  Call it a but or whatever
            td = Dom.getAncestorByTagName(elCell, 'td');
            // if the column should not be grouped, the value is shown
            // and the style set according to the current row setting
            if (oColumn.group === false) {
                elCell.innerHTML = value;
                Dom.addClass(td, (dirty ? 'first': 'next'));
                // It is always important to clear any className previously set.
                Dom.removeClass(td, (dirty ? 'next': 'first'));
            } else {
                // if the row is dirty (a value changed in a previous column)
                // or the value changed in this very column
                if (dirty || previousRow[k] != value) {
                    // mark the remaining columns in the row as dirty
                    dirty = true;
                    // set the corresponding className
                    Dom.addClass(td, 'first');
                    Dom.removeClass(td, 'next');
                    // fill the cell with the value
                    elCell.innerHTML = value;
                    // save the now current value
                    previousRow[k] = value;
                } else {
                    // set the style for repeated cells
                    Dom.addClass(td, 'next');
                    Dom.removeClass(td, 'first');
                    //Make sure the cell is empty
                    elCell.innerHTML = '';
                }
            }
        };

        var dataSource = new YAHOO.util.DataSource(data.records);
        dataSource.responseType = YAHOO.util.DataSource.TYPE_JSARRAY;
        dataSource.responseSchema = data.columns;

        var columnDefs = data.columnDefs;

        //filter data table
        dataSource.doBeforeCallback = function(req, raw, parsedRes, callback) {
            if (!req) {
                return parsedRes;
            }

            var regExp = new RegExp(req, "i");
            var tblData = parsedRes.results || [];
            var filtered = [];

            //YAHOO.log("request " + req);
            //YAHOO.log("raw response " + YAHOO.lang.dump(raw));
            //YAHOO.log("parsed response " + YAHOO.lang.dump(parsedRes));
            for (i in tblData) {
                for (y in tblData[i]) {
                    if (regExp.test(tblData[i][y])) {
                        //YAHOO.log("match found " + tblData[i][y]);
                        filtered.push(tblData[i]);
                        break;
                    }
                }
            }

            //alter and send back the result to datatable
            parsedRes.results = filtered;
            return parsedRes;
        };

        for (i in columnDefs) {
            if (columnDefs[i].formatter == "grouper") {
                columnDefs[i].formatter = grouper;
            }
        }

        //paginate table based on server side hints
        var tblConfig = {
            formatRow: resetDirty
        };

        if (tdata.page) {
            tblConfig.paginator = new YAHOO.widget.Paginator({
                containers: tdata.pageId,
                rowsPerPage: 40,
                alwaysVisible: false,
                pageLinks: 3
            });
        }

        var dataTable = new YAHOO.widget.DataTable(el.id, columnDefs, dataSource, tblConfig);
        dataTable.subscribe('renderEvent',
        function() {
            previousRow = {};
            Util = new YAHOO.Dicty.Util;
            Util.linkEvent();
        });

        return {
            oDS: dataSource,
            oDT: dataTable,
            id: el.id
        };
    };

    YAHOO.Dicty.Data.Format.prototype.formatTree = function(rawData) {
        var ID = Math.floor(Math.random() * 2001) + '-tree';
        var HTML = '<div class="yui_tree" id="' + ID + '"></div>';
        var treeData = {
            html: HTML,
            id: ID,
            args: rawData.argument,
            json: escape(YAHOO.lang.JSON.stringify(rawData.nodes))
        };
        return treeData;
    };

    YAHOO.Dicty.Data.Format.prototype.displayTreeData = function(treeData) {
        var id = treeData.id;
        var filter = this.filter;
        var args = treeData.args;
        nodes = YAHOO.lang.JSON.parse(unescape(treeData.json));
        //YAHOO.log(YAHOO.lang.JSON.stringify(nodes));
        var treeView = new YAHOO.widget.TreeView(id, nodes);
        treeView.subscribe('labelClick',
        function(node) {
            //YAHOO.log(node.index + " node is clicked " + node.label);
            if (!node.hasChildren()) {
                //YAHOO.log("got table id " + args);
                filter.treeTblFilter(args, node.label);
            }
        });
        treeView.render();
    };

    YAHOO.Dicty.Data.Format.prototype.helpHint = function(ev) {
        YAHOO.util.Event.preventDefault(ev);

        var elem = Event.getTarget(ev);

        url = elem.tagName == 'SPAN' ? elem.getAttribute('name') : elem.tagName == 'A' ? elem.getAttribute('href') : undefined;

        var helpPanel = new YAHOO.widget.Panel("helpPanel", {
            width: "500px",
            visible: false,
            modal: true,
            fixedcenter: true,
            zIndex: 3
        });
        helpPanel.setHeader("dictyBase Help: Press ESC to close the window");
        helpPanel.setBody("Loading, please wait...");

        var kl = new YAHOO.util.KeyListener(document, {
            keys: 27
        },
        {
            fn: helpPanel.hide,
            scope: helpPanel,
            correctScope: true
        });

        helpPanel.cfg.queueProperty("keylisteners", kl);
        helpPanel.render(document.body);

        YAHOO.plugin.Dispatcher.process(helpPanel.body, "Loading, please wait...");
        // displaying the panel
        helpPanel.show();
        /* loading the content */
        YAHOO.plugin.Dispatcher.fetch(helpPanel.body, url + '.html');
    };

    YAHOO.Dicty.Data.Format.prototype.formatAddToCart = function(name, id, title) {
        var ID = Math.random() * 2001 + '-button';
        var html = '<a href=# id="' + id +
        '" name="' + name +
        '" class="' + this.addToCartLink +
        '" title="' + title +
        '">&nbsp;</a>';
        return html;
    };

    YAHOO.Dicty.Data.Format.prototype.addItemToCart = function(ev) {
        YAHOO.util.Event.preventDefault(ev);

        var elem = Event.getTarget(ev);
        var name = elem.name;
        var id = elem.id;

        Dom.get('order-name').value = name;
        Dom.get('order-id').value = id;

        //YAHOO.log(Dom.get('order-name').value);
        //YAHOO.log(Dom.get('order-id').value);
        AddToCart(document.forms.order);
    };
})();
