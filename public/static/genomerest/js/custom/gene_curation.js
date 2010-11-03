$(document).ready(function() {

	var genebox = $("input[@name=replace][@type=checkbox]");
	$("#replace_col").append("<b id='message'>Gene ID replacement automatically deletes gene</b>"); 
	$("#message").css({ backgroundColor: "yellow" });
	$("#message").hide();

	genebox.click(function() {
		if (!genebox.attr('checked')) {
			$("#message").fadeOut('slow');
			$("p[id*=newblock]").remove();
			$("input[@name=is_deleted][@type=checkbox]").removeAttr('disabled');
			return;
		}

		$("#message").fadeIn('slow');
		$("#replace_col").append("<p id='newblock'><input type='text' name='replace_gene_id'/></p>");
		$("#newblock").append("&nbsp&nbsp<input type='button' id='moreid' value='+'/>");
		$("#moreid").css({ border: "1px solid black", padding: "2px"});
		$("#newblock").css({ color: "blue" }).append("&nbsp&nbsp<b>More</b>");
		$("input[@name=is_deleted][@type=checkbox]").attr('disabled','true');

		$("#moreid").click(function() {
				$("#replace_col").append("<p id='newblock'><input type='text' name='replace_gene_id'/></p>");
				$("p[id=newblock]:last").append("&nbsp&nbsp<input type='button' id='lessid' value='-'/>");
				var button = $("input[id=lessid][@type=button]:last");
				button.css({ border: "1px solid black", padding: "2px"});
				button.click(function() {
					button.parent("#newblock").remove();
				});
		});

	});


		/*$("a[id^=hide]").click(function() {
		  var id = $(this).attr("id");
			var val = id.split(":");
			$("td[id=" + val[1] + "]").each(function () {
				 if (!$(this).css('display')) {
				 		$(this).hide();
				 }

			)};
		}) ; */

  /*$("#gframe").load(loadframe);*/

  	var iframe = $("#gframe");

  	//Resize function

  	function iresize() {
  		//alert ("in safari" );
  		var innerframe = document.getElementById('gframe');
  		var height = innerframe.contentWindow.document.body.offsetHeight;
  		//alert(height);
  		innerframe.style.height = height + 5 + "px";
  	}

  	// For safari or opera
  	if ($.browser.safari || $.browser.opera) {

  		// start timer to allow loading
  		iframe.load(function () {
  			setTimeout(iresize,0);
  	});

  		var source = iframe.src;
  		iframe.src = '';
  		iframe.src = source;
  	}

  	else {
  		iframe.load(function () {
  		  //alert ("in firefox");
  		  //alert (this.contentWindow.document.body.offsetHeight + 5); 
  			this.height = this.contentWindow.document.body.offsetHeight + 5 ;
			});
		}

});

/*function loadframe () {
	var gframe = $("#gframe");
	if (gframe) {
		innerframe = (gframe.get(0).contentDocument) ? gframe.get(0).contentDocument : gframe.get(0).contentWindow.document;
		gframe.height(innerframe.body.scrollHeight + 2);
	}
}*/


