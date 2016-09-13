<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties,
                 com.cisco.eit.sprit.ui.*,
                 com.cisco.eit.sprit.ui.SpritGUI,
                 com.cisco.eit.sprit.ui.SpritGUIBanner,
                 com.cisco.eit.sprit.ui.SpritReleaseTabs,
                 com.cisco.eit.sprit.ui.SpritSecondaryNavBar,
                 com.cisco.eit.sprit.logic.cco.CcoPostIOS,
                 com.cisco.eit.sprit.dataobject.CcoSummary,
                 java.util.Enumeration,
                 com.cisco.eit.sprit.dataobject.CcoInfo,
                 com.cisco.eit.sprit.logic.cco.CcoPostHelper,
                 com.cisco.eit.sprit.logic.cco.PostCcoException,
                 com.cisco.eit.sprit.util.*,
                 java.util.Vector" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.CacheOPUS" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.AdditionsInfo" %>

<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>

<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntity" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntityHome" %>

<%
  Context ctx;
  Integer 			releaseNumberId;
  ReleaseNumberModelHomeLocal   rnmHome;
  ReleaseNumberModelInfo        rnmInfo;
  ReleaseNumberModelLocal       rnmObj;
  SpritAccessManager 		spritAccessManager;
  SpritGlobalInfo 		globals;
  SpritGUIBanner 		banner;
  String 			jndiName;
//  String 			pathGfx;
  String 			releaseNumber = null;


  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
//  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  String user =  spritAccessManager.getUserId();

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  String strMode = request.getParameter("mode");
  if(strMode == null)
     strMode="View";

  try {
     releaseNumberId = new Integer( WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  }

  // Get release number information.
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber();

  } catch( Exception e ) {
    throw e;
  }  // catch

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,releaseNumber)
   );

 //html macros
// htmlNoValue = "<span class=\"noData\"><center>---</center></span>";
  String pathGfx = globals.gs( "pathGfx" );
  String htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit1",
      "Submit",
      "javascript:submitCco()",
      pathGfx + "/" + (strMode.equals("Confirm") ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT),
      "actionBtnSubmit('btnSubmit1', '" + (strMode.equals("Confirm") ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT) + "')",
      "actionBtnSubmitOver('btnSubmit1', '" + (strMode.equals("Confirm") ?
          SpritConstants.GFX_BTN_CONFIRM_OVER : SpritConstants.GFX_BTN_SUBMIT_OVER) + "')"
      );

  String htmlButtonSubmit2 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit2",
      "Submit",
      "javascript:submitCco()",
      pathGfx + "/" + (strMode.equals("Confirm") ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT),
      "actionBtnSubmit('btnSubmit2', '" + (strMode.equals("Confirm") ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT) + "')",
      "actionBtnSubmitOver('btnSubmit2', '" + (strMode.equals("Confirm") ?
          SpritConstants.GFX_BTN_CONFIRM_OVER : SpritConstants.GFX_BTN_SUBMIT_OVER) + "')"
      );

  String htmlButtonSubmit3 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit3",
      "Submit",
      "javascript:history.go(-1)",
      pathGfx + "/" + SpritConstants.GFX_BTN_BACK,
      "actionBtnSubmit('btnSubmit3', '" + SpritConstants.GFX_BTN_BACK + "')",
      "actionBtnSubmitOver('btnSubmit3', '" + SpritConstants.GFX_BTN_BACK_OVER + "')"
      );

  String htmlButtonSubmit4 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit4",
      "Submit",
      "javascript:history.go(-1)",
      pathGfx + "/" + SpritConstants.GFX_BTN_BACK,
      "actionBtnSubmit('btnSubmit4', '" + SpritConstants.GFX_BTN_BACK + "')",
      "actionBtnSubmitOver('btnSubmit4', '" + SpritConstants.GFX_BTN_BACK_OVER + "')"
      );

   if(!"Report".equals(strMode)) {
%>
<%= SpritGUI.pageHeader( globals,"CCO","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getTabs(globals, "cco") %>
<%
   } else {
       response.setContentType("application/vnd.ms-excel");
   }
%>
<%
  String webParamsDefault = ""
        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
  if(!"Report".equals(strMode)) {
 %>


  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
    	<td valign="middle" width="70%" align="left">
          <%
             out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render(
          		new boolean [] { (strMode.equals("View")) ? false : true,
                                   (strMode.equals("Edit")) ? false : true,
                                   (strMode.equals("Repost") ||
                                         ( !spritAccessManager.isAdminSprit() &&
                                              !spritAccessManager.isAdminCco())) ? false : true,
                                    (strMode.equals("Report")) ? false : true},
          		new String [] { "View", "Post", "Repost", "Report" },
          		new String [] { "IosCcoView.jsp?releaseNumberId=" + releaseNumberId,
            		            "IosCcoView.jsp?mode=Edit&releaseNumberId=" + releaseNumberId,
            		            "IosCcoView.jsp?mode=Repost&releaseNumberId=" + releaseNumberId,
            		            "IosCcoView.jsp?mode=Report&releaseNumberId=" + releaseNumberId}
            		        ) ) );

           %>
         </td>
    	<td valign="middle" width="30%" align="left">
          <%
            if(spritAccessManager.isAdminSprit() ||
                 spritAccessManager.isAdminCco()) {
            out.println( SpritGUI.renderTabContextNav( globals,
          	secNavBar.render(
          		new boolean [] { true },
          		new String [] { "UPopulation" },
          		new String [] { "UPopulation.jsp?" + webParamsDefault },
                      false
            		        ) ) );
            }
           %>
         </td>
      </tr>
   </table>
