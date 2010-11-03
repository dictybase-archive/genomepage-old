(function() {

    YAHOO.namespace('Dicty');
    YAHOO.Dicty.ContentDispatcher = function() {
        return;
    };

    YAHOO.Dicty.ContentDispatcher.prototype.setContent = function(obj) {

        var response,
        layout,
        item,
        handler;
        var headerType = obj.getResponseHeader['Content-Type'];
        var id = obj.argument[1];


        var conf = {
            parentLayout: obj.argument[0]
        };

        if (conf.parentLayout == 'accordion') {
            conf.loaderId = obj.argument[2];
        }

        if (headerType.match('json')) {
            response = YAHOO.lang.JSON.parse(obj.responseText);
            layout = response[0].layout;
            item = response[0].items;
        }
        else if (headerType.match('html')) {
            item = obj.responseText;
            layout = 'generic';
        }

        switch (layout) {
        case 'tabview':
            handler = new YAHOO.Dicty.Item.TabView(item);
            break;
        case 'accordion':
            //for construction of 'Accordion' item object the default configuration is fine
            handler = new YAHOO.Dicty.Item.Accordion(item);
            break;
        case 'row':
            handler = new YAHOO.Dicty.Item.Row(item);
            break;
        case 'column':
            handler = new YAHOO.Dicty.Item.Column(item);
            break;
        case 'json':
            handler = new YAHOO.Dicty.Item.Json(item);
            break;
        case 'generic':
            handler = new YAHOO.Dicty.Item.Generic(item);
            break;
        default:
            handler = this.container;
            break;
        }
        handler.render(id, conf);
    };

    YAHOO.Dicty.ContentDispatcher.prototype.onFailure = function(o) {
        YAHOO.log('Oops!', 'error');
        YAHOO.log("error output " + o.tld + " " + o.status + " " + o.statusText + " " + YAHOO.lang.dump(o.argument) );
        // handle failure
    };
})();
