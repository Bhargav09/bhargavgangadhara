F<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Sunil Mathew (sunmathe@cisco.com)
: @modified by Holly Chen (holchen@cisco.com) add Release News text area for Sprit 6.8 CSCsi47314
:
: Copyright (c) 2005-2012 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import = "java.net.URLEncoder,
                   com.cisco.eit.sprit.ui.SpritGUI,
                   com.cisco.eit.sprit.ui.SpritGUIBanner,
                   com.cisco.eit.sprit.ui.SpritReleaseTabs,
                   com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper,
                   com.cisco.eit.sprit.controller.NonIosCcoRequestContext" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprImageDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprReleaseNotesInfo"%>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleasenumber.CsprReleaseNumberLocal" %>
<%@ page import="javax.ejb.FinderException" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishUtil" %>


<%
  Integer               osTypeId            = null;
  String                osType              = null;
  String                releaseName         = null;
  String                imageName           = null;
  NonIosCcoPostHelper   nonIosCcoPostHelper = null;
  SpritAccessManager    spritAccessManager;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  boolean               isSoftwareTypePM    = false;
  String missingMd5ChecksumError = null;
  boolean searchByExactRel = false;
  boolean 				isIOSXE 				= false;
  String            	psirtMsg				= "";
  Integer 				iosRelNumberId 		= null;
  Integer 				relId 					= null;

 
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );
  String pathGfx = globals.gs( "pathGfx" );
  nonIosCcoPostHelper = new NonIosCcoPostHelper();

  String action = nonIosCcoPostHelper.getAction(request);
  String strMode = nonIosCcoPostHelper.getMode(request);

  // Get os type ID.  Try to convert it to an Integer from the web value!
  try {
    osTypeId = nonIosCcoPostHelper.getOSTypeId(request);
  } catch ( Exception e ) {
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
    return;   //harish
  }

  osType = nonIosCcoPostHelper.getOSType(osTypeId);

  if(osType == null || osType.equals("")) {
    // No os type!  Bad!  Redirect to error page.
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
    return; //Harish
  }
  if(osType.equals(CcoPostUtility.IOSXE))
  {
 	 isIOSXE=true;
  }
  releaseName = nonIosCcoPostHelper.getReleaseName(request);
  
  
  // just to search by exact release
  String searchByExactRelease = 
    WebUtils.getParameter(request, NonIosCcoPostHelper.SEARCH_BY_EXACT_RELEASE);
 
  if (searchByExactRelease != null && "yes".equalsIgnoreCase(searchByExactRelease)) {
    searchByExactRel = true;
  }

  //harish  added MODE_VIEW condition
   
   boolean isReliseView=false;
   
  if (strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST)||strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_VIEW)  //harish
  		|| strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST)) {
  	if (releaseName == null || "".equals(releaseName)) {
  		// no release selected redirect user to release selection page
  		response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);
  		return;
  	}
  	 	
  	
  	try {
  			EJBHomeFactory.getFactory().getCsprReleaseNumberLocalHome().findByCsprReleaseName(releaseName, osTypeId);
  			
  	} catch(Exception fe) {
  		// redirect the user to release selection page
  			//response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);  			
  			isReliseView=true;   //Harish
  		//return;
  	} 
  	//catch(Exception e) {
  		// redirect the user to release selection page
  	//	response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);
  	//	return;  //Harish  		
  	//} 
  	
  	if(isReliseView) {
  		response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);
  		return;
  	}  	
  	
  	
  	// make searchByExactRel to true in case of POST & REPOST
  	searchByExactRel = true;
  }

  //gettins IOS release for IOSXE release and check for any psirt volunerability
  if (strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST) 
	  		|| strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_VIEW)) {
  
	  	if(isIOSXE)
	  	 {	  		
	  		try {
	  	  	CsprReleaseNumberLocal csprReleaseNumberLocal = 
	  	  				EJBHomeFactory.getFactory().getCsprReleaseNumberLocalHome().findByCsprReleaseName(releaseName, osTypeId);
	  	  		relId=csprReleaseNumberLocal.getReleaseNumberId();
	  	  	} catch(Exception fe) {
	  	  		// redirect the user to release selection page
	  	  		try {
	  	  			//response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);
	  	  			isReliseView=true;
	  	  			//return;  //Harish
	  	  		}catch (IllegalStateException ie){}

	  	  		//return;
	  	  	} //catch(Exception e) {
	  	  		// redirect the user to release selection page
	  	  		//response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);
	  	  		//return;  //Harish
	  	  	//} 
	  	  	
	  	  if(isReliseView){
	  		response.sendRedirect("NonIOSSelectRelease.jsp?osTypeId=" + osTypeId + "&selectedTab=CCOPost&" + NonIosCcoPostHelper.MODE + "=" + strMode);
	  		return;
	  	  }
	  	  
	  	  if(relId!=null)
	  	  	iosRelNumberId = CcoPostUtility.getIOSReleaseNumberId(relId);
	  	  if(iosRelNumberId!=null)
	  	  {
	  		 MonitorUtil.cesMonitorCall("SPRIT-7.3-CSCso34437-Check CCO Post show stopper for IOSXE/MCP releases", request);
	  		 psirtMsg = CcoPostUtility.getPsirtMsg(iosRelNumberId);
		  }
      }
  } 
  
    
  imageName = nonIosCcoPostHelper.getImageName(request);

  String errorMessage = (String)session.getAttribute("errorMessage");

  NonIosCcoRequestContext nonIosCcoRequestContext = (NonIosCcoRequestContext)session.getAttribute("nonIosCcoRequestContext");

  if (nonIosCcoRequestContext == null) {
    nonIosCcoRequestContext = new NonIosCcoRequestContext(request);
  }
  
  // Release notes validation to make sure the file they entered does exist on file system and readable
  String[] relSRC = nonIosCcoRequestContext.getReleaseSRC();
  if (relSRC != null) {
	  for (int i = 0; i < relSRC.length; i++) {
	  	if (relSRC[i] != null && !relSRC[i].equals("") && !relSRC[i].equalsIgnoreCase("NULL")) {
	  		if (!SpritUtility.fileExists(relSRC[i])) {
	  			errorMessage = (errorMessage != null) ?errorMessage :"" + "Release Notes source file: " + relSRC[i].trim() + " not exist/readable\n";
	  		}
	  	}
	  }
  }

  isSoftwareTypePM = spritAccessManager.isSoftwareTypePM(osTypeId);
  boolean isSecondaryPublisher = spritAccessManager.isSecondaryPublisher(osTypeId);
  
  if ( (!NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode) &&
       !isSoftwareTypePM &&
       !spritAccessManager.isAdminSprit() &&
       !spritAccessManager.isGlobalExportTrade() &&
       !spritAccessManager.isAdminCco()) && !isSecondaryPublisher ) {
	  
	  
	  
	  // just redirecting back to the view page -- asuman
    response.sendRedirect( NonIosCcoPostHelper.REDIRECT_URL + 
                           NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_VIEW + "&" +
                           NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                           (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + response.encodeRedirectURL( releaseName ) : "") +
                           (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + response.encodeRedirectURL( imageName ) : "")
                         );
  }
  
  // redirect if the user is secondary publisher and mode is neither View nor Post -- asuman
  if(isSecondaryPublisher && !NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode) &&
        !NonIosCcoPostHelper.MODE_POST.equalsIgnoreCase(strMode)) {
        response.sendRedirect( NonIosCcoPostHelper.REDIRECT_URL + 
                           NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_VIEW + "&" +
                           NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                           (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + response.encodeRedirectURL( releaseName ) : "") +
                           (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + response.encodeRedirectURL( imageName ) : "")
                         );
  } 
  
  
  String parentSwTypeName = NonIosCcoPostHelper.getParentSwTypeName(osTypeId); // getting parent swt
  //String defaultNews = NonIosCcoPostHelper.getDefaultNews(osTypeId);
  String defaultNews = "'New <b>" + NonIosCcoPostHelper.getSwTypeMDFName(osTypeId) + "</b> has been posted to the <a href=\"http://www.cisco.com/kobayashi/sw-center/\">Software Center</a>.'";	

    Integer releaseNumberId = nonIosCcoPostHelper.getNonIosReleaseNumberIdByName(releaseName, osTypeId); // getting release number id 
    
