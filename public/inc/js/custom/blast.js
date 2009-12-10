function init() {
    var Dom = YAHOO.util.Dom;
    //var logger = new YAHOO.widget.LogReader();
    var blast = 'run-blast-button',
        reset = 'reset-blast-button',
        ncbi = 'ncbi-blast-button',
        submitID = 'submit-id-button',
        toggleOptions = 'showOptions',
        options = 'blast-options',
        sequence = 'blast-sequence';

    /* --- Options --- */
    var eValueDropDown = Dom.get('e-value'),
        numAlignDropDown = Dom.get('num-align'),
        wordSizeDropDown = Dom.get('word-size-option'),
        matrixDropDown = Dom.get('matrix-option'),
        gappedCheckbox = Dom.get('gapped-alignment'),
        filterCheckbox = Dom.get('filter-alignment');

    /* --- Dropdowns --- */
    var blastProgramDropDown = Dom.get('blast-program-option'),
        blastDatabaseDropDown = Dom.get('blast-database-option'),
        blastFeatureDropDown = Dom.get('blast-feature-option'),
        blastSequenceDropDown = Dom.get('blast-sequence-option'),
        blastQueryID = Dom.get('query-primary-id'),
        blastOptions = Dom.get('e-value');

    var programOptions = ['-- Please Select a Program --', 'blastn', 'blastp', 'blastx', 'tblastx', 'tblastn'];
    var programValues = ['unselected', 'blastn', 'blastp', 'blastx', 'tblastx', 'tblastn'];

    var databaseOptions = [
        '-- Please Select a Database --',
        'dictyBase Coding Sequences - DNA',
        'dictyBase Genomic Sequences - DNA',
        'dictyBase Protein Sequences - Protein',
        'EST Sequences - DNA',
        'Full chromosomes 1,2,3,4,5,6,M; Floating contigs 2F and 3F - DNA'
    ];
    var databaseValues = [
        'unselected',
        'dicty_primary_cds',
        'dicty_primary_genomic',
        'dicty_primary_protein',
        'dicty_est',
        'dicty_chromosomal'
    ];
    
    /* Initialization for form dropdowns */
    function initDropDown(el, options, values, defaultValue) {
        var selectedIndex = 0;
        el.options.length = 0;
        for (i in options) {
            if ((defaultValue !== undefined) && (options[i] == defaultValue)) {
                selectedIndex = i;
            }
            el.options[el.options.length] = new Option(options[i], values[i]);
        }
        el[selectedIndex].selected = true;
    }

    function selectDropDown(el, value) {
        var selectedIndex = 0;
        for (var i=0;i< el.options.length;i++) {
            if (el.item(i).innerHTML == value) {
                selectedIndex = i;
            }
        }
        el[selectedIndex].selected = true;
    }

    function initFeatureDropDown(el, data) {
        Dom.addClass(Dom.get('blast-id-selection-warn'), 'hidden');
        el.options.length = 0;
        if (data.length == 1) {
            el.options[el.options.length] = new Option(data[0].id + ' - ' + data[0].description, data[0].id);
            el.options.item(0).selected = true;
            onFeatureChange(undefined,el);
        }
        else{ 
            el.options[el.options.length] = new Option('-- Please Select a Sequence --', 'unselected');
            for (i in data) {
                el.options[el.options.length] = new Option(data[i].id + ' - ' + data[i].description, data[i].id);
            }
        }
        var parent = Dom.getAncestorByTagName(el, 'div');
        Dom.removeClass(parent, 'hidden');
    } 
       
    function initSeqTypeDropDown(el, data) {  
        var prefilledSequence = el.options.length > 0 ? el.options.item(0).innerHTML : '',
        id = blastFeatureDropDown.options[blastFeatureDropDown.selectedIndex].value || Dom.get('query-primary-id').value;

        el.options.length = 0;

        if (data.length == 1) {
            postData = 'primary_id=' + id + '&sequence=' + data[0];
            request = YAHOO.util.Connect.asyncRequest('POST', '/db/cgi-bin/dictyBase/yui/get_fasta.pl?primary_id=', seqTypeCallback, postData);
        }
        else {
            el.options[el.options.length] = new Option('-- Please Select a Sequence Type--', 'unselected');
            var selectedIndex = 0;
            for (i in data) {
                if ((prefilledSequence !== '') && (data[i].match(prefilledSequence))) {
                    selectedIndex = i;
                    selectedIndex++;
                    postData = 'primary_id=' + id + '&sequence=' + data[i];
                    request = YAHOO.util.Connect.asyncRequest('POST', '/db/cgi-bin/dictyBase/yui/get_fasta.pl?primary_id=', seqTypeCallback, postData);
                }
                el.options[el.options.length] = new Option(data[i], data[i]);
            }

            el.options.item(selectedIndex).selected = true;
            var parent = Dom.getAncestorByTagName(el, 'div');
            
            if (prefilledSequence !== ''){
                var defaultProgram = prefilledSequence.match('Protein') ? 'blastp': 'blastn';
                var defaultDatabase = 
                    prefilledSequence.match('Genomic') ? 'dictyBase Genomic Sequences - DNA': 
                    prefilledSequence.match('coding')||prefilledSequence.match('transcript') ? 'dictyBase Coding Sequences - DNA' : 'unselected';
                selectDropDown(blastProgramDropDown, defaultProgram);
                adjustDatabaseDropdown(defaultProgram);
                selectDropDown(blastDatabaseDropDown, defaultDatabase);
                defaultValue = defaultProgram == 'blastn' ? '11': '3';
                selectDropDown(wordSizeDropDown,defaultValue);
            }            
            Dom.removeClass(parent, 'hidden');
        }
    }

    function initOptions(el) {
        var index = el.selectedIndex,
        program = el.options[index].value;
        
        /* --- e-value selector --- */
        var options = ['1000', '500', '100', '10', '1', '0.1', '0.001', '1e-5', '1e-25', '1e-50', '1e-100'];
        var defaultValue = '0.1';
        initDropDown(eValueDropDown, options, options, defaultValue);


        /* --- Number of Alignments selector --- */
        options = ['5', '25', '50', '100', '250', '500', '750', '1000'];
        defaultValue = '50';
        initDropDown(numAlignDropDown, options, options, defaultValue);

        /* --- Word Size selector --- */
        options = ['2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'];
        defaultValue = '3';
        initDropDown(wordSizeDropDown, options, options, defaultValue);

        /* --- Matrix selector --- */
        options = ['BLOSUM45', 'BLOSUM62', 'BLOSUM80', 'PAM30', 'PAM70'];
        defaultValue = 'BLOSUM62';
        initDropDown(matrixDropDown, options, options, defaultValue);

        /* --- Gapped Alignment --- */
        gappedCheckbox.checked = true;

        /* --- Filtering --- */
        filterCheckbox.checked = true;
    }

    /* Gets blast result and window, where result should be rendered, checks if result contains error 
        message and displays it. Otherwise renders blast result 
    */

    /* Failure handling */
    function onFailure(obj) {
        Dom.get('blast-id-selection-warn').innerHTML = '<p>' + obj.statusText + '</p>';
    }

    /* Callbacks definitions */
    /* Fired on server responce to acync call fired by ID "submit" button, recieves list of corresponding 
        sequences in JSON format, or error message 
    */
    var idCallback = {
        success: function(obj) {
            try {
                var results = YAHOO.lang.JSON.parse(obj.responseText);
            }
            catch(e) {
                Dom.get('blast-id-selection-warn').innerHTML = 'Please provide valid DDB or DDB_G ID';
                Dom.removeClass(Dom.get('blast-id-selection-warn'), 'hidden');
                return;
            }
            initFeatureDropDown(blastFeatureDropDown, results);
        },
        failure: onFailure
    };
    /* Fired on server responce to acync call fired by "Select Feature" dropdown, recieves list of 
        corresponding features in JSON format, or error message 
    */
    var featureCallback = {
        success: function(obj) {
            try {
                var results = YAHOO.lang.JSON.parse(obj.responseText);
            }
            catch(e) {
                Dom.get('blast-id-selection-warn').innerHTML = 'Please provide valid DDB or DDB_G ID';
                Dom.removeClass(Dom.get('blast-id-selection-warn'), 'hidden');
                return;
            }
            initSeqTypeDropDown(blastSequenceDropDown, results);
        },
        failure: onFailure
    };
    /* Fired on server responce to acync call fired by "Select Sequence" dropdown, gets FASTA formatted sequence */
    var seqTypeCallback = {
        success: function(obj) {
            Dom.get(sequence).value = obj.responseText;
            Dom.removeClass(sequence, 'warning');
        },
        failure: onFailure
    };
    /* Fired on server responce to BLAST call, gets BLAST result and window to render it */    
    var callback = {
        success: function(obj){
            var results = obj.responseText;
            var resultWindow = obj.argument;
            if (results.match('BLAST') && !(results.match('Sorry'))) {
                var form =
                '<form method="post" name="blast_report" action="/tools/blast/report">' +
                '<textarea name="report" style="display:none;" >' + results + '</textarea></form>';
                
                resultWindow.document.write(form);
                resultWindow.document.close();
                resultWindow.document.forms.blast_report.submit();
            }
            else {
                errorBox = Dom.get('run-blast-warning');
                errorBox.innerHTML = results;
                Dom.removeClass('run-blast-warning', 'hidden');
                resultWindow.document.write(results);
                resultWindow.document.close();
            }
        },
        failure: onFailure
    };

    /* onChange functions */
    function onProgramChange(ev, el) {
        var index = el.selectedIndex,
        program = el.options[el.selectedIndex].value,
        info = '';

        if (program == 'blastn') {
            info = 'DNA query to DNA database';
        }
        else if (program == 'blastp') {
            info = 'Protein query to protein database';
        }
        else if (program == 'blastx') {
            info = 'Translated (6 frames) DNA query to protein database';
        }
        else if (program == 'tblastx') {
            info = 'Translated (6 frames) DNA query to translated (6 frames) DNA database';
        }
        else if (program == 'tblastn') {
            info = 'Protein query to translated (6 frames) DNA database';
        }

        YAHOO.util.Dom.get('blast-program-option-info').innerHTML = info;
        if (Dom.hasClass('blast-program-option-info', 'hidden')) {
            Dom.removeClass('blast-program-option-info', 'hidden');
        }
        if (Dom.hasClass('blast-program-option-info', 'warning')) {
            Dom.removeClass('blast-program-option-info', 'warning');
        }

        adjustDatabaseDropdown(program);
        defaultValue = program == 'blastn' ? '11': '3';
        selectDropDown(wordSizeDropDown,defaultValue);
    }
    
    function onFeatureChange(ev, el) {
        var index = el.selectedIndex,
        id = el.options[el.selectedIndex].value;

        Dom.addClass(Dom.getAncestorByTagName(blastSequenceDropDown, 'div'), 'hidden');
        Dom.addClass('blast-id-selection-warn', 'hidden');
        
        if (id == 'unselected') {
            return;
        }
        var postData = 'from=' + 'DDB ID' + '&to=' + 'sequence_types' + '&ids=' + id;
        var request = YAHOO.util.Connect.asyncRequest('POST', '/translate', featureCallback, postData);
    }
    
    function onSequenceChange(ev, el) {
        var sequence = el.options[el.selectedIndex].value,
        blastFeatureDropDown = Dom.get('blast-feature-option'),
        id = blastFeatureDropDown.options[blastFeatureDropDown.selectedIndex].value || Dom.get('query-primary-id').value;
        
        if (sequence == 'unselected') {
            return;
        }
        
        var defaultProgram = sequence.match('Protein') ? 'blastp': 'blastn';
        var defaultDatabase = 
            sequence.match('Genomic') ? 'dictyBase Genomic Sequences - DNA': 
            sequence.match('coding')||sequence.match('transcript') ? 'dictyBase Coding Sequences - DNA' : 'unselected';
        selectDropDown(blastProgramDropDown, defaultProgram);
        adjustDatabaseDropdown(defaultProgram);
        selectDropDown(blastDatabaseDropDown, defaultDatabase);
        defaultValue = defaultProgram == 'blastn' ? '11': '3';
        selectDropDown(wordSizeDropDown,defaultValue);

        var postData = 'primary_id=' + id + '&sequence=' + sequence;
        var request = YAHOO.util.Connect.asyncRequest('POST', '/db/cgi-bin/dictyBase/yui/get_fasta.pl?primary_id=', seqTypeCallback, postData);
    }
    
    function adjustDatabaseDropdown(program) {
        var blastDatabaseDropDown = Dom.get('blast-database-option'),
        databases = blastDatabaseDropDown.options;

        if (program.match('Select')) {
            initDatabaseDropdown(blastDatabaseDropDown);
        }
        else if (program == 'blastp' || program == 'blastx') {
            blastDatabaseDropDown.options.length = 0;
            blastDatabaseDropDown.options[blastDatabaseDropDown.options.length] = new Option('dictyBase Protein Sequences - Protein', 'dicty_primary_protein');
            blastDatabaseDropDown.isSelected = true;
        }
        else if (program == 'blastn' || program == 'tblastx' || program == 'tblastn') {
            blastDatabaseDropDown.options.length = 0;
            blastDatabaseDropDown.options[blastDatabaseDropDown.options.length] = new Option('-- Please Select a Database --', 'unselected');
            blastDatabaseDropDown.options[blastDatabaseDropDown.options.length] = new Option('dictyBase Coding Sequences - DNA', 'dicty_primary_cds');
            blastDatabaseDropDown.options[blastDatabaseDropDown.options.length] = new Option('dictyBase Genomic Sequences - DNA', 'dicty_primary_genomic');
            blastDatabaseDropDown.options[blastDatabaseDropDown.options.length] = new Option('EST Sequences - DNA', 'dicty_est');
            blastDatabaseDropDown.options[blastDatabaseDropDown.options.length] = new Option('Full chromosomes 1,2,3,4,5,6,M; Floating contigs 2F and 3F - DNA', 'dicty_chromosomal');
        }
        Dom.addClass('blast-database-option-warn', 'hidden');
    }

    function getIDMapping(id) {
        Dom.addClass(Dom.getAncestorByTagName(Dom.get('blast-sequence-option'), 'div'), 'hidden');
        Dom.addClass(Dom.getAncestorByTagName(Dom.get('blast-feature-option'), 'div'), 'hidden');
        Dom.addClass(Dom.get('blast-id-selection-warn'), 'hidden');
        Dom.get(sequence).value = '';

        if (id.match('DDB_G')) {
            var postData = 'from=' + 'DDB_G ID' + '&to=' + 'features' + '&ids=' + id;
            var request = YAHOO.util.Connect.asyncRequest('POST', '/translate', idCallback, postData);
        }
        else if (id.match('DDB')) {
            postData = 'from=' + 'DDB ID' + '&to=' + 'sequence_types' + '&ids=' + id;
            request = YAHOO.util.Connect.asyncRequest('POST', '/translate', featureCallback, postData);
        }
        else {
            Dom.get('blast-id-selection-warn').innerHTML = 'Please provide valid DDB or DDB_G ID';
            Dom.removeClass(Dom.get('blast-id-selection-warn'), 'hidden');
        }
    }
    
    /* --- Event subscribers --- */
    YAHOO.util.Event.onAvailable(blastProgramDropDown, function(){ 
        initDropDown(blastProgramDropDown, programOptions, programValues);
    });
    
    YAHOO.util.Event.onAvailable(blastDatabaseDropDown, function(){
        initDropDown(blastDatabaseDropDown, databaseOptions, databaseValues);
    });
    
    YAHOO.util.Event.onAvailable(blastOptions, initOptions, blastProgramDropDown);
    
    YAHOO.util.Event.onDOMReady( function() {
        if (blastQueryID.value === '') {
            return;
        }
        getIDMapping(blastQueryID.value);
    });

    YAHOO.util.Event.on(blastProgramDropDown, 'change', onProgramChange, blastProgramDropDown);
    YAHOO.util.Event.on(blastFeatureDropDown, 'change', onFeatureChange, blastFeatureDropDown);
    YAHOO.util.Event.on(blastSequenceDropDown, 'change', onSequenceChange, blastSequenceDropDown);
    YAHOO.util.Event.on(blastDatabaseDropDown, 'change', function() {
        Dom.addClass('blast-database-option-warn', 'hidden');
    });

    /* --- BLAST --- */
    function validateParameters(blastType) {
        if (Dom.get('blast-program-option').selectedIndex === 0) {
            YAHOO.util.Dom.get('blast-program-option-info').innerHTML = 'Please select a program to run';
            Dom.addClass('blast-program-option-info', 'warning');
            Dom.removeClass('blast-program-option-info', 'hidden');
            return false;
        }
        if (Dom.get(sequence).value.match('Paste') || Dom.get(sequence).value === '') {
            YAHOO.util.Dom.get(sequence).value = 'Please type or paste a query sequence here';
            Dom.addClass(sequence, 'warning');
            return false;
        }
        if (blastType == 'ncbi-blast') {
            return true;
        }
        if (Dom.get('blast-database-option').options.length > 1 && Dom.get('blast-database-option').selectedIndex === 0) {
            Dom.removeClass('blast-database-option-warn', 'hidden');
            return false;
        }
        return true;
    }

    function runBlast() {
        Dom.addClass('run-blast-warning', 'hidden');
        var valid = validateParameters('blast');
        if (valid) {
            var program = blastProgramDropDown.options[blastProgramDropDown.selectedIndex].value,
            database = blastDatabaseDropDown.options[blastDatabaseDropDown.selectedIndex].value,
            eValue = eValueDropDown.options[eValueDropDown.selectedIndex].value,
            numAlign = numAlignDropDown.options[numAlignDropDown.selectedIndex].value,
            wordSize = wordSizeDropDown.options[wordSizeDropDown.selectedIndex].value,
            matrix = matrixDropDown.options[matrixDropDown.selectedIndex].value,
            gapped = gappedCheckbox.checked ? 'T': 'F',
            filter = filterCheckbox.checked ? 'T': 'F',
            fasta = Dom.get(sequence).value;

            if ((database == 'dicty_chromosomal') && (filter == 'F')) {
                if ((program === 'tblastn') || (program === 'tblastx')) {
                    filter = 'm S';
                }
                else {
                    filter = 'm D';
                }
            }
            var postData =
            'program=' + program +
            '&database=' + database +
            '&evalue=' + eValue +
            '&limit=' + numAlign +
            '&wordsize=' + wordSize +
            '&matrix=' + matrix +
            '&gapped=' + gapped +
            '&filter=' + filter +
            '&sequence=' + fasta;

            resultWindow = window.open();
            resultWindow.document.write('Please wait for results to be loaded');
            resultWindow.document.close();
            callback.argument = resultWindow;
            var request = YAHOO.util.Connect.asyncRequest('POST', '/tools/blast', callback, postData);
        }
    }

    function runNcbiBlast() {
        var valid = validateParameters('ncbi-blast');
        if (valid) {
            var program = blastProgramDropDown.options[blastProgramDropDown.selectedIndex].value,
            fasta = Dom.get(sequence).value,
            page;

            if ((program == 'tblastn') || (program == 'tblastx') || (program == 'blastx')) {
                page = 'Translations';
            }
            else if (program == 'blastp') {
                page = 'Proteins';
            }
            else {
                page = 'Nucleotides';
            }
            resultWindow = window.open();

            var form =
            '<form method="post" name="ncbi_blast_form" action="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi">' +
            '<input name="PAGE"  type="hidden" value="' + page + '">' +
            '<input name="PROGRAM" type="hidden" value="' + program + '">' +
            '<input name="QUERY"   type="hidden" value="' + fasta + '">' +
            '<input name="FILTER"  type="hidden" value="L"></form>';
            resultWindow.document.write('Please wait while you are redirected to NCBI BLAST.' + form);
            resultWindow.document.forms.ncbi_blast_form.submit();
            resultWindow.document.close();
        }
    }

    /* --- Buttons --- */
    var BlastButton = new YAHOO.widget.Button({
        container: blast,
        label: 'BLAST',
        type: 'button',
        id: 'run-blast'
    });
    BlastButton.on('click', runBlast);

    var resetButton = new YAHOO.widget.Button({
        container: reset,
        label: 'Reset',
        type: 'button',
        id: 'dicty-button'
    });
    resetButton.on('click', function() {
        Dom.get(sequence).value = 'Paste your sequence here  ......';
        initDropDown(blastProgramDropDown, programOptions, programValues);
        initDropDown(blastDatabaseDropDown, databaseOptions, databaseValues);
        initOptions(blastProgramDropDown);
        blastQueryID.value = '';
        Dom.addClass(Dom.getAncestorByTagName(blastFeatureDropDown, 'div'), 'hidden');
        Dom.addClass(Dom.getAncestorByTagName(blastSequenceDropDown, 'div'), 'hidden');
        Dom.addClass('blast-id-selection-warn', 'hidden');
    });

    var NcbiBlastButton = new YAHOO.widget.Button({
        container: ncbi,
        label: 'BLAST at NCBI',
        type: 'button',
        id: 'dicty-button'
    });
    NcbiBlastButton.on('click', runNcbiBlast);

    YAHOO.util.Event.on('submit-primary-id', 'click', function() {
        getIDMapping(blastQueryID.value);
    });
    
    YAHOO.util.Event.on('showOptions', 'click', function() {
        if (Dom.hasClass(options, 'hidden')) {
            Dom.removeClass(options, 'hidden');
        }
        else {
            Dom.addClass(options, 'hidden');
        }
    });
    
    YAHOO.util.Event.addFocusListener(sequence, function() {
        var initData = Dom.get(sequence).value;
        if ((initData.match('Paste')) || (initData.match('paste'))) {
            Dom.get(sequence).value = '';
            Dom.removeClass(sequence, 'warning');
        }
        else if (initData.match('paste')) {
            Dom.get(sequence).value = '';
            Dom.removeClass(sequence, 'warning');
        }
    });
}
