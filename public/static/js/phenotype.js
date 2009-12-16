
// Global variables
var selectedrow = undefined;
var url = "/db/cgi-bin/ajax_search/genetics/process_phenotype_data.pl";

// All the ids go to the server as Divs with hidden CSS For eg: <div class="hidden">22</div>

/* Inserts a new row in the table*/
function insert_row( target )
{
   
   if(!validate_data()) {
   	return false;
   }
   
   if(undefined != selectedrow)
   {
   	document.getElementById(target).rows[selectedrow].bgColor = "white";
   	selectedrow = undefined;
   }
   
   var genotype = document.getElementById('genotype');   
   var genetic_context = document.getElementById('genetic_context');
   var entity = document.getElementById('entity');
   var quality = document.getElementById('quality');
   var reference= document.getElementById('reference');
   var environment = document.getElementById('environment');   
   var assay = document.getElementById('assay');   
   var notes = document.getElementById('notes');   
   
   
   var table_row = document.getElementById(target).insertRow(1);
     
   table_row.insertCell(0).innerHTML = '<IMG src="/images/delete.PNG" width="22" height="24" border="0" onclick="delete_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)"/> <IMG src="/images/edit.PNG" width="35" height="20" border="0" onclick="edit_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)">&nbsp;&nbsp;<IMG src="/images/copy.PNG" width="22" height="20" border="0" onclick="copy_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)">';
   table_row.insertCell(1).innerHTML = genotype.value + get_hidden_element(document.getElementById('genotype_id').value);      
   table_row.insertCell(2).innerHTML = genetic_context.value  + get_hidden_element(document.getElementById('genetic_context_id').value);
   table_row.insertCell(3).innerHTML = entity.value + get_hidden_element(document.getElementById('entity_id').value);
   table_row.insertCell(4).innerHTML = quality.value + get_hidden_element(document.getElementById('quality_id').value);
   table_row.insertCell(5).innerHTML = reference.value + get_hidden_element(document.getElementById('reference_id').value);
   table_row.insertCell(6).innerHTML = environment.value + get_hidden_element(document.getElementById('environment_id').value);
   table_row.insertCell(7).innerHTML = assay.value + get_hidden_element(document.getElementById('assay_id').value);
   table_row.insertCell(8).innerHTML = notes.value;
   
   
   
   if(undefined != selectedrow)
   {
      selectedrow += 1;
   }
   
   
   
}

/* Deletes the row from the table */
function delete_row( target, row)
{
document.getElementById(target).deleteRow(row);
if((undefined != selectedrow) && (row < selectedrow))
{   
   selectedrow -= 1;
}

if(selectedrow == row)
{
  selectedrow = undefined;
}

}

/* Make the table row editable */
function edit_row( target, row)
{

var edit_row = document.getElementById(target).rows[row];

var genotype_cell_value = edit_row.cells[1].innerHTML;
document.getElementById('genotype').value = genotype_cell_value.substring(0, genotype_cell_value.indexOf("<"));
document.getElementById('genotype_id').value = genotype_cell_value.substring(genotype_cell_value.indexOf("<"), genotype_cell_value.length).stripTags();

var genetic_context_cell_value = edit_row.cells[2].innerHTML;
document.getElementById('genetic_context').value = genetic_context_cell_value.substring(0, genetic_context_cell_value.indexOf("<"));
document.getElementById('genetic_context_id').value = genetic_context_cell_value.substring(genetic_context_cell_value.indexOf("<"), genetic_context_cell_value.length).stripTags();

var entity_cell_value = edit_row.cells[3].innerHTML;
document.getElementById('entity').value = entity_cell_value.substring(0, entity_cell_value.indexOf("<"));
document.getElementById('entity_id').value = entity_cell_value.substring(entity_cell_value.indexOf("<"), entity_cell_value.length).stripTags();

var quality_cell_value = edit_row.cells[4].innerHTML;
document.getElementById('quality').value = quality_cell_value.substring(0, quality_cell_value.indexOf("<"));
document.getElementById('quality_id').value = quality_cell_value.substring(quality_cell_value.indexOf("<"), quality_cell_value.length).stripTags();

var reference_cell_value = edit_row.cells[5].innerHTML;
document.getElementById('reference').value = reference_cell_value.substring(0, reference_cell_value.indexOf("<"));
document.getElementById('reference_id').value = reference_cell_value.substring(reference_cell_value.indexOf("<"), reference_cell_value.length).stripTags();

var environment_cell_value = edit_row.cells[6].innerHTML;
document.getElementById('environment').value = environment_cell_value.substring(0, environment_cell_value.indexOf("<"));
document.getElementById('environment_id').value = environment_cell_value.substring(environment_cell_value.indexOf("<"), environment_cell_value.length).stripTags();


var assay_cell_value = edit_row.cells[7].innerHTML;
document.getElementById('assay').value = assay_cell_value.substring(0, assay_cell_value.indexOf("<"));
document.getElementById('assay_id').value = assay_cell_value.substring(assay_cell_value.indexOf("<"), assay_cell_value.length).stripTags();


document.getElementById('notes').value =  edit_row.cells[8].innerHTML;

if(undefined != selectedrow)
{
document.getElementById(target).rows[selectedrow].bgColor = "white";
}
selectedrow = row;
edit_row.bgColor = "lightgoldenrodyellow";

}