%>

<%@page import="com.cisco.eit.sprit.util.CcoPostUtility"%>
<%@page import="com.cisco.eit.sprit.util.MonitorUtil"%>
<script language="javascript">
<!--


// ==========================
// CUSTOM JAVASCRIPT ROUTINES
// ==========================
function doBlink() {
    var blink = document.all.tags("blink");
    for (var i=0; i < blink.length; i++) {
        blink[i].style.visibility = blink[i].style.visibility == "" ? "hidden" : "" 
    }
}

function startBlink() {
    // Make sure it is IE4
    if (document.all) {
        setInterval("doBlink()",500)
    }
}
window.onload = startBlink;

//........................................................................
// DESCRIPTION:
// Changes the up/over images if the form hasn't been submitted.
//........................................................................
function actionBtnSubmit(elemName, imagename) {
    if ( document.forms['ccoPost'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
}

function actionBtnSubmitOver(elemName, imagename) {
    if ( document.forms['ccoPost'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
}

function checkboxSelectAllHere() {		
		
	//for (var i=0; i<document.ccoPost.length; i++) {
			//document.ccoPost.elements[i].checked='true';
	//}
	var x=document.getElementsByName("imageid");
	if(x!=null) {
		for (var count=0; count<x.length; count++) {
			x[count].checked=true;
		}
	}
}

function checkboxSelectNoneHere() {
	var x=document.getElementsByName("imageid");
	if(x!=null) {
		for (var count=0; count<x.length; count++) {
			x[count].checked=false;
		}
	}
}//Method	

function checkReleaseIsUnique(){
	var flag = true;
	var x=document.getElementsByName("imageid");
	var releaseArray = new Array();
	var i =0;
	if(x!=null) {
		for (var count=0; count<x.length; count++) {
			
			if(x[count].checked == true){
				startPos = x[count].value.indexOf(":") +1;
				releaseArray[i++]=x[count].value.substring(startPos);
				//alert(x[count].value.substring(startPos));
			}
		}
		
	}
     
		for (var i=0; i<releaseArray.length - 1; i++)
		{
			for (var j=i+1; j<releaseArray.length; j++)
			{
				if (releaseArray[i] != releaseArray[j]){
					flag  = false;
					return flag;
				}
			}
		}	
	
	return flag;
}

function submitCco() {
    var check = false;

    for (var i=0; i<document.ccoPost.length; i++) {

        if (document.ccoPost.elements[i].name == 'imageid') {
            
            if (document.ccoPost.elements[i].checked) {
                check = true;

                <%
                if ( strMode != null && ( NonIosCcoPostHelper.MODE_POST.equalsIgnoreCase(strMode) ||
                                          NonIosCcoPostHelper.MODE_REPOST.equalsIgnoreCase(strMode) ) ) {
                    %>
                    // TODO                        

                    <%
                }
                %>

            }
        }
    }

    if (check == false) {
        alert("Atleast one image should be selected");
        return false;
    }
    
    //check for email alias and software pm
    document.ccoPost.softwarepm_hidden.value = 'false';
    var x=document.getElementsByName("softwarepm");
		if(x!=null) {
			for (var count=0; count<x.length; count++) {
				if(x[count].checked) {
					
					document.ccoPost.softwarepm_hidden.value = 'true';
				}
			}
		}
    document.ccoPost.emailalias_hidden.value = 'false';
    var x=document.getElementsByName("emailalias");
		if(x!=null) {
			for (var count=0; count<x.length; count++) {
				if(x[count].checked) {
					
					document.ccoPost.emailalias_hidden.value = 'true';
				}
			}
		}
    
 <%if(strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST)  || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST)){
	 %>
	 //CSCsr29014 - Validate URL - images cannot be CCO Posted/Reposted with invalid product/release notes URL
	 var invalidUrlMessage = isReleaseURLValid();
     if( invalidUrlMessage != ''){
     	Ext.MessageBox.alert('Error',' Please enter valid URLs before submission.<br/><br/>' + invalidUrlMessage);
 		return false;
     }<%	 
    if(!isSecondaryPublisher ){%>
                var result = getResultString();
                if( result != '' && result.substring(0, 'Error'.length ) == 'Error') {
                    Ext.MessageBox.alert('Error', result.substring('Error!'.length ) );
                    return false;
                } else { 
                    document.ccoPost._releaseNotesData.value = result;                                       
                    document.ccoPost._releaseMessage.value = document.getElementById('releaseMessage').value;
                }
    <%}%>	
 <%}%>
 
 <%if(strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST)) {%>
           var formObj = document.forms['ccoPost'];
           var prefixRegex = new RegExp( "^acl_" );
    
           var elems = document.forms['ccoPost'].elements;
           var numElems = elems.length;
           var acllist = '';
           for( e=0; e<numElems; e++ ) {
              var elemName = elems[e].name;
    
              if( prefixRegex.test(elemName) ) {
                 if( elems[e].value == null || trim(elems[e].value) == '') {
                     alert( "ACL list can't be empty." );
                     return false;
                 }
                 acllist += ', ' + elems[e].value;
              }
           }  // for( e=0; e<numElems; e++ )
           if( acllist != '' ) {
           		 //alert ( 'user list ' + acllist );
           		
                validateCcoUser(acllist);
                if(anyAclErrors)
                    return false;
           }
 <%}%>
    document.ccoPost.action.value = "submit";
    document.ccoPost.submit();
    return true;
}

    var anyAclErrors = false;    
    
    function validateCcoUser(aclList) {
        if (aclList != null && aclList.length >0 ) {
            var validationurl = 'CcoUserValidator?acllist='+ aclList;
            anyAclErrors = false;
                Ext.Ajax.request({
                    url: validationurl,
                    method: 'GET',
                    success: function(response, options) {
                        var strResponse = trim(response.responseText);
                        if( strResponse != '' ) {
				             if( strResponse == 'Internal Error' ) {
				                alert( "Internal Error!. Unable to validate CCO user ids." );
				             } else {
				                alert( "Some of the ACL user id's (" + strResponse + ") are Invalid." );
				             }
				             anyAclErrors = true;
				         } else 
			                 anyAclErrors = false;
		            },
                    failure: function(response, options) {
                        var strResponse = trim(response.responseText);
                        anyAclErrors = true;
                        alert( "Unable to validate CCO user ids." + strResponse);
                    },
                    scope: this,
                    async: false
                });
         }
     }
     
function confirmCco() {

    if (document.ccoPost._submitformflag.value == 0) {
        document.ccoPost._submitformflag.value = 1;
    } else {
        return false;
    }

    document.ccoPost.action.value = "confirm";
    document.ccoPost.submit();
    return true;
}

function changeSoftwareType() {

    if (document.ccoPost.releaseName != null) {
    	document.ccoPost.releaseName.value = '';
    }
    document.ccoPost.imageName.value = '';
    document.ccoPost.submit();
    return true;
}

function trim(str) {
    return str.replace(/^\s*|\s*$/g,"");
}

	var objReleaseNews = {
		
		unCheckDefault: function() {
			document.getElementById('isDefault').checked = false;
		},
		
		
		checkText: function(text,allowedTags) {
					var returnMsg = '';
					var invalidTag = false;
					// Pattern to strip HTML Tags from text
					var pattern = /<\/?\s*\w+\s*(\s*\w+\s*=?\s*[\"|\']?(\s*[^ >]*\s*)*[\"|\']?)*\s*\/?>/g;
					var arrHtmlTags = text.match(pattern);
					if(arrHtmlTags != null) {
						for(i=0;i<arrHtmlTags.length;i++){
							var wordPattern = /\w+/g;
							var arrTag = arrHtmlTags[i].match(wordPattern);
							// Loop through allowed HTML tags to check if
							// this HTML tag is valid
							if (allowedTags != null && allowedTags.length > 0) {
								for(j=0;j<allowedTags.length;j++){
									if(arrTag[0].toLowerCase() != allowedTags[j]){
										invalidTag = true;
									}else{
										invalidTag = false;
										break;
									}
								}
							}
							//break out of for loop if an invalid tag is found
							if (invalidTag)
								break;
						} //for
					}
					
					if(invalidTag)
						returnMsg = 'Unsupported HTML Tag found\n';
					return returnMsg;	
		},
		
		clearCheckBox:function(){
			document.getElementById('isDefault').checked = false;
		}
}

//-----------------release Notes-----------------------------------------------------------------------------------------------
   			  release_max_row = 4;
              release_count =0;
  
  			//add a new row to the table release notes
  			function addReleaseUrlRow()
  			{
  				
  				var tblReleaseNoteTable = document.getElementById('tblReleaseNoteTable');
  				var releaseAddBtn = document.getElementById("addBtn");
  				
  				if(tblReleaseNoteTable.rows.length<release_max_row){
  					//add a row <tr> to the rows collection and get a reference to the newly added row
  					var newRow = document.getElementById('tblReleaseNoteTable').insertRow(tblReleaseNoteTable.rows.length);
  					  							
  				
  					//add 3 cells (<td>) to the new row and set the innerHTML to contain text boxes
  					var oCell = newRow.insertCell(0);
  					oCell.innerHTML = "<input type='text' size='20' style='width: 100%;' maxlength='60'  name='releaseLabel' id ='releaseLabel' value ='' />";
  				
  								
  					var oCell = newRow.insertCell(1);
  					var inputReleaseURL = "<input type='text' size='45' style='width: 100%;' maxlength='1000' name='releaseURL' id='releaseURL' value ='' />"
  					oCell.innerHTML =  inputReleaseURL;
  					
  					var oCell = newRow.insertCell(2);
  					var inputReleaseSRC = "<input type='text' size='45' style='width: 100%;' maxlength='1000' name='releaseSRC' id='releaseSRC' value ='' />";
  					oCell.innerHTML = inputReleaseSRC;
  					
  					var oCell = newRow.insertCell(3);
  					oCell.innerHTML= "<input type='button' id ='deleteBtn' value='Delete' onclick='removeReleaseRow(this);'/>";	
  					
  					release_count++;
  					if(tblReleaseNoteTable.rows.length==release_max_row) releaseAddBtn.disabled= true;
  				}
  				
  				
  			}
  			
  			//deletes the specified row from the table
  			function removeReleaseRow(src)
  			{
  				/* src refers to the input button that was clicked.	
  				   to get a reference to the containing <tr> element,
  				   get the parent of the parent (in this case case <tr>)
  				*/			
  				var oRow = src.parentNode.parentNode;		
  				var releaseAddBtn = document.getElementById("addBtn");
  				
  				//once the row reference is obtained, delete it passing in its rowIndex			
  				document.getElementById("tblReleaseNoteTable").deleteRow(oRow.rowIndex);	
  				releaseAddBtn.disabled=false;
  				release_count--;
			}
//-----------------End Release notes --------------------------------------------------------------------------------------------  

//----------------JS Validation object-----------------------------------------------------
var objReleaseNotes = {
				
		isLabelUnique: function(text){
				var releaseLabels = document.getElementById('releaseLabel');
				if(releaseLabels != null) {
					if(isNaN(releaseLabels.length)){
						var tmp = releaseLabels;
						releaseLabels = new Array();
						releaseLabels[0] = tmp;
					}
					
					for(i=0;i<releaseLabels.length;i++){
						if(text == releaseLabels[i].value)
							return false;
					}
				}
				return true;
		},
		validateReleaseNotes: function(){
					var errorMessage = '';
					var unsupportedHTML = '';
					
					// Release Message: should be less than 350 character and allow <br>, <b>, <i> and <a href = URL link>
					//if(document.csprImageEdit.releaseMessage!= null){
						var releaseMessage = document.getElementById('releaseMessage').value;
						if(releaseMessage.length > 350)
							 errorMessage = errorMessage + 'Release Message exceeds 350 characters\n';
						if (releaseMessage.length>1 && unsupportedHTML == '') {
							unsupportedHTML = this.checkText(releaseMessage,new Array('b','i','br','a')); 	 
							if(unsupportedHTML != '')
								errorMessage = errorMessage + unsupportedHTML;
						}	 
					
					//}
					
					
					//Release Note Label not empty
					if(this.arrayFieldIsRequired(document.getElementsByName('releaseLabel'))){
						errorMessage = errorMessage + 'Release Label is Required\n';
					}
								
					// Release URL or Source Location need to be entered
					if (this.arrayFieldsRequired(document.getElementsByName('releaseURL'), document.getElementsByName('releaseSRC'))) {
						errorMessage = errorMessage + 'Release URL / Source Location is Required, provide either Release Notes URL or Source Location not both\n';
					}
					
					
					
					// Release URL need to be unique
					var releaseURLArray = document.getElementsByName('releaseURL')
					if(!this.arrayFieldIsUnique(releaseURLArray)) {
						errorMessage = errorMessage + 'Release URL must be unique \n';
					}
					// Check and make sure Image Source Location doesn't have any special chars
					var imageSRCValidRegex = new RegExp( "^[a-zA-Z0-9\-_\./\\\\]+$" );
    				if( this.arrayFieldPatternCheck(document.getElementsByName('releaseSRC'), imageSRCValidRegex) ) {
    					errorMessage = errorMessage + 'Release Doc Source Location can not have special characters, only A-Z,a-z,0-9, -, _, /, \\ and . are allowed\n';
					}
					
					// Check and make sure user keyed in allowed file formats
					// for now restricting .htm files as WCM team doesn't render .htm files
					var fileTypes = new Array();
					fileTypes[0] = new RegExp( ".htm$" );
					if ( this.arrayFieldFileTypeCheck(document.getElementsByName('releaseSRC'), fileTypes) ) {
						errorMessage = errorMessage + 'Release Doc Source Location can not have .htm file type, please rename file to .html\n';
					}
					
					return errorMessage;
				},
				
				checkText: function(text,allowedTags) {
					var returnMsg = '';
					var invalidTag = false;
					// Pattern to strip HTML Tags from text
					var pattern = /<\/?\s*\w+\s*(\s*\w+\s*=?\s*[\"|\']?(\s*[^ >]*\s*)*[\"|\']?)*\s*\/?>/g;
					var arrHtmlTags = text.match(pattern);
					if(arrHtmlTags != null) {
						for(i=0;i<arrHtmlTags.length;i++){
							var wordPattern = /\w+/g;
							var arrTag = arrHtmlTags[i].match(wordPattern);
							// Loop through allowed HTML tags to check if
							// this HTML tag is valid
							if (allowedTags != null && allowedTags.length > 0) {
								for(j=0;j<allowedTags.length;j++){
									if(arrTag[0].toLowerCase() != allowedTags[j]){
										invalidTag = true;
									}else{
										invalidTag = false;
										break;
									}
								}
							}
							//break out of for loop if an invalid tag is found
							if (invalidTag)
								break;
						} //for
					}
					
					if(invalidTag)
						returnMsg = 'Unsupported HTML Tag found\n';
					return returnMsg;	
				},
				
				arrayFieldIsRequired: function(objArr) {
					var flag = false;
					if (objArr != null) {
						if (isNaN(objArr.length)) {
							var tmp = objArr;
							objArr = new Array();
							objArr[0] =  tmp;
						}
						for(i=0;i<objArr.length;i++) {
							if (trim(objArr[i].value).length == 0) {
								flag = true;
								break;
							}
						}
					}
					return flag;			
				},
				
				arrayFieldsRequired: function(object1, object2) {
					var flag = false;
					if ((object1 == null) && (object2 == null)) {
						return flag;
					}
					
					var object1length = 0;
					if (object1 != null) {
						if (isNaN(object1.length)) {
							var tmp = object1;
							object1 = new Array();
							object1[0] = tmp;
						}
						object1length = object1.length;
					}
					
					var object12ength = 0;
					if (object2 != null) {
						if (isNaN(object2.length)) {
							var tmp = object2;
							object2 = new Array();
							object2[0] = tmp;
						}
						object2length = object2.length;
					}
					var maxLength = Math.max(object1length, object2length);
					for(i=0; i < maxLength; i++) {
						if (object1[i] != null) {
							if (object1[i].value.length == 0) {
								flag = true;
							}
						}
						
						if (object2[i] != null) {
							if (flag) {
								if (object2[i].value.length == 0) {
									break;
								} else {
									flag = false;
								}
							} else {
								if (object2[i].value.length != 0) {
									flag = true;
									break;
								}
							}
						}
					}
					return flag;
				},
				
				
				arrayFieldPatternCheck: function(objArr, regExPattern) {
					var flag = false;
					
					if (objArr == null) {
						return flag;
					}
					
					if (isNaN(objArr.length)) {
						var tmp = objArr;
						objArr = new Array();
						objArr[0] = tmp;
					}
					
					for (i = 0; i < objArr.length; i++) {
						if (objArr[i].value.length != 0) {
							if (!regExPattern.test(objArr[i].value)) {
								flag = true;
								return flag;
							}
						}
					}
					
					return flag;
				},
				
				
				arrayFieldFileTypeCheck: function(objArr, fileTypes) {
					var flag = false;
					
					if ((objArr == null) || (fileTypes == null)) {
						return flag;
					}
					
					if (isNaN(objArr.length)) {
						var tmp = objArr;
						objArr = new Array();
						objArr[0] = tmp;
					}
					
					if (isNaN(fileTypes.length)) {
						var tmp = fileTypes;
						fileTypes = new Array();
						fileTypes[0] = tmp;
					}
					
					for (i = 0; i < objArr.length; i++) {
						if (objArr[i].value.length != 0) {
							for (j = 0; j < fileTypes.length; j++) {
								if (fileTypes[j].test(objArr[i].value)) {
								flag = true;
								return flag;
								}
							}
						}
					}
					
					return flag;
				},
				
				
				arrayFieldIsUnique: function(objArr) {
					var flag = true;
					if (objArr != null) {
						// Only one release label is present
						if (objArr.length == 1) {
							return flag;
											}
						// More than one release labels are present
						for(i=0;i<objArr.length;i++) {
							var label = objArr[i].value;
							for(j=i+1;j<objArr.length;j++){
								//label is not unique
								if(label == objArr[j].value){
								return false;
								}
							}
						}
					}
						return flag;
								
				}
	}  

//-----------------------------------End JS validation object------------------------------------------------

 
-->
</script>

<form name="ccoPost" method="post" action="NonIosCcoProcessor">

<%
  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  if(strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST)  || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST)) {
  	if(SpritUtility.isOsTypeIosIoxCatos(osType)){
	  banner.addContextNavElement( "REL:",
	      SpritGUI.renderReleaseNumberNav(globals,releaseName,osType)
	   );
  	}else{
	    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                SpritGUI.renderOSTypeNav(globals,osType,releaseName,"CCOPost",WebUtils.getParameter(request,"osTypeId"),strMode)
	    );
  	}
  } else {
  	banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                               SpritGUI.renderOSTypeNav(globals,osType));
  }
%>

<%= SpritGUI.pageHeader( globals, NonIosCcoPostHelper.CCO_PAGE_HEADER,"" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getOSTypeTabs(globals, NonIosCcoPostHelper.CCO_TAB) %>

<%
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>

<table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr bgcolor="#BBD1ED">
    <td valign="middle" width="70%" align="left">
      <%

  String   filterTransactionType              = "";
  String   filterPostingType                  = "";
 filterTransactionType = nonIosCcoPostHelper.getTransactionType(request);
 filterPostingType     = nonIosCcoPostHelper.getPostingType(request);
 
 String ttype        = SpritUtility.replaceString(filterTransactionType,"*","");
 String ptype        = SpritUtility.replaceString(filterPostingType,"*","");
 
 if ( filterTransactionType == null || "".equals( filterTransactionType ) )
      filterTransactionType = "*";
 if ( filterPostingType == null || "".equals( filterPostingType ) )
      filterPostingType = "*";

	if(!NonIosCcoPostHelper.MODE_POST.equalsIgnoreCase(strMode) && !NonIosCcoPostHelper.MODE_REPOST.equalsIgnoreCase(strMode)) {
        secNavBar.addFilters(
          "releaseName", releaseName, 12,
          pathGfx+"/"+"release_number.gif",
          "Sorry, no Help available.",
          "Release Number filter"
        );
    } else {
%>
		<input type="hidden" name="releaseName" value='<%=releaseName%>'></input>
<%
    }
			
	    // adding filter
        secNavBar.addFilters(
          "imageName", imageName, 22,
          pathGfx+"/"+"filter_label_imgname.gif",
          "Sorry, no Help available.",
          "Image Name filter"
        );

	    
	    // adding filter
        secNavBar.addFilters(
          "filterTransactionType", filterTransactionType, 12,
          pathGfx+"/"+"filter_label_transaction_status.gif",
          "Sorry, no Help available.",
          "Transaction Status filter"
        );

	    
	    // adding filter
        secNavBar.addFilters(
          "filterPostingType", filterPostingType, 22,
          pathGfx+"/"+"filter_label_posting_status.gif",
          "Sorry, no Help available.",
          "Posting Type filter"
        );
        
        		
        // if the user is secondary publisher
	    
	    if(isSecondaryPublisher){
        	 out.println( SpritGUI.renderTabContextNav( globals,
                     secNavBar.render(
                         new boolean [] { ( NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode) )   ? false : true,
                                          ( NonIosCcoPostHelper.MODE_POST.equalsIgnoreCase(strMode) )   ? false : true
             
                                        },
                         new String []  { NonIosCcoPostHelper.NAV_BAR_VIEW_ALL, 
                                          NonIosCcoPostHelper.MODE_POST 
                                       
                                        },
                         new String []  { NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                            (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                            (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : ""),
                                          NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_POST + 
                                            "&" + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                            (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                            (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : "")
                                        
                                        }
                         ) ) );
        	
        }
        
        // if the user is a software type PM or Admin
        else if((isSoftwareTypePM ||
            spritAccessManager.isAdminSprit() ||
            spritAccessManager.isAdminCco()) && !SpritUtility.isSoftwareTypeEndOfSupport(osTypeId.toString()) ) {
        	
        	
          out.println( SpritGUI.renderTabContextNav( globals,
              secNavBar.render(
                  new boolean [] { ( NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode) )   ? false : true,
                                   ( NonIosCcoPostHelper.MODE_POST.equalsIgnoreCase(strMode) )   ? false : true,
                                   ( NonIosCcoPostHelper.MODE_REPOST.equalsIgnoreCase(strMode) ) ? false : true,
                                   ( NonIosCcoPostHelper.MODE_REMOVE.equalsIgnoreCase(strMode) ) ? false : true
                                 },
                  new String []  { NonIosCcoPostHelper.NAV_BAR_VIEW_ALL, 
                                   NonIosCcoPostHelper.MODE_POST, 
                                   "Metadata Repost", 
                                   NonIosCcoPostHelper.MODE_REMOVE
                                 },
                  new String []  { NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : ""),
                                     
                                   NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_POST + 
                                     "&" + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : ""),
                                     
                                     
                                   NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_REPOST + 
                                     "&" + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : ""),
                                     
                                     
                                   NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_REMOVE + 
                                     "&" + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : "")
                                 }
                  ) ) );

        } 
        
        // remove section
        else {
          if(isSoftwareTypePM ||
            spritAccessManager.isAdminSprit() ||
            spritAccessManager.isAdminCco()) {
        	  
        	  
          out.println( SpritGUI.renderTabContextNav( globals,
              secNavBar.render(
                  new boolean [] { ( NonIosCcoPostHelper.MODE_REMOVE.equalsIgnoreCase(strMode) ) ? false : true,
                                   ( NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode) ) ? false : true
                                 },
                  new String []  { NonIosCcoPostHelper.MODE_REMOVE,
                                   NonIosCcoPostHelper.NAV_BAR_VIEW_ALL
                                 },
                  new String []  {   NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_REMOVE + 
                                     "&" + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : ""), 
                                     
                                     
                                     NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : "")
                                 }
                  ) ) );
           } 
          
          // view section -- when user has no write permissions in SPRIT
          
          else 
          {
          out.println( SpritGUI.renderTabContextNav( globals,
              secNavBar.render(
                  new boolean [] { ( NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode) ) ? false : true
                                 },
                  new String []  { NonIosCcoPostHelper.NAV_BAR_VIEW_ALL
                                 },
                  new String []  { NonIosCcoPostHelper.MAIN_URL + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId +
                                     (releaseName != null && !releaseName.trim().equals("") ? "&" + NonIosCcoPostHelper.RELEASE_NAME + "=" + URLEncoder.encode( releaseName ) : "") +
                                     (imageName != null && !imageName.trim().equals("") ? "&" + NonIosCcoPostHelper.IMAGE_NAME + "=" + URLEncoder.encode( imageName ) : "")
                                 }
                  ) ) );
            }                  
        }

      %>
    </td>
  </tr>
