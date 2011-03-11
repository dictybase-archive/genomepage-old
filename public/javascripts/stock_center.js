function is_sc_search_term_empty()
{

strfield1=document.scform.search_term.value

  //name field
    if (strfield1 == "" || strfield1 == null)
    {
    alert("\"Search text\" is a mandatory field.\nPlease amend and retry.");
    return false;
    }
    return true;
    
}


function mut_popup(mylink, windowname)
{
if (! window.focus)return true;
var href;
if (typeof(mylink) == 'string')
href=mylink;
else
href=mylink.href;
NewWindow(href, windowname, 500, 300, "center");
//window.open(href, windowname, 'width=400,height=270');
return false;
}

var last_selected_val = -1;
function open_selection_popup_window(value)
{
		
	
	
	if(!(last_selected_val == value))
	{

	//	alert(value);
		if(value == "type")
		{		
			settings = "width=350,height=600,scrollbars=1";
			var win = window.open("/db/cgi-bin/dictyBase/SC/search_options.pl?type=strain_characterstics", "select_window",settings);
			win.opener.name = "opener";
			document.scform.column.options[11].selected = true;
	
		}else if((value == "mut method") || (value == "mut_method"))
		{
			
			//alert("here....");
			settings = "width=400,height=500";
			var win = window.open("/StockCenter/mutagenesis_method.html", "select_window",settings);
			win.opener.name = "opener";		
			 document.scform.column.options[4].selected = true;
	
		}
		last_selected_val = value;
	
	}else
	{
		last_selected_val = -1; 
	}
	
	//return true;
}


function insert_selected_text(name)
{
	
	var val = getRadioValue(name);
	opener.document.scform.search_term.value = val;
	window.close();
	return true;

}

function getFormGroup(name) {return document.getElementsByName(name);}function getRadio(name) {elements = getFormGroup(name);if (elements)/* loop over all the radio buttons */for (i = 0; i < elements.length; i++)if (elements[i].checked)return elements[i];/* either no group by that name was foundor none were selected */return null;}function getRadioValue(name) {element = getRadio(name);if (element)return element.value;/* there must not have been a radio buttonselected */return '';}

function change_text(checkbox_object, text_area_object, text)
{
	if(checkbox_object.checked)
	{
		text_area_object.value = text;
	}else
	{
		text_area_object.value = '';
	}

}

function stock_center_search_options(searchdbarray)
{

var search_db; 
search_db = searchdbarray.value;
	           
var option_obj = document.scform.column;	
option_obj.length = 0;

if(search_db == "strains")
{
	
var text_value = new Array("All", "Depositor", "Genotype", "Keyword", "Mutagenesis method", "Parental strain", "Stock center phenotype","Plasmid", "Species", "Strain ID", "Strain descriptor/Synonyms/Systematic name", "Strain characteristics");	
var option_value = new Array("all", "depositor", "genotype", "keyword", "mut method", "parental strain", "phenotype","plasmid", "species", "id", "name", "type", "sys_name");	

var i=0;
for(i=0; i<12; i++)
{

	option_obj.options[i] =  new Option(text_value[i], option_value[i]);	
	
	if( text_value[i] == "Strain descriptor/Synonyms/Systematic name") 
	{
		option_obj.options[i].selected = true; 
	}
}

}else if(search_db == "plasmids")
{

var i=0;

var text_value = new Array("All", "Depositor", "Genbank accession number", "ID", "Keywords", "Name");	
var option_value = new Array("all", "depositor", "genbank_accession_number",  "id", "keywords","name");	

for(i=0; i<6; i++)
{	
	option_obj.options[i] =  new Option(text_value[i], option_value[i]);	
}
	

}else
{
	alert(searchdbarray[0].checked);
	alert(searchdbarray[1].checked);
	searchdbarray[0].checked = 0;
	searchdbarray[1].checked = 0;

}

}					


function change_action_url(url)
{
	document.shipping_form.action = url;			
	document.shipping_form.submit();
}

function loadCart(doc)
{

	var i=0;
	for(i=1; i<13; i++)
	{		
		if(document.forms[i].add.checked)
		{					
				
			AddToCart(doc.forms[i]);		
			
		}
	}
}