/* Copies the row on which this method is called */
function copy_row(target, row)
{
   var source_row = document.getElementById(target).rows[row];
   var new_row = document.getElementById(target).insertRow(1);
   
   new_row.innerHTML = source_row.innerHTML;
   
   /*
   new_row.insertCell(0).innerHTML = '<IMG src="/images/delete.PNG" width="22" height="24" border="0" onclick="delete_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)"/> <IMG src="/images/edit.PNG" width="35" height="20" border="0" onclick="edit_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)">&nbsp;&nbsp;<IMG src="/images/copy.PNG" width="22" height="20" border="0" onclick="copy_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)">';
   new_row.insertCell(1).innerHTML = source_row.cells[1].innerHTML;
   new_row.insertCell(2).innerHTML = source_row.cells[2].innerHTML;
   new_row.insertCell(3).innerHTML = source_row.cells[3].innerHTML;
   new_row.insertCell(4).innerHTML = source_row.cells[4].innerHTML;
   new_row.insertCell(5).innerHTML = source_row.cells[5].innerHTML;
   new_row.insertCell(6).innerHTML = source_row.cells[6].innerHTML;
   new_row.insertCell(7).innerHTML = source_row.cells[7].innerHTML;
   new_row.insertCell(8).innerHTML = source_row.cells[8].innerHTML;
   */
   
   if(undefined != selectedrow)
   {
         selectedrow += 1;
   }
   
   
}

/* Updates the changes made in the boxes to the table data */
function update_row(target)
{


if(undefined != selectedrow)
{
var row = document.getElementById(target).rows[selectedrow];

row.cells[1].innerHTML = document.getElementById('genotype').value + get_hidden_element(document.getElementById('genotype_id').value);
if(document.getElementById('genetic_context').value.length > 0) {
	row.cells[2].innerHTML = document.getElementById('genetic_context').value + get_hidden_element(document.getElementById('genetic_context_id').value);
}else {
	row.cells[2].innerHTML = document.getElementById('genetic_context').value;
}
row.cells[3].innerHTML = document.getElementById('entity').value  + get_hidden_element(document.getElementById('entity_id').value) ;

if(document.getElementById('quality').value.length > 0) {
	row.cells[4].innerHTML = document.getElementById('quality').value + get_hidden_element(document.getElementById('quality_id').value);
}else {
	row.cells[4].innerHTML = document.getElementById('quality').value;
}

if(document.getElementById('environment').value.length > 0) {
	row.cells[6].innerHTML = document.getElementById('environment').value + get_hidden_element(document.getElementById('environment_id').value);
}else {
	row.cells[6].innerHTML = document.getElementById('environment').value;
}

if(document.getElementById('assay').value.length > 0) {
	row.cells[7].innerHTML = document.getElementById('assay').value + get_hidden_element(document.getElementById('assay_id').value);
}else {
	row.cells[7].innerHTML = document.getElementById('assay').value;
}



row.cells[5].innerHTML = document.getElementById('reference').value  + get_hidden_element(document.getElementById('reference_id').value);
row.cells[8].innerHTML = document.getElementById('notes').value;

}
}


/* Sends the data to the server and commits the data to the database */
function commit_data(target)
{
   /*
   var confirmed = confirm("Are you sure you want to commit this data. Any data not currently retrieved in the tool will be deletd");
   
   if(!confirmed) {
   	return false;
   }
   */
   
   set_processing_message();
   var rows = document.getElementById(target).rows;
   var data_array = new Array();
      
   for(i=1; i<rows.length;i++)
   {
   	var source_row = rows[i];
   	var cells = source_row.cells;   	
   	
   	d = new Data(cells[0].innerHTML, cells[1].innerHTML, cells[2].innerHTML, cells[3].innerHTML, cells[4].innerHTML, cells[5].innerHTML, cells[6].innerHTML, cells[7].innerHTML, cells[8].innerHTML);
   	data_array[i] = d;   	        
   }
   
   // Curators wants to delete all the annotations from this strain
   if(rows.length == 0) {
   
   
   }
   
   var json_string = data_array.toJSONString();   
   
   genotype_id = replace_carriage_returns(document.getElementById('genotype_id').value);
   
   var pars = 'genotype_id='+genotype_id+'&user='+document.getElementById('user').value;
   
   
   //alert(json_string);
   		
   var myAjax = new Ajax.Updater( 'results', url, { method: 'get', parameters: pars, requestHeaders: ['X-JSON', json_string]}); 
  
   
}