</table>

<font size="+1" face="Arial,Helvetica"><b>
<center>
  <%= nonIosCcoPostHelper.getHeader( strMode, nonIosCcoRequestContext ) %>
</center>
</b></font>

<%

  if(errorMessage != null && !errorMessage.equals("")) {
%>
<center>
  <table border="0" cellpadding="0" cellspacing="0" width="60%">
    <tr>
      <td width="20%" valign=\"top\"><font face="Arial,Helvetica" color="#FF0000"><b><blink>WARNING!!!</blink>:</b></font></td>
      <td>
        <table border="1" bordercolor="#FF0000" cellpadding="0" cellspacing="0" width="100%">
<%=errorMessage%>
        
        </table>
      </td>
    </tr>
  </table>
</center>
<%
  }
%>

<% //CSCsr29014 - Validate Product/Release Notes URLs

if ((strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST) || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST))
		&& !action.equalsIgnoreCase(NonIosCcoPostHelper.ACTION_SUBMIT)) {
	String invalidNoteUrlMsg = CcoPostUtility.getInvalidUrlMessage(releaseNumberId, osType);
    if(!SpritUtility.isNullOrEmpty(invalidNoteUrlMsg)){%>
    <br/><center><%=invalidNoteUrlMsg%></center><br/><br/>
<%}}%>