function change_action_url(url)
{
	document.shipping_form.action = url;			
	document.shipping_form.submit();
}


/* This method submits the stock center deletion form.  */

function deleteconformation(msg, url, func, id, name)
{

//alert("Inside function");
if(func == 'delete')
{
	
	var name = confirm(msg);
	if (name == true)
	{
		
		document.delete_form.action = url;
		document.delete_form.func.value = "delete";
		document.delete_form.submit();
		return true;

	}else
	{
		return false;
	}

}else if(func == "edit")
{
	
	//alert("EDIT ......");
	document.delete_form.action = url;
	document.delete_form.func.value = "edit";
	document.delete_form.id.value = id;
	document.delete_form.submit();
}else if(func == "add")
{
	
	//alert("ADD ......");
	document.delete_form.action = url;
	document.delete_form.id.value = id;
	document.delete_form.name.value = name;
	document.delete_form.submit();
}else if(func == "check")
{	
	document.delete_form.action = url;
	
	var input;
	var input2;
	var input3;
	
	input = document.getElementById('column');
	
	if(null == input) {
		input = document.createElement('INPUT');
		input.id = "column";
		input.name = "column";
		input.value= 'id';
		input.type = "text";			
		document.delete_form.appendChild(input);
	}	
	
	input2 = document.getElementById('searchdb');
	
	
	if(null == input2) {
		input2 = document.createElement('INPUT');
		input2.id = "searchdb";
		input2.name = "searchdb";
		input2.value= "inventory";
		input2.type = "text";
		document.delete_form.appendChild(input2);		
	}
		
	input3 = document.getElementById('search_term');
	
	if(null == input3) {
		input3 = document.createElement('INPUT');
		input3.id = "search_term";
		input3.name = "search_term";
		input3.value= id;
		input3.type = "text";	
		document.delete_form.appendChild(input3);		
	}else {
		input3.value= id;
	}
	
	document.delete_form.submit();
}else if(func == "editinventory")
{
	
	//alert("EDIT INVENTORY ......");
	document.delete_form.action = url;
	document.delete_form.id.value = id;
	document.delete_form.strain_name.value = name;
	document.delete_form.func.value = "edit";
	document.delete_form.submit();
	
}else if(func == "editplasmidinventory")
{
	
	//alert("EDIT INVENTORY ......");
	document.delete_form.action = url;
	document.delete_form.id.value = id;
	document.delete_form.plasmid_id.value = name;
	document.delete_form.func.value = "edit";
	document.delete_form.submit();
	
}
}



function strain_inventory_search_options(searchdbarray)
{

var search_db; 
search_db = searchdbarray.value;
	           
var option_obj = document.scform.column;	
option_obj.length = 0;

if(search_db == "strains")
{
	
var text_value = new Array("All", "Depositor", "Genotype", "Keyword", "Mutagenesis method", "Parental strain", "Stock Center Phenotype","Plasmid", "Species", "Strain ID", "Strain descriptor/Synonyms/Systematic name", "Strain characteristics");	
var option_value = new Array("all", "depositor", "genotype", "keyword", "mut method", "parental strain", "phenotype","plasmid", "species", "id", "name", "type", "sys_name");	

var i=0;
for(i=0; i<12; i++)
{

	option_obj.options[i] =  new Option(text_value[i], option_value[i]);	
	
	if( text_value[i] == "Strain descriptor/Synonyms/Systematic name") 
		{
			option_obj.options[i].selected = true; 
	}
}

}else if(search_db == "inventory")
{

var i=0;

var text_value = new Array("All", "Location", "Strain ID", "Strain descriptor/Synonyms/Systematic name");	
var option_value = new Array("all", "location", "id", "name", "sys_name");	

for(i=0; i<4; i++)
{	
	option_obj.options[i] =  new Option(text_value[i], option_value[i]);	
	
	if( text_value[i] == "Strain descriptor/Synonyms/Systematic name") 
			{
				option_obj.options[i].selected = true; 
	}
}
	

}else
{
	searchdbarray[0].checked = 0;
	searchdbarray[1].checked = 0;

}

}					