/* This is the data class to represent the table data */
function Data(experiment, genotype, genetic_context, entity, quality, reference, environment, assay, notes)
{
	this.genotype = replace_carriage_returns(genotype.substring(0, genotype.indexOf("<")));
	this.genotype_id = replace_carriage_returns(genotype.substring(genotype.indexOf("<"), genotype.length).stripTags());
		
	this.genetic_context = replace_carriage_returns(genetic_context.substring(0, genetic_context.indexOf("<")));
	this.genetic_context_id = replace_carriage_returns(genetic_context.substring(genetic_context.indexOf("<"), genetic_context.length).stripTags());
	
	this.entity = replace_carriage_returns(entity.substring(0, entity.indexOf("<")));
	//alert(this.entity);
	this.entity_id = replace_carriage_returns(entity.substring(entity.indexOf("<"), entity.length).stripTags());
	
	this.quality = replace_carriage_returns(quality.substring(0, quality.indexOf("<")));
	this.quality_id = replace_carriage_returns(quality.substring(quality.indexOf("<"), quality.length).stripTags());
	
	//this.reference = reference.substring(0, reference.indexOf("<"));
	this.reference = replace_carriage_returns(reference.substring(reference.indexOf("<"), reference.length).stripTags());
	
	this.environment = replace_carriage_returns(environment.substring(0, environment.indexOf("<")));
	this.environment_id = replace_carriage_returns(environment.substring(environment.indexOf("<"), environment.length).stripTags());

	this.assay = replace_carriage_returns(assay.substring(0, assay.indexOf("<")));
	this.assay_id = replace_carriage_returns(assay.substring(assay.indexOf("<"), assay.length).stripTags());

	
	this.experiment_id = experiment.substring(experiment.indexOf("<DIV"), experiment.length).stripTags();	
	this.experiment_id = this.experiment_id.replace("&nbsp;", "");
	this.experiment_id = replace_carriage_returns(this.experiment_id.replace("&nbsp;", ""));		
	//alert(this.experiment_id);
	this.notes = notes;
}

// Retrives the phenotype data from the server and displays in a table
function retrieve_data(target)
{	
	
	set_processing_message();
	clear_table_data('data');
	var genotype_id = document.getElementById('genotype_id').value;	
	
	if(genotype_id.length > 0)
	{
		var pars = 'action=retrieve&genotype_id='+genotype_id;
		var myAjax = new Ajax.Request( url, { method: 'post', parameters: pars, onComplete: load_table_data, onFailure: error_message}); 		
	
	}else
	{
	    alert("Genotype not properly set to retrieve the data.");
	}
}

// Loads data in to the table
function load_table_data(originalRequest, json_obj)
{
		
	for(i=0; i< json_obj.length; i++) 
	{	
	var table_row = document.getElementById('data').insertRow(1);
	
	table_row.insertCell(0).innerHTML = '<IMG src="/images/delete.PNG" width="22" height="24" border="0" onclick="delete_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)"/> <IMG src="/images/edit.PNG" width="35" height="20" border="0" onclick="edit_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)">&nbsp;&nbsp;<IMG src="/images/copy.PNG" width="22" height="20" border="0" onclick="copy_row(this.parentNode.parentNode.parentNode.parentNode.id,this.parentNode.parentNode.rowIndex)">' + get_hidden_element(json_obj[i].experiment_id);
	table_row.insertCell(1).innerHTML = json_obj[i].genotype + get_hidden_element(json_obj[i].genotype_id);   	

	if(json_obj[i].genetic_context) {
		table_row.insertCell(2).innerHTML = json_obj[i].genetic_context + get_hidden_element(json_obj[i].genetic_context_id);   			
	}else {
		table_row.insertCell(2).innerHTML = "&nbsp;";	
	}
	table_row.insertCell(3).innerHTML = json_obj[i].entity + get_hidden_element(json_obj[i].entity_id);   	

	if(json_obj[i].quality) {
		table_row.insertCell(4).innerHTML = json_obj[i].quality + get_hidden_element(json_obj[i].quality_id);   	
	}else {
		table_row.insertCell(4).innerHTML = "&nbsp;";	
	}
	
	table_row.insertCell(5).innerHTML = json_obj[i].reference_citation + get_hidden_element(json_obj[i].reference);   	

	if(json_obj[i].environment) {
		table_row.insertCell(6).innerHTML = json_obj[i].environment + get_hidden_element(json_obj[i].environment_id);   	
	}else {
		table_row.insertCell(6).innerHTML = "&nbsp;";		
	}
	
	if(json_obj[i].assay) {
		table_row.insertCell(7).innerHTML = json_obj[i].assay + get_hidden_element(json_obj[i].assay_id);   	
	}else {
		table_row.insertCell(7).innerHTML = "&nbsp;";		
	}	
	
	if(json_obj[i].notes) {
		table_row.insertCell(8).innerHTML = json_obj[i].notes;
	}else {
		table_row.insertCell(8).innerHTML  = "&nbsp;";		
	}
	
	}
	
	if(json_obj.length > 0) {
		success_message('Data loaded successfully ');   
	} else {
		success_message('No existing data');   
	}
	
	
}