<% // checking for md5 checksum error
  if ( strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST) || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REMOVE) ) {
	if ( action.equalsIgnoreCase(NonIosCcoPostHelper.ACTION_SUBMIT) ) {
	  missingMd5ChecksumError = nonIosCcoRequestContext.generateMissingMd5ChecksumMsg(strMode);
      if ( missingMd5ChecksumError != null ) {
%>
<center>
  <table border="0" cellpadding="0" cellspacing="0" width="60%">
    <tr>
      <td width="20%" valign=\"top\"><font face="Arial,Helvetica" color="#FF0000"><b><blink>WARNING!!!</blink>:</b></font></td>
      <td>
        <table border="1" bordercolor="#FF0000" cellpadding="0" cellspacing="0" width="100%">
<%=missingMd5ChecksumError%>        
        </table>
      </td>
    </tr>
  </table>
</center>

<%
      }
    }
  }
%>

<%
try{
	
	// painting upper button
	
 out.println(nonIosCcoPostHelper.paintUpperButton( request, globals, action, strMode, osTypeId, osType, releaseName, imageName, ttype, ptype, nonIosCcoRequestContext, searchByExactRel )); 
}catch(Exception e){System.out.println(e.toString());}

    if ((strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST) 
      		|| strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_VIEW))&&  isIOSXE ) {
    	  
%>
	<center>
	<table>
	  <table border="0" cellpadding="0" cellspacing="0" width="60%">
	     <tr bgcolor="#ffffff">
	    <td align="left" valign="top">
	    <%=psirtMsg%></td>
	     </tr>
	 </table>
	</table>
	</center>
	<br/> 
 <%
    }

