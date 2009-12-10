//////////////////////////////////////////////////////
//
//  checkbox functions
//
/////////////////////////////////////////////////////

  //
  // removes selected options from select list
  //
  // args:
  //   form_field : checkbox group being checked
  //
   function checkbox_check_all( form_field ){
      if ( form_field.length == undefined ) {
         form_field.checked = true;
      }
      else {
         for (var i=0; i<form_field.length; i++) {
            form_field[i].checked = true;
         }
      }
   }

  //
  // removes selected options from select list
  //
  // args:
  //   form_field : checkbox group being unchecked
  //
   function checkbox_uncheck_all( form_field ){
      if ( form_field.length == undefined ) {
         form_field.checked = false;
      }
      else {
         for (var i=0; i<form_field.length; i++) {
            form_field[i].checked = false;
         }
      }
   }



//////////////////////////////////////////////////////
//
//  checkbox functions
//
/////////////////////////////////////////////////////

  //
  // returns the value of the radio item which is checked
  //
  //  args:
  //     group: radio grup being queried
  //
   function radio_get_value( group ) {
      var returnval = null;


      if (typeof group.length == "undefined") {
         returnval = group.value;
      }
      else {
         for (var i=0; i<group.length; i++) {
            if (group[i].checked) {
               returnval = group[i].value;
               break;
            }
         }
      }
      return returnval;
   }


  //
  // checks item with specified value in radio group
  //
  //  args:
  //     group: radio grup being set
  //     value: value to set to
  //
   function radio_set_value( group, thevalue ) {

      for (var i=0; i<group.length; i++) {
         if (group[i].value == thevalue ) {
            group[i].checked = true;
            break;
         }
      }
   }


//////////////////////////////////////////////////////
//
//  select list functions
//
/////////////////////////////////////////////////////

  //
  // add option to select list
  //
  // args:
  //   form_field : select element being set
  //   text       : text to be added
  //   value      : value to be aded
  //
   function select_add_option( form_field, text, value ) {
      var optionName = new Option(text, value);
      var length = form_field.length;

      for (var i=0; i<form_field.options.length; i++) {
        if (form_field.options[i].value == value)
           return;
      }

      form_field.options[length] = optionName;

   }

  //
  // removes single option from select list
  //
  // args:
  //   form_field : select element being set
  //   index      : index to be removed
  //
   function select_delete_option( form_field, index ) {
      form_field.options[index] = null;
   }


  //
  // removes selected options from select list
  //
  // args:
  //   form_field : select element being set
  //
   function select_remove_options( form_field ){
      for (var i=form_field.options.length-1; i>-1; i--) {
         if (form_field.options[i].selected)
            select_delete_option(form_field, i);
      }
   }

  //
  // removes selected options from select list
  //
  // args:
  //   form_field : select element being set
  //
   function select_select_all( form_field ){
      for (var i=0; i<form_field.options.length; i++) {
         form_field.options[i].selected = true;
      }
   }

  //
  // sets a selected item based on the text 
  //
  // args:
  //   form_field : select element being set
  //   value      : value to set to
  //
  //
  function select_set_on_text( form_field, value ) {

     for (var i=0; i<form_field.options.length; i++) {
        if (form_field.options[i].text == value ) {
           form_field.selectedIndex = i;
           break;
        }
     }
     
  }


  //
  // Utility function to trim leading and trailing whitespace from a string
  //
  // args:
  //   str : string to trim
  //
  //
   function trim(str) { 
      str = str.replace(/^\s*/, '').replace(/\s*$/, ''); 
      return str;
   }



  //
  // sort select list
  //
  // args:
  //   form_field : select element being sorted
  // 
  //
  //
   function selectsort_options( form_field ) {

      var copyOption = new Array();
      for (var i=0; i<form_field.options.length; i++)
         copyOption[i] = new Array(form_field[i].value,form_field[i].text);

      copyOption.sort(function(a,b) { return a[0]-b[0]; });

      for (var i=form_field.options.length-1;i>-1;i--)
         select_delete_option(form_field,i);

      for (var i=0;i<copyOption.length;i++)
         select_add_option(copyOption[i][1],copyOption[i][0])
   }
   
   
   // Checks for NUll values in the form fields
   
   
 function null_validation(textfield_name, textfield_value)
   {
   	if(textfield_value.length == 0)
   	{
   		return '- ' + textfield_name + '\n';
   	}
   
   	return '';
   }
   
// The input parameter is the reference ('this') to the form which needs to be validated.
// In order to use this function the form fileds must have the ID attribute set to the form field label. 
// Otherwise, it wont show up.   
   
   function validate_form(form_name)
   {
   	var msg = '';
   	for(i=0; i<form_name.length;i++)
   	{   	
   		if(form_name.elements[i].id.length > 0)
   		{
   			msg = msg + null_validation(form_name.elements[i].id,form_name.elements[i].value);
		}   			
   	}
   
	if(msg.length > 0)
	{
		alert('Please enter a valid value for the following form fields\n' + msg);
		return false;	
	
	}
	
	return true;
   }
   
   