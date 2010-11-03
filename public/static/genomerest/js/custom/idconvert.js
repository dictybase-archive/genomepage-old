YAHOO.example.init = function() {
    var Dom = YAHOO.util.Dom;
    //    var logger = new YAHOO.widget.LogReader();
    var callback = {
        success: setResult,
        failure: onFailure
    };
    var searchButton = new YAHOO.widget.Button({
        container: 'id-submit-button',
        label: 'Show result',
        type: 'button',
        id: 'dicty-button'
    });
    searchButton.on('click', onClick);

    var clearButton = new YAHOO.widget.Button({
        container: 'id-clear-button',
        label: 'Refresh',
        type: 'button',
        id: 'dicty-button'
    });

    clearButton.on('click',
    function() {
        Dom.get('dicty-seq-ids').value = 'Paste your IDs here  ......';
        Dom.get('dicty-result-div').innerHTML = 'And get your result here  ......';
    });

    var excelButton = new YAHOO.widget.Button({
        container: 'id-excel-button',
        label: 'Get as Excel',
        type: 'button',
        id: 'dicty-excel'
    });

    excelButton.on('click', fetchExcelData);


    YAHOO.util.Event.addFocusListener('dicty-seq-ids',
    function() {
        var initData = Dom.get('dicty-seq-ids').value;
        if (initData.match('Paste')) {
            Dom.get('dicty-seq-ids').value = '';
        }
    });

    function fetchExcelData(ev) {
        var ids = Dom.get('dicty-seq-ids').value;
        var validatedIDs = ids.replace(/\s+/g, ":");
        validatedIDs = validatedIDs.replace(/^:/, '');
        //needs more validation here
        // if fails do not proceed
        var fromDropDown = Dom.get('dicty-from-option');
        var indexFrom = fromDropDown.selectedIndex;
        var from = fromDropDown.options[indexFrom].value;

        var toDropDown = Dom.get('dicty-to-option');
        var indexTo = toDropDown.selectedIndex;
        var to = toDropDown.options[indexTo].value;

        if ((indexFrom === indexTo) && (indexFrom !== 0)) {
            loaderHTML = '<b><p>Selected combination cannot be converted </p></b>' +
            '<b><p>Check Hint for help</p></b>';
            Dom.get('dicty-result-div').innerHTML = loaderHTML;
            return;
        }


        var userText = '<p id="dicty-excel-message"> <b> Generating excel file' +
        'please wait(might take a while) ..........</b>' +
        '</p> <div id="dicty-excel-spinner"></div>';

        var xlsForm = '<p><form id="dicty-excel-form" method="post">' +
        '<input type="hidden" name="from" value="' + from + '" />' +
        '<input type="hidden" name="to" value="' + to + '" />' +
        '<input type="hidden" name="ids" value="' + validatedIDs + '" />' +
        '</form></p>' + userText;

        Dom.get('dicty-result-div').innerHTML = xlsForm;
        var fadeOutTxt = new YAHOO.util.Anim('dicty-excel-message', {
            opacity: {
                to: 0
            }
        },
        14, YAHOO.util.Easing.easeOut);
        var fadeOutImg = new YAHOO.util.Anim('dicty-excel-spinner', {
            opacity: {
                to: 0
            }
        },
        25, YAHOO.util.Easing.easeOut);
        var form = Dom.get('dicty-excel-form');
        form.action = '/output';
        form.submit();
        fadeOutTxt.animate();
        fadeOutImg.animate();
    }

    function onClick(ev) {
        var ids = Dom.get('dicty-seq-ids').value;
        var validatedIDs = ids.replace(/\s+/g, ":");
        validatedIDs = validatedIDs.replace(/^:/, '');
        //needs more validation here
        // if fails do not proceed
        var fromDropDown = Dom.get('dicty-from-option');
        var indexFrom = fromDropDown.selectedIndex;
        var from = fromDropDown.options[indexFrom].value;

        var toDropDown = Dom.get('dicty-to-option');
        var indexTo = toDropDown.selectedIndex;
        var to = toDropDown.options[indexTo].value;

        if ((indexFrom === indexTo) && (indexFrom !== 0)) {
            loaderHTML = '<b><p>Selected combination cannot be converted </p></b>' +
            '<b><p>Check Hint for help</p></b>';
            Dom.get('dicty-result-div').innerHTML = loaderHTML;
        }
        else {
            var postData = 'from=' + from + '&to=' + to + '&ids=' + validatedIDs;
            var request = YAHOO.util.Connect.asyncRequest('POST', '/translate', callback, postData);

            var loaderHTML = '<p>Searching please wait ........... </p>';
            loaderHTML += '<img id="result_loader" src="/inc/images/ajax-loader3.gif">' +
            '</img>';
            Dom.get('dicty-result-div').innerHTML = loaderHTML;
        }
    }

    function setResult(obj) {
        var results = obj.responseText;
        var textarea = '<textarea id="dicty-result-ids" name="dicty-result-id" cols="40" rows="22" readonly="true">' +
        results + '</textarea>';
        Dom.get('dicty-result-div').innerHTML = textarea;

    }

    function onFailure(obj) {
        Dom.get('result').innerHTML = '<p>' + obj.statusText + '</p>';
    }
};

YAHOO.util.Event.onDOMReady(YAHOO.example.init);
