var myWin
var myWinExist = false
var windowOptions = "resizable,scrollbars,width=500,height=600"
var windowOptions2 = "resizable,width=500,height=450"
var windowOptions3 = "scrollbarresizable=yes,width=500,height=450"

function open_win (str) {
    if (!myWinExist || myWin.closed) {
	myWinExist = true
	myWin = window.open("", "infowin", windowOptions)
    }else {
	myWin.document.close()    
    }
}

function open_win2 (str) {
    if (!myWinExist || myWin.closed) {
	myWinExist = true
	myWin = window.open("", "infowin2", windowOptions2)
    }else {
	myWin.document.close()    
    }
}

function open_search_complete_list(str)
{
     h = 600
     w = 900
     myleft=(screen.width)?(screen.width-w)/2:100;mytop=(screen.height)?(screen.height-h)/2:100;
     settings="width= 900,height=600,top=" + mytop + ",left=" + myleft + ",scrollbars=yes,location=no,directories=no,status=yes,menubar=no,toolbar=no,resizable=yes";
     
     if (!myWinExist || myWin.closed) 
     {
     	myWinExist = true
     	myWin = window.open("", "infowin2", settings)
     }else 
      {
     	myWin.document.close()    
     }
     
 }



function writeInfo (txt) {
    document.infoform.info.value=(txt);
}

function jump (element) {
    var listItem = element.options[element.selectedIndex].text;
    var pattern = /\#/;
    var url = document.location.href.split(pattern);
    document.location.href = url[0] + "#" + listItem;
}

function switchAddress(list ){	
    location.href = list.options[list.selectedIndex].value;
}



function goToBlast(analysislist,seqlist){	

    var url     = analysislist.options[analysislist.selectedIndex].value;
    var seqtype = radio_get_value( seqlist );
    var analysistype = analysislist.options[analysislist.selectedIndex].text;

  //
  // if it is blast at NCBI, then go to our launch page in new window
  //
    if ( /NCBI/.test(analysistype)) {
       NewWindow(url,'Popup', '800', '650', 'center','front');
       return;   
    }

  //
  // for BLASTX and BLASTP 
  // set the database to protein (both require protein databases)
  //
    if ( analysistype == 'BLASTX' ||
         analysistype == 'BLASTP')  {
       seqtype = seqtype + '&database=dictyProtein';
    }
  //
  // if a protein sequence is selected, but the program chosen does accept a 
  // protein query, then set the seqtype to a non-protein sequence
  // (assuming that t item in list will be a non protein sequnece)
  //
    if (seqtype == 'Protein' && 
        (analysistype != 'BLASTP' && analysistype != 'TBLASTN')
       ) {
       seqtype = seqlist[0].value;
    }
    url = url + "&sequence_type=" + seqtype;
    location.href = url;
}

//
// if a user selects certain types of BLAST
// want to automatically select sequence types consistent with 
// type of blast.
//
function setSeqType(analysislist,seqlist){	


    var seqtype      = radio_get_value( seqlist );
    var analysistype = analysislist.options[analysislist.selectedIndex].text;
 
  //
  // for BLASTP and TBLASTN and BLASTP at NCBI
  // set the sequnce type to protein (both require protein queries)
  //
    if ( /(NCBI)|(BLASTP)|(TBLASTN)/.test(analysistype) ) {
         radio_set_value( seqlist, 'Protein');
    }
  //
  // for others (which require nuc. query
  // set the sequence to DNA coding sequence
  //
    if ( radio_get_value( seqlist ) == 'Protein' &&
         !/(NCBI)|(BLASTP)|(TBLASTN)/.test(analysistype) ) {
         radio_set_value( seqlist, 'DNA coding sequence');
    }
}