%>

<!---- Email Alias For CCO POST ----->
<%if((strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST)  || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST) 
     || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REMOVE)) 
     && (!action.equalsIgnoreCase(NonIosCcoPostHelper.ACTION_CONFIRM))) {
     //there should be at least one image
     if (nonIosCcoPostHelper.getImageList() != null && nonIosCcoPostHelper.getImageList().size() > 0) { 
     %>     
      
    <center>
    <table>
    <br>
     <br>
      <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="3" cellspacing="1" width="100%">
          <tr bgcolor="#ffffff">
            <td colspan="2" align="center" valign="top">
              <font size="+1" face="Arial,Helvetica"><b>
                 Email Notifications
                </b></font></td>
          </tr>
         
          <tr bgcolor="#ffffff">
            <td bgcolor="#ffffff" align="center" colspan="2" align="center" valign="top"><span class="dataTableTitle">
              Post CCO Posting Emails</span></td>
          </tr>        

           <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="20%" align="left" valign="top"><span class="dataTableTitle">
              CCO POST Complete Alias List</span></td>
            <td align="left" valign="top">   
             
           <!---- if submitted ----->
           <% if(action.equalsIgnoreCase(NonIosCcoPostHelper.ACTION_SUBMIT)){ %>
              
           <% 
           String ccoEmailAliasList = "";
           boolean isSoftwarePMChecked = false;
           boolean isEmailAliasChecked = false;
           
           //get alias entered by user
           if(session.getAttribute("_ccoPostEmailAlias") != null){
            	ccoEmailAliasList = (String)session.getAttribute("_ccoPostEmailAlias");
            }
           
            //get sw pm checkbox value
            String includeSotfwarePM = "";
            if(session.getAttribute("_softwarepm") != null){
            	if(((String)session.getAttribute("_softwarepm")).equals("true")){
            		isSoftwarePMChecked = true;
            	}
            }
            
            //get alias in DB checkbox value
            String includeCcoPostEmailAlias = "";
            if(session.getAttribute("_fromsubmitpage") != null){
            	if(((String)session.getAttribute("_emailalias")).equals("true")){
            		isEmailAliasChecked = true;
            	}
            }
           
            //get complete list
            String ccoPostEmailAliasList = "";
            if(session.getAttribute("_fromsubmitpage") != null){
	            ccoPostEmailAliasList = SpritUtility.getNonIosSuccessEmailAliasList(ccoEmailAliasList,
		    		                         spritAccessManager.getUserId(), osTypeId, strMode,
		    		                         isSoftwarePMChecked, isEmailAliasChecked);		       
		    }else{
		    	 ccoPostEmailAliasList = SpritUtility.getNonIosSuccessEmailAliasList("",
		    		                         spritAccessManager.getUserId(), osTypeId, strMode,
		    		                         true, true);		         
		    }
	       %>
           <textarea name="ccoPostCompleteEmailAlias" cols="80" rows="4" wrap="hard" readonly="yes"><%=ccoPostEmailAliasList%></textarea>
           <!---- if initial view ----->
           <% }else{ %>
           
           <%
           
           String defaultNotification = "";
           String softwarePM = "";
           String emailAlias = "";
           
           try{
               //get default notification
	           defaultNotification = SpritUtility.getSpritEmailAliasListString(osTypeId,
	    			                              "Cco"+strMode+"Completed",System.getProperty("envMode"))
	                                              + "," + spritAccessManager.getUserId();
	           //get alias in db 
	           emailAlias = SpritUtility.getSpritEmailAliasListString(osTypeId, "TransactionNotificationAlias",
	                         System.getProperty("envMode"));
	           //get sw pm              
	           softwarePM = YPublishUtil.getSoftwareTypePMs(osTypeId);      
           }catch(Exception e){
           
           }
           %>
            <table border="0" cellpadding="2" cellspacing="3" width="100%">
            <input type="hidden" name="fromsubmitpage_hidden" value='true'>
                <tr bgcolor="#ffffff">
                  <td width="18%"><span class="dataTableTitle"> Type </span></td>
                  <td> <span class="dataTableTitle"> Email Alias/User </span></td>
                  <td> <span class="dataTableTitle">Include(?)</span></td>
                </tr>
                <tr bgcolor="#ffffff">
                  <td width="18%"><span class="dataTableTitle"> Default Notification:</span></td>
                  <td> <span class="dataTableData"> <%=defaultNotification %></span></td>
                  <td></td>
                </tr>
                <tr bgcolor="#ffffff">
                  <td width="18%"><span class="dataTableTitle"> Software PM:</span></td>
                  <td> <textarea cols="55" rows="3" wrap="hard" readonly="yes"><%=softwarePM%></textarea></td> 
                  <td> <input id='softwarepm' type='checkbox' name='softwarepm' checked>
                       <input type="hidden" name="softwarepm_hidden" value='true'></input>
                       
                   </td>
                </tr>
                <tr bgcolor="#ffffff">
                  <td width="18%"><span class="dataTableTitle"> Email Alias:</span> </td>
                  <td> <textarea cols="55" rows="2" wrap="hard" readonly="yes"><%=emailAlias%></textarea></td> 
                  <td> <input id='emailalias' type='checkbox' name='emailalias' checked>
                       <input type="hidden" name="emailalias_hidden" value='true'></input>
                  </td>
                </tr>
                <tr bgcolor="#ffffff">
                  <td width="18%"><span class="dataTableTitle"> Add Email Alias/User:</span></td>
                  <td> <span class="dataTableData"><input type="text" name="ccoPostEmailAlias" size="73"> </span></td>
                  <td> </td>
                </tr>
              </table>
           <% } %>
            </td>
          </tr>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </table>
    </center>
    
    <% if(strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REMOVE)){%>
    	<br>
    <% } %>
   <% } %>