<%
  }
%>
  <center><br/><br/><br/>
<!--  <img src="../gfx/btn_copy_image.gif" alt="Copy Images" border="0" name="btnCopyImages1"
  	onclick="javascript:GetSourceRelease('<%=releaseNumberId%>')"
  	onmouseover="setImg('btnCopyImages1','../gfx/btn_copy_image_over.gif')" onmouseout="setImg('btnCopyImages1','../gfx/btn_copy_image.gif')" /> -->
  </center>

<font size="+1" face="Arial,Helvetica"><b><center>CCO Post Status <%=strMode%></b>
<%
    if( "Confirm".equals(strMode)) {
%><br><font face="Arial,Helvetica" color="#FF0000">(Hit Submit to Confirm and initiate CCO Posting)</font>
<%
    }
%>
</center>
</font>

<jsp:useBean id="releaseBean" scope="session"
    class="com.cisco.eit.sprit.ui.ReleaseBean"></jsp:useBean>

<form name="ccoPost" method="post" action="IosCcoProcessor?releaseNumberId=<%=releaseNumberId%>">
<input type="hidden" name="fromWhere" value="<%=strMode%>">
<input type="hidden" name="_submitformflag" value="0" />
<%

    session.setAttribute("rnmInfo", rnmInfo);

    CcoPostHelper oCcoPostHelper = null;
    CcoSummary summary = null;
    Enumeration enu = null;
    String strErrorMessage = null;
    boolean isIARRequired = false;

    try {
        oCcoPostHelper = (CcoPostHelper)
                session.getAttribute("CcoPostHelper");

        if(oCcoPostHelper == null || !"Confirm".equals(strMode) ||
                !releaseNumberId.equals(oCcoPostHelper.getReleaseNumberId())) {
            oCcoPostHelper = new CcoPostHelper(rnmInfo, user,
                    ("Repost".equals(strMode) ? new Boolean(true): new Boolean(false)));
            session.setAttribute("CcoPostHelper", oCcoPostHelper);
        }

        summary = oCcoPostHelper.getCcoSummary();
        if("Confirm".equals(strMode))
            enu = oCcoPostHelper.getSelectedCcoInfo();
        else
            enu = oCcoPostHelper.getAllImagesCcoInfo();

        isIARRequired = oCcoPostHelper.isIARRequired();
    } catch(PostCcoException e) {
        e.printStackTrace();
        strErrorMessage = e.getMessage();
    }
    
    Vector listOfImagesWithoutFs = null;

    if("Edit".equals(strMode) || "Repost".equals(strMode)) {
        listOfImagesWithoutFs = (Vector)
            oCcoPostHelper.getProperty("AllImagesWithoutFeatureSet");

        Vector listOfImagesWithoutFsId = (Vector)
            oCcoPostHelper.getProperty("AllImagesWithoutFeatureSetId");
        listOfImagesWithoutFs.addAll(listOfImagesWithoutFsId);
    } else {
        listOfImagesWithoutFs = new Vector();
    }

    boolean allowed = false;
    String strEnvMode = System.getProperty("envMode");

    String strWarning = "";

    if(strErrorMessage != null) {
      String strErrMessage = SpritGUI.renderErrorBox(
            globals, "Error!!!",
                strErrorMessage );
%>
    </br></br><%=strErrMessage%></br>
<%
    } else {
        strErrorMessage = (String) session.getAttribute("Error");
        session.removeAttribute("Error");

        if(!SpritUtility.isNullOrEmpty(strErrorMessage)) {
%>
        <br/></br><%=strErrorMessage%></br>
<%
        }
    }

    if(strMode.equals("Edit") ||
         strMode.equals("Repost")) {
        if(summary.getNoOfImagesWithoutImageFile() > 0 ) {
            strWarning = "Some of the images don't have image files in Archive directory.<br>" +
                        " Please contact build engineer before post it. Click <a href=\"CcoImageMissingEmail.jsp?releaseNumberId=" +
                            rnmInfo.getReleaseNumberId() + "\">here</a> to send email to build Engineer.<br>";
            Vector listOfImages = oCcoPostHelper.getAllImagesWithoutImageFile();
            session.setAttribute("missingImages", listOfImages);
        } else if(summary.getNoOfImagesBeingPosted() > 0) {
                strWarning = "This release is being posted. Please wait until it finished.";
        } else if( (strWarning = oCcoPostHelper.isValidRelease()) != null){
            // do nothing
        } else {
            if(strMode.equals("Edit"))
                allowed = spritAccessManager.isAdminSprit() || oCcoPostHelper.checkUserPermissionToPost();
            else
                allowed = spritAccessManager.isAdminSprit() || spritAccessManager.isAdminCco();

            if(!allowed) {
                strWarning = "You don't have permission to this release. You should be either SPRIT admin," +
                        " Release owner, or CCO Milestone owner to post it.";
            } else {
                allowed = ("prod".equals(strEnvMode)) ? oCcoPostHelper.isCryptoUser() : true;
                if(!allowed)
                    strWarning = "You can't post this release as you are not Crypt user.";
            }
        }
    } else {
        allowed = true;
    }

    if( (strMode.equals("Edit") || strMode.equals("Repost")) &&
            strWarning != null && !"".equals(strWarning)) {
%>
<br><center><font face="Arial,Helvetica" color="#FF0000"><b><blink>WARNING!!!</blink>:
                      <%=strWarning%></b></font></br></center>
<%
    }