// Returns hidden DIV
function get_hidden_element(value) 
{
	return '<DIV id="hidden">'+value+'</DIV>';
}

// Prints the Success Message
function success_message(message)
{

	var html_message = '<table width="50%" cellspacing="0" class="success"><tbody><tr><th class="success">MESSAGE</th></tr><tr><td class="success"><pre>';
	html_message += message;
	html_message += '</pre></td></tr></tbody></table>';

	document.getElementById('results').innerHTML = html_message;

}

// Print Error message
function error_message(XHR)
{
	var html_message = '<table width="50%" cellspacing="0" class="error"><tbody><tr><th class="error">MESSAGE</th></tr><tr><td class="error"><pre>';
	html_message += XHR.responseText;
	html_message += '</pre></td></tr></tbody></table>';
	document.getElementById('results').innerHTML = html_message;

}

// Print Error message
function check_commit(XHR)
{
	var html_message = '<table width="50%" cellspacing="0" class="error" ><tbody><tr><th class="error">MESSAGE</th></tr><tr><td class="error"><pre>';
	html_message += XHR.responseText;
	html_message += '</pre></td></tr></tbody></table>';
	document.getElementById('results').innerHTML = html_message;

}


// Prints the processig message
function set_processing_message()
{
	var html_message = '<table width="50%" cellspacing="0"><tbody><tr><td><IMG src="/images/timer.gif" width="64" height="64" border="0"/></td>';
	html_message += "<td>&nbsp;&nbsp;&nbsp;&nbsp;<b>Request is being processed by the server ................</b>";
	html_message += '</td></tr></tbody></table>';
	document.getElementById('results').innerHTML = html_message;
	

}

//Clears all the table data
function clear_table_data(target)
{

	var rows = document.getElementById(target).rows.length;

for(i=1; i< rows; i++) 
{
	document.getElementById(target).deleteRow(1);
}

}


function validate_data()
{
	var genotype = document.getElementById('genotype').value;   
	var genotype_id = document.getElementById('genotype_id').value;   
	
	var error = "";
	if(!(genotype.length > 0) || !(genotype_id.length > 0)) {
		
		error += "- Strain\n";		
	}
	
	
	
	var entity = document.getElementById('entity').value;
	var entity_id = document.getElementById('entity_id').value;
	
	
	if(!(entity.length > 0) || !(entity_id.length > 0)) {
			
			error += "- Entity\n";		
	}
	
	var reference = document.getElementById('reference').value;
	var reference_id = document.getElementById('reference_id').value;
	
	//alert(reference_id);
	
	if(!(reference.length > 0) || !(reference_id.length > 0)) {
				
				error += "- Reference\n";		
	}
	
	var environment = document.getElementById('environment');   
	var assay = document.getElementById('assay');   
	var notes = document.getElementById('notes');   
   
	if(error.length > 0) {
		alert ("The following field(s) are compulsory and need to be set properly\n"+error);
		return false;
	}
	
	return true;
	
}

function replace_carriage_returns( text )
{
	return text.replace("\n","").replace("\r","")

}


// This is a odd man out method added to the tool to take care of 
// the special case of loading the strain data table
function load_strain_table(termid, term){
           if ( !isNaN( termid ) ) {
            var pars = 'termid=' + termid;
            var myAjax = new Ajax.Updater('terminfo', "/db/cgi-bin/ajax_search/genetics/genotype.pl", {method: 'get', parameters: pars } );
            document.data_table.genotypeid.value = termid;
	    document.data_table.genotype.value = term;	    	    
            retrieve_data('data');
         }
         
}