function setBlastType(analysislist,seqlist){	
    var seqtype      = radio_get_value( seqlist );
    var analysistype = analysislist.options[analysislist.selectedIndex].text;

  //
  // for BLASTP and TBLASTN and BLASTP at NCBI
  // set the sequnce type to protein (both require protein queries)
  //
    if ( seqtype == 'Protein'  && !/(NCBI)|(BLASTP)|(TBLASTN)/.test(analysistype) ){

       select_set_on_text(analysislist,'BLASTP')
    }
    if ( seqtype != 'Protein'  && /(NCBI)|(BLASTP)|(TBLASTN)/.test(analysistype) ){

       select_set_on_text(analysislist,'BLASTN')
    }


}



  /****************************************************
  AUTHOR: WWW.CGISCRIPT.NET, LLC
  URL: http://www.cgiscript.net
  Use the code for FREE but leave this message intact.
  Download your FREE CGI/Perl Scripts today!
  ( http://www.cgiscript.net/scripts.htm )
  ****************************************************/
  var win=null;
  function NewWindow(mypage,myname,w,h,pos,infocus){
     var regexp = new RegExp(" ");
     if ( ie4 && regexp.exec(myname) ) { alert("No spaces allowed in window name in IE ("+myname+")"); }
     if(pos=="random"){myleft=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;mytop=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
	  if(pos=="center"){myleft=(screen.width)?(screen.width-w)/2:100;mytop=(screen.height)?(screen.height-h)/2:100;}
	  else if((pos!='center' && pos!="random") || pos==null){myleft=524;mytop=50}
	  var settings="width=" + w + ",height=" + h + ",top=" + mytop + ",left=" + myleft + ",scrollbars=yes,location=yes,directories=yes,status=yes,menubar=yes,toolbar=yes,resizable=yes";
       win=window.open(mypage,myname,settings);
	  win.opener.name = "opener";
	  win.focus();}


  function NewWindowNoToolbars(mypage,myname,w,h,pos,infocus){
     var regexp = new RegExp(" ");
     if ( ie4 && regexp.exec(myname) ) { alert("No spaces allowed in window name in IE ("+myname+")"); }
     if(pos=="random"){myleft=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;mytop=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
	  if(pos=="center"){myleft=(screen.width)?(screen.width-w)/2:100;mytop=(screen.height)?(screen.height-h)/2:100;}
	  else if((pos!='center' && pos!="random") || pos==null){myleft=524;mytop=50}
	  settings="width=" + w + ",height=" + h + ",top=" + mytop + ",left=" + myleft + ",scrollbars=yes,location=no,directories=yes,status=yes,menubar=no,toolbar=no,resizable=yes";win=window.open(mypage,myname,settings);
	  win.opener.name = "opener";
	  win.focus();}


var ie4=document.all&&navigator.userAgent.indexOf("Opera")==-1
var ns6=document.getElementById&&!document.all
var ns4=document.layers
var opr=navigator.userAgent.indexOf("Opera")
var macie = navigator.appVersion.indexOf('Mac') != -1&&document.all




function shift_linkMenu() {

   var which = 'links';
   menuobj=ie4? eval('document.all.'+which+'DIV') : ns6? document.getElementById(which+'DIV') : ns4? eval('document.'+which+'DIV') : ""
   menuobj.thestyle=(ie4||ns6)? menuobj.style : menuobj

   offset = ie4 ? 40 : 900;

   var width = getScreenWidth();
   if (width) {
      menuobj.thestyle.position = 'absolute';
      menuobj.thestyle.left = (getScreenWidth()-200);

   }
   else {
      menuobj.thestyle.left = (findPosX(menuobj) - offset)
   }
}

function shiftmenu_forMac(e,which){

   menuobj=ie4? eval('document.all.'+which+'DIV') : ns6? document.getElementById(which+'DIV') : ns4? eval('document.'+which+'DIV') : ""
   menuobj.thestyle=(ie4||ns6)? menuobj.style : menuobj

   if (macie) {
      if (!document.all&&!document.getElementById&&!document.layers)
      return

      themenuoffsetX= document.body.scrollLeft -20
      themenuoffsetY= document.body.scrollTop + 14

      menuobj.thestyle.left= themenuoffsetX+event.clientX-event.offsetX
      menuobj.thestyle.top=  themenuoffsetY+event.clientY-event.offsetY
   }
}

function getScreenWidth() {
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    myWidth = window.innerWidth - 17;
    myHeight = window.innerHeight;
  } else {
    if( document.documentElement &&
        ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
      //IE 6+ in 'standards compliant mode'
      myWidth = document.documentElement.clientWidth;
      myHeight = document.documentElement.clientHeight;
    } else {
      if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
        //IE 4 compatible
        myWidth = document.body.clientWidth;
        myHeight = document.body.clientHeight;
      }
    }
  }
  return myWidth
}






function findPosX(obj)
{
	var curleft = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curleft += obj.offsetLeft
			obj = obj.offsetParent;
		}
	}
	else if (obj.x)
		curleft += obj.x;
	return curleft;
}

function findPosY(obj)
{
	var curtop = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curtop += obj.offsetTop
			obj = obj.offsetParent;
		}
	}
	else if (obj.y)
		curtop += obj.y;
	return curtop;
}



function NewWindowExpression(mypage,myname,w,h,pos,infocus){
     if(pos=="random"){myleft=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;mytop=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
	  if(pos=="center"){myleft=(screen.width)?(screen.width-w)/2:100;mytop=(screen.height)?(screen.height-h)/2:100;}
	  else if((pos!='center' && pos!="random") || pos==null){myleft=524;mytop=50}
	  settings="width=" + w + ",height=" + h + ",top=" + mytop + ",left=" + myleft + ",scrollbars=yes,location=no,directories=no,status=yes,menubar=no,toolbar=no,resizable=yes";win=window.open(mypage,'',settings);
	  //win.opener.name = "opener";
	  //win.focus();
	  
	  }

function submit_conformation(msg)
{

var name = confirm(msg)
if (name == true)
{
	return true ;
}else
{

	return false;
}

}


function refresh_gene_page(link)
{
	opener.location = link;
}

