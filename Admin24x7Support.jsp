<!--.........................................................................
: DESCRIPTION:
: Admin Support Page: Place for 24x7 issues.
: Excel.
:
: AUTHORS:
: @author Robert Nevitt (rnevitt@cisco.com)
:
: Copyright (c) 2006, 2010, 2013 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%
  Properties props;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String pathGfx;
    String htmlButtonSaveUpdates1;
  TableMaker tableReleasesYouOwn;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  props = (Properties) globals.go( "properties" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );

  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  
  
  htmlButtonSaveUpdates1 = SpritGUI.renderButtonRollover(
	globals,
	"btnSaveUpdates1",
	"Save Updates",
	"javascript: submitPostStatusForm('postStatusParameters') ",
	pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
	"actionBtnSaveUpdates('btnSaveUpdates1')",
	"actionBtnSaveUpdatesOver('btnSaveUpdates1')"
	);
%>
<%= SpritGUI.pageHeader( globals,"24x7 Support Menu","" ) %>
<%= banner.render() %>

<%

//if( spritAccessManager.isAdminSprit() ) {
  StringBuffer htmlSpritInfo;
 
 Properties properties;


 
   properties = (Properties) globals.go( "properties" );
   // Figure out if we're in a different environment mode!



 
 
%>

<span class="headline">
  24x7 Support Menu
</span><br /><br />

<span class="subHeadline">
	Change CCO Status In Our DB only (does not resubmit):
</span><br />
<ul><form action="Admin24x7SupportProcessor" method="post" name="postStatusParameters">
  <input type="hidden" name="_submitformflag" value="0" />
  <input type="hidden" name="callingForm" value="postStatusParameters" />
  <li>Release number ID:<input type="text" name="_releaseNumId" size="14" value="" >   Change status to:<select name ="_ccoStatus"><option value='Fail'>Fail</option><option value='Inprogress'>Inprogress</option><option value='Success'>Success</option></select>   Transaction type:<select name="_trans"><option value='Post'>Post</option><option value='Repost'>Repost</option><option value='Delete'>Delete</option></select></li> <%= htmlButtonSaveUpdates1 %>
</ul>

<br clear="all" />

<script language="javascript">
  //........................................................................  
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................  
  function actionBtnSaveUpdates(elemName) {
	if( document.forms['postStatusParameters'].elements['_submitformflag'].value==0 ) {
	  setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
	}  // if
  }
  function actionBtnSaveUpdatesOver(elemName) {
	if( document.forms['postStatusParameters'].elements['_submitformflag'].value==0 ) {
	  setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
	}  // if
  }
  
 /*CSCuf35307 : WAS8 Testing (Apply check to avoid Numberformat exception on account of passing String param to Integer)*/
   function submitPostStatusForm(formName) {
     formObj = document.forms[formName];
     var validRegex = new RegExp("^[0-9]+$");  
     if (formObj._releaseNumId.value != "" && !validRegex.test(formObj._releaseNumId.value)) {
 	    alert("Release Number ID can not have characters only 0-9 numbers are allowed");
 	    return false;
     }
     
     if (formObj._releaseNumId.value == "" || formObj._releaseNumId.value == null) {
  	    alert("Release Number ID is mandatory");
  	    return false;
     } 
     elements = formObj.elements;
     elements['_submitformflag'].value=1;
  	 formObj.submit();
   }
</script>
<%= Footer.pageFooter(globals) %>
<!-- end -->