%>
<script language="javascript"> <!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================
   function doBlink() {
      var blink = document.all.tags("blink")
      for (var i=0; i < blink.length; i++)
         blink[i].style.visibility = blink[i].style.visibility == "" ? "hidden" : "" 
   }

   function startBlink() {
     // Make sure it is IE4
     if (document.all)
        setInterval("doBlink()",500)
   }
   window.onload = startBlink;

  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................
  function actionBtnSubmit(elemName, imagename) {
    if( document.forms['ccoPost'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
  }
  function actionBtnSubmitOver(elemName, imagename) {
    if( document.forms['ccoPost'].elements['_submitformflag'].value==0 ) {
      setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
  }

  function submitCco() {
    var formObj;
    var elements;

    var check = <%=strMode.equals("Repost")
        ? "true" : "false"%>
    var strMode='<%=strMode%>';

    if( strMode == "Edit" || strMode == "Repost" ) {

       var nImagesBeingPosted = document.forms['ccoPost'].imagesBeingPosted.value;
<%--       alert( 'nImagesWithoutImageFileCount - ' + nImagesWithoutImageFileCount );--%>
       if( nImagesBeingPosted > 0 ) {
         alert( "This release is currently posting images to CCO.\nPlease wait until it finishes." );
         return false;
       }

       var nImagesWithoutImageFileCount = document.forms['ccoPost'].imagesWithoutImageFileCount.value;
<%--       alert( 'nImagesWithoutImageFileCount - ' + nImagesWithoutImageFileCount );--%>
       if( nImagesWithoutImageFileCount > 0 ) {
         alert( "Some of the images doesn't have image file. \n Please contact build team at kuong-team@cisco.com." );
         return false;
       }

       var nImagesReady = document.forms['ccoPost'].imagesReadyTobePostedCount.value;
<%--       alert( 'nImagesReady - ' + nImagesReady );--%>
       if( nImagesReady == 0 ) {
         alert( "It seems either all the images are posted or being posted." );
         return false;
       }
    }
<% if(isIARRequired) { %>
    if(strMode == 'Edit' ) {
       var nImagesReady = document.forms['ccoPost'].releaseNotes;
<%--       alert( 'nImagesReady - ' + nImagesReady );--%>
       if( nImagesReady.value == '' ) {
           alert( "Release Notes can't be empty." );
           return false;
       }
<%
    if( oCcoPostHelper.isRebuild()) {
%>
       var softwareAdvisary = document.forms['ccoPost'].softwareAdvisory.value;
       if( softwareAdvisary == '' ) {
           alert( "Software Advisory# can't be empty." );
           return false;
       }
<%
    }
%>
    }
<%
    }
%>
    if(check) {
       var prefixRegex = new RegExp( "^img_" );

       var elems = document.forms['ccoPost'].elements;
       var numElems = elems.length;
       var found = false;
       for( e=0; e<numElems; e++ ) {
          var elemName = elems[e].name;

          if( !found && prefixRegex.test(elemName) ) {
             if( elems[e].checked ) {
                 found = true;
             }
          }
       }  // for( e=0; e<numElems; e++ )

       if( !found ) {
         alert( 'Atlease one image should be selected to submit the post' );
         return false;
       }
    }

    // Make a shortcut to our form's objects.
    formObj = document.forms['ccoPost'];
    elements = formObj.elements;

    // See if we've already submitted this form.  If so then halt!
    if( elements['_submitformflag'].value==0 ) {
      if( strMode == 'Confirm' ) {
           elements['_submitformflag'].value=1;
      }
      document.forms['ccoPost'].submit();
    }  // if( elements['_submitformflag'].value==0 )
  }

function checkboxSetAll(value) {
  var elems,numElems,e,o,elemName,suffixRegex,prefixRegex;

  // Create regexes!
  prefixRegex = new RegExp( "^img_" );

  // Try to get the elements of the form.
  elems = document.forms['ccoPost'].elements;
  numElems = elems.length;
  for( e=0; e<numElems; e++ ) {
    // Remap for convenience.
    elemName = elems[e].name;

    // See if the prefix matches!
      if( prefixRegex.test(elemName) ) {
        elems[e].checked = value;
      }  // if( !prefixRegex.test(elemName) )
  }  // for( e=0; e<numElems; e++ )
}

  -->
</script>

<%
    if(!strMode.equals("Confirm")) {
%>

<table>
<center>
<br>
 <br>
  <table border="0" cellpadding="0" cellspacing="0" width="70%">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1" width="100%">
      <tr bgcolor="#d9d9d9">
	<td align="center" valign="top"><span class="dataTableTitle">
	  Total Images</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Missing</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Already Posted</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Ready to be Posted</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Images being Posted</span></td>
     </tr>
     <tr bgcolor="#ffffff">
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfTotalImages()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfImagesWithoutImageFile()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfImagesAlreadyPosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfImagesReadyToBePosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfImagesBeingPosted()%> </span></td>
     </tr>
     </table>

     </td></tr></table></td></tr></table></table>
<%
    }

    if(allowed && (strMode.equals("Edit") || ( strMode.equals("Confirm") &&
            "Edit".equals(request.getParameter("repedit"))))) {

%>

    <table>
    <center>
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
          <% if(isIARRequired) {%>
          <tr bgcolor="#ffffff">
            <td bgcolor="#ffffff" align="center" colspan="2" align="center" valign="top"><span class="dataTableTitle">
              Pre CCO Posting Emails</span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Image Availability Request Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(strMode.equals("Edit")) {
      %>
            <%=oCcoPostHelper.getProperty("IARAliasList")%>,&nbsp;<br/><input type="text" name="iarList" size="50">
      <%
        } else {
      %>
            <%=oCcoPostHelper.getProperty("IARAliasList")%>
      <%
        }
      %>
              </span></td>
          </tr>
          <% } %>
          <tr bgcolor="#ffffff">
            <td bgcolor="#ffffff" align="center" colspan="2" align="center" valign="top"><span class="dataTableTitle">
              Post CCO Posting Emails</span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Images Available Email Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(strMode.equals("Edit")) {
      %>
            <%=oCcoPostHelper.getProperty("ReadMeAliasList")%>,&nbsp;</br><input type="text" name="readmeList" size="50">
      <%
        } else {
      %>
            <%=oCcoPostHelper.getProperty("ReadMeAliasList")%>
      <%
        }
      %>
              </span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              CCO POST Log Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(strMode.equals("Edit")) {
      %>
            <%=oCcoPostHelper.getProperty("CcoLogAliasList")%>,&nbsp;<br/><input type="text" name="ccoLogList" size="50">
      <%
        } else {
      %>
            <%=oCcoPostHelper.getProperty("CcoLogAliasList")%>
      <%
        }
      %>
              </span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              CCO POST Complete Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(strMode.equals("Edit")) {
      %>
            <%=oCcoPostHelper.getProperty("CcoCompleatedAliasList")%>,&nbsp;<br/><input type="text" name="ccoList" size="50">
      <%
        } else {
      %>
            <%=oCcoPostHelper.getProperty("CcoCompleatedAliasList")%>
      <%
        }
      %>
              </span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </center></table>


<%
    }

  if( strMode.equals("Confirm") &&
            "Repost".equals(request.getParameter("repedit"))) {
%>
    <input type="hidden" name="isRepost" value="true">
<%
  }

  if( strMode.equals("Edit") || strMode.equals("Repost")) {
%>
   <input type="hidden" name="imagesWithoutImageFileCount" value="<%=summary.getNoOfImagesWithoutImageFile()%>">
   <input type="hidden" name="imagesReadyTobePostedCount" value="<%=summary.getNoOfImagesReadyToBePosted()%>">
   <input type="hidden" name="imagesBeingPosted" value="<%=summary.getNoOfImagesBeingPosted()%>">

<%
  }
%>

<%
      if(allowed && isIARRequired && "Edit".equals(strMode)) {
%>
    <table>
    <center>
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
                 IMAGE AVAILABILITY REQUEST <%=rnmInfo.getFullReleaseNumber()%>
                </b></font></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Version</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <%=rnmInfo.getFullReleaseNumber()%></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Program Manager</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <%=user%></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Integration Engr</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <input type="Text" name="integrationEngr" size="35"></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              CCO Post</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              *YES*</span></td>
          </tr>
<%
          if(oCcoPostHelper.isRebuild()) {
%>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Software/Deferral Advisory #</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <input type="Text" name="softwareAdvisory" size="35"></span></td>
          </tr>
<%
          }
%>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Comments</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <textarea name="comments" rows=4 cols="50"></textarea></span></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Release Notes</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <textarea type="TextArea" name="releaseNotes" rows=4 cols="50"></textarea></span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </center></table>

<%
      }
%>

<%
      if( isIARRequired && "Confirm".equals(strMode) &&
              "Edit".equals(request.getParameter("repedit"))) {
%>
<center>
<br>
 <br>
  <table border="0" cellpadding="1" cellspacing="0" width="70%">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1" width="100%">
      <tr bgcolor="#ffffff">
        <td  align="center"><span class="dataTableData">
         <b>Image Availability Request Email</b></td>
      </tr>
      <tr bgcolor="#ffffff"><td align="left"><span class="dataTableData">
         <%=SpritUtility.replaceLineBreakWithBR(
                 oCcoPostHelper.getIARMailContent())%></td>
      </tr></table>
      </td></tr></table>
    </td></tr></table>
    </center>
<%
      }

    if(allowed) {
%>
<br><center><%=(strMode.equals("View") || strMode.equals("Report"))? "" :
               (strMode.equals("Confirm") ? (htmlButtonSubmit3 +
                  "&nbsp;&nbsp;" + htmlButtonSubmit1 )
                   : "<font face=\"Arial,Helvetica\" color=\"#FF0000\"><b><blink>Important</blink>: You should contact and get approval from Software center (andyng) " +
                      " before posting.</b></font></br>" + htmlButtonSubmit1 )%></center>
<%
    }
%>

<table>
<center>
<br>
 <br>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1">
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
<%
    if(/*strMode.equals("Edit") || */ strMode.equals("Repost")) {
%>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Select <br/>
        <a href="javascript:checkboxSetAll(true)">
           <img src="../gfx/btn_all_mini.gif" border="0"/></a>
        <a href="javascript:checkboxSetAll(false)">
           <img src="../gfx/btn_none_mini.gif" border="0" /></a>
      </span></td>
<%
    }
%>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Image Name</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Cco Directory</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Description</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Image Size</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Is CCO Posted?</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Original CCO Post date</span></td>
<%
    if(spritAccessManager.isAdminSprit()) {
%>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Encrypt Value</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  MD5</span></td>
<%
    }
%>
     </tr>
<%
    while(enu.hasMoreElements()) {
        CcoInfo info = (CcoInfo) enu.nextElement();
        String strCssVal;
        if(listOfImagesWithoutFs.contains(info.getImageName()))
            strCssVal = "dataTableDataRed";
        else
            strCssVal = "dataTableData";
        
        if(strMode.equals("Repost") &&
            "N".equals(info.getIsPostedToCco()))
            continue;


%>
     <tr bgcolor="#ffffff">
<%
        if(strMode.equals("Edit") || strMode.equals("Repost")) {
            if(!strMode.equals("Edit")) {
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
<%
            }
            boolean allowEdit = false;
            if( strMode.equals("Edit") &&
                 !"Y".equals(info.getIsPostedToCco()) &&
                      !"I".equals(info.getIsPostedToCco()) &&
                         info.getLengthOfSourceImageFile() != -1)
                allowEdit = true;
            else if( strMode.equals("Repost") &&
                 !"N".equals(info.getIsPostedToCco()) &&
                     info.getLengthOfSourceImageFile() != -1)
                allowEdit = true;
            if(allowEdit) {
                if(strMode.equals("Edit")) {
%>
              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="hidden" name="img_<%=info.getImageId()%>" value="<%=info.getImageId()%>"/>
<%
                } else {
%>
              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="checkbox" name="img_<%=info.getImageId()%>" value="<%=info.getImageId()%>"/>
<%
                }
            } else if(!strMode.equals("Edit")){
%>
         &nbsp;
<%
            }

            if(!strMode.equals("Edit")) {
%>
        </span></td>
<%
            }
        }
%>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getImageName()%> </span></td>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getCcoDir()%> </span></td>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=((info.getDescription() == null) ? "<center>--</center>" : info.getDescription())%> </span></td>
    <td align="right" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getLengthOfSourceImageFile()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=("Y".equals(info.getIsPostedToCco()) ? "Yes" :
                ("N".equals(info.getIsPostedToCco()) ? "No" : 
                    ("I".equals(info.getIsPostedToCco()) ? "In Progress" : "--")))%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=("View".equals(strMode) && "N".equals(info.getIsPostedToCco()))
               ? "--" : ((info.getCcoPostTime() == null)
                    ? "" : info.getCcoPostTime().toString()) %> </span></td>
<%
    if(spritAccessManager.isAdminSprit()) {
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getEncryption()%> </span></td>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getMd5()%> </span></td>
<%
    }
%>
     </tr>
<%
    }
%>
     </table>
     </td></tr></table></td></tr></table></table>
<%
    if(allowed) {
%>
     <br><%=(strMode.equals("View") || strMode.equals("Report"))? "" :
               (strMode.equals("Confirm") ? (htmlButtonSubmit4 +
                  "&nbsp;&nbsp;" + htmlButtonSubmit2 )
                   : "<font face=\"Arial,Helvetica\" color=\"#FF0000\"><b><blink>Important</blink>: You should contact and get approval from Software center (andyng) " +
                      " before posting.</b></font></br>" + htmlButtonSubmit2 )%></center>
<%
    }
%>
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