<% } %>
<!----  Email Alias ends --------------------------->
<!----  Release notes News --------------------------->
<%if((strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_POST)  || strMode.equalsIgnoreCase(NonIosCcoPostHelper.MODE_REPOST)) 
		&& !isSecondaryPublisher) {  
    if (nonIosCcoPostHelper.getImageList() != null && nonIosCcoPostHelper.getImageList().size() > 0) { %>
 <br />
 
<%if(!action.equalsIgnoreCase(NonIosCcoPostHelper.ACTION_SUBMIT)) { 	
%>
 <jsp:include page="inc_releasenotes.jsp">
   <jsp:param name="releaseNumberId" value="<%=releaseNumberId%>" />
   <jsp:param name="releaseName" value="<%=releaseName%>" />
   <jsp:param name="osTypeId" value="<%=osTypeId%>" />
   <jsp:param name="readOnly" value="N" />
   <jsp:param name="releaseMessageRequired" value="Y" />
</jsp:include>

    <center>
    <table>
    <br>
    
      <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="3" cellspacing="1" width="100%">
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Release Notes</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <div id="view-div"></div></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Release Notes</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <div id="view-div"></div></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Product Release Notes</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <div id="editor-grid"></div><div id="content_div"></div><div id="mdf-div"></div></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Release Message</span><br><font class="instructionText">(MaxLength is 350 character including HTML tags)</font></td>
            <td align="left" valign="top"><span class="dataTableData">
              <div id="release_message"></div></span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </table></center>
 <% } else { %>
    <center>
    <table>
    
     <br>
      <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="3" cellspacing="1" width="100%">
          <tr bgcolor="#ffffff">
         
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Release Notes </span></td>
            <td align="left" valign="top"><span class="dataTableData">
            <%
               String relNotes = (String) session.getAttribute("_releaseNotesDataAsString");
               relNotes = (relNotes!= null && !"null".equalsIgnoreCase(relNotes))
               						? relNotes : "";
            %>
              <%= relNotes%></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Release Message (PST)</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <%=session.getAttribute("_releaseMessage") %></span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </table></center>
 <% } %>
 
 <%}%>  
  <!----  end Release notes News --------------------------->  
  

 <br> 
 <% 
   } //if (nonIosCcoPostHelper.getImageList() != null && nonIosCcoPostHelper.getImageList().size() > 0) {
 %> 
  
  
  
  <input type="hidden" name="_submitformflag" value="0" />
  <input type="hidden" name="<%= NonIosCcoPostHelper.ACTION %>" value="" />
  <input type="hidden" name="<%= NonIosCcoPostHelper.MODE %>" value="<%= strMode %>" />

  <input type="hidden" name="_releaseNotesData" value="" />
  <input type="hidden" name="_releaseMessage" value="" />


<!-- asuman has added this comment -->
<%= nonIosCcoPostHelper.paintPage( request, globals, action, strMode, osTypeId, osType, releaseName, imageName, nonIosCcoRequestContext, searchByExactRel ) %>

</form>

<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->
<!-- end -->
