<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author kumar (kdharmal@cisco.com)
:
: Copyright (c) 2005-2006 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties,
                 com.cisco.eit.sprit.ui.*,
                 com.cisco.eit.sprit.ui.SpritGUI,
                 com.cisco.eit.sprit.ui.SpritGUIBanner,
                 com.cisco.eit.sprit.ui.SpritReleaseTabs,
                 com.cisco.eit.sprit.ui.SpritSecondaryNavBar,
                 com.cisco.eit.sprit.dataobject.CcoSummary,
                 java.util.Enumeration,
                 com.cisco.eit.sprit.dataobject.CcoInfo,
                 com.cisco.eit.sprit.logic.cco.PostCcoException,
                 com.cisco.eit.sprit.util.*,
                 java.util.Vector,
				 com.cisco.eit.sprit.logic.ypublishiox.*,
                 com.cisco.eit.sprit.logic.ypublish.*" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
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
<%@ page import = "com.cisco.rtim.util.WebUtils" %>

<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntity" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntityHome" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

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
  String            osType = "IOX";
  String            osTypeURL = null;
  String            osTypeRnmInfo = null;
//  String 			pathGfx;
  String 			releaseNumber = null;
  boolean			postStopper = false;
  boolean			clean = true;
  String			psirtMsg = "";
  CcoPostUtil		cpu = new CcoPostUtil();
  String			psirtMsgTable="";


  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
//  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  String user =  spritAccessManager.getUserId();

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
    String parameter = request.getParameter("mode");
    int nMode = 1;
	int nIonMode= 0;
    if(!SpritUtility.isNullOrEmpty(parameter))
        nMode=Integer.valueOf(parameter).intValue();

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

///try{
     // Set osType based on session attribute IF it exists
 //   osType = (String) session.getAttribute("osType");
 //    System.out.println( "  session.getAttribute osType '"+osType+"'");
     
 // }catch( Exception e ) {
    //do nothing
 // }
  // Get release number information.
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
	rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId,osType );
    releaseNumber = rnmInfo.getFullReleaseNumber();

  } catch( Exception e ) {
    throw e;
  }  // catch

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addReleaseNumberElement( request,"releaseNumberId" ); //CSCsj36148
//banner.addContextNavElement( "REL:",SpritGUI.renderReleaseNumberNav(globals,releaseNumber));

//Get the osType as stored in the database
//  osTypeRnmInfo  = rnmInfo.getOsType(); //from database

 // try {
 //   osTypeURL = new String(WebUtils.getParameter(request,"osTypeURL"));

//  } catch( Exception e ) {
       // Nothing to do.
// }  

  //-------------------------
  // If the osType in the database is IOS (and only IOS) then we can overide the osType with ION
  // through the session attribute (osType) or the URL value (osTypeURL)
  // This can be done ONLY if the osType in the database is IOS
//    if(osTypeRnmInfo.equalsIgnoreCase("IOS")){
//     if( "ION".equalsIgnoreCase(osTypeURL)|| "ION".equalsIgnoreCase(osType)){
//       osType = "ION";
//       rnmInfo.setOsType("ION");
 //    }else if( "IOX".equalsIgnoreCase(osTypeURL)|| "IOX".equalsIgnoreCase(osType)){
//		osType = "IOX";
 //      rnmInfo.setOsType("IOX");
//	 }else{
//		rnmInfo.setOsType("IOX");
	// }
//  }

 //html macros
// htmlNoValue = "<span class=\"noData\"><center>---</center></span>";
  String pathGfx = globals.gs( "pathGfx" );
  String htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit1",
      "Submit",
      "javascript:submitCco()",
      pathGfx + "/" + (nMode == YPublishConstants.CCO_CONFORM ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT),
      "actionBtnSubmit('btnSubmit1', '" + (nMode == YPublishConstants.CCO_CONFORM ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT) + "')",
      "actionBtnSubmitOver('btnSubmit1', '" + (nMode == YPublishConstants.CCO_CONFORM ?
          SpritConstants.GFX_BTN_CONFIRM_OVER : SpritConstants.GFX_BTN_SUBMIT_OVER) + "')"
      );

  String htmlButtonSubmit2 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit2",
      "Submit",
      "javascript:submitCco()",
      pathGfx + "/" + (nMode == YPublishConstants.CCO_CONFORM ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT),
      "actionBtnSubmit('btnSubmit2', '" + (nMode == YPublishConstants.CCO_CONFORM ?
          SpritConstants.GFX_BTN_CONFIRM : SpritConstants.GFX_BTN_SUBMIT) + "')",
      "actionBtnSubmitOver('btnSubmit2', '" + (nMode == YPublishConstants.CCO_CONFORM ?
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


   if(nMode != YPublishConstants.CCO_REPORT) {
%>
<%= SpritGUI.pageHeader( globals,"cco","") %>
<%= banner.render() %>
<%= SpritReleaseTabs.getNonIosTabs(globals,"cco") %>
<%
   } else {
       response.setContentType("application/vnd.ms-excel");
   }
%>

<%
//  String webParamsDefault = ""
//        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
  if(nMode != YPublishConstants.CCO_REPORT) {
      boolean [] access;
      String [] urls, titles;
      if ( spritAccessManager.isAdminHFR()) {
            access = new boolean [] {
                                   (nMode == YPublishConstants.IOX_VIEW) ? false : true,
                                   (nMode == YPublishConstants.IOX_POST) ? false : true,
                                   (nMode == YPublishConstants.IOX_REMOVE) ? false : true,
								   (nMode == YPublishConstants.IOX_REPORT) ? false : true
             
                                 };
            urls = new String [] {
                                   "CsprIoxCcoView.jsp?releaseNumberId=" + releaseNumberId,
                                   "CsprIoxCcoView.jsp?mode=" + YPublishConstants.IOX_POST + "&releaseNumberId=" + 		releaseNumberId,
                                   "CsprIoxCcoView.jsp?mode=" + YPublishConstants.IOX_REMOVE + "&releaseNumberId=" + 	releaseNumberId,
									"CsprIoxCcoView.jsp?mode=" + YPublishConstants.IOX_REPORT + "&releaseNumberId=" + releaseNumberId
       
                                 };
            titles = new String [] { "View", "Post", "Remove", "Report"};
      }else {
            access = new boolean [] {
                                   (nMode == YPublishConstants.IOX_VIEW) ? false : true
                                    };
            urls = new String [] {
                                   "CsprIoxCcoView.jsp?releaseNumberId=" + releaseNumberId
                                 };
            titles = new String [] { "View" };
      } 
 %>


  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
    	<td valign="middle" width="70%" align="left">
          <%
             out.println( SpritGUI.renderTabContextNav( globals,
          	    secNavBar.render(access,titles,urls)));
           %>
         </td>
      </tr>
   </table>
<%
  }
%>
  <center><br/><br/><br/>

  </center>

<font size="+1" face="Arial,Helvetica"><b><center>
    <%=YpublishPostStatusUtil.getPostingString(nMode,"IOX")%></b>
<%

	if( nMode == YPublishConstants.CCO_CONFORM) {
%><font face="Arial,Helvetica" color="#FF0000">(Hit Submit to Confirm and initiate CCO Posting)</font>
<%
	}
%>
</center>
</font>

<jsp:useBean id="releaseBean" scope="session"
    class="com.cisco.eit.sprit.ui.ReleaseBean"></jsp:useBean>

<form name="ccoPost" method="post" action="CsprIoxCcoProcessor?releaseNumberId=<%=releaseNumberId%>">
<input type="hidden" name="fromWhere" value="<%=nMode%>">
<input type="hidden" name="_submitformflag" value="0" />
<%
		
    if(!SpritUtility.isNullOrEmpty(request.getParameter("repedit"))) {

%>
<input type="hidden" name="PostingType" value="<%=request.getParameter("repedit")%>"/>
<%

    }
%>
<%
    session.setAttribute("rnmInfo", rnmInfo);

    IoxPostHelper oCcoPostHelper = null;
    CcoSummary summary = null;
    Enumeration enu = null;
    String strErrorMessage = null;
    boolean isIARRequired = false;
	String imagenotExist = "Image Does Not Exist";
    
    try {
        oCcoPostHelper = (IoxPostHelper)
                session.getAttribute("IoxPostHelper");

        if(oCcoPostHelper == null || nMode != YPublishConstants.CCO_CONFORM ||
                !releaseNumberId.equals(oCcoPostHelper.getReleaseNumberId())) {
            oCcoPostHelper = new IoxPostHelper(rnmInfo, user, (short)nMode, null );
            session.setAttribute("IoxPostHelper", oCcoPostHelper);
        }

        summary = oCcoPostHelper.getCcoSummary();

		if(nMode == YPublishConstants.CCO_CONFORM)
            enu = oCcoPostHelper.getSelectedCcoInfo();
        else 
            enu = oCcoPostHelper.getAllImagesCcoInfo();

        isIARRequired = oCcoPostHelper.isIARRequired();
     
    } catch(CcoPostException e) {
        e.printStackTrace();
        strErrorMessage = e.getMessage();
    }
    
    Vector listOfImagesWithoutFs = null;

 
    boolean allowed = false;
	boolean cryptocheck = false;
    String strEnvMode = System.getProperty("envMode");
    
   MonitorUtil monUtil = new MonitorUtil();
   monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "IOX CCOPost");

    String strWarning = "";

    if(strErrorMessage != null) {
      String strErrMessage = SpritGUI.renderErrorBox(
            globals, "Error!!!",
                strErrorMessage );
%>
    <%=strErrMessage%></br>
<%
    } else {
        strErrorMessage = (String) session.getAttribute("Error");
        session.removeAttribute("Error");

        if(!SpritUtility.isNullOrEmpty(strErrorMessage)) {
%>
        <%=strErrorMessage%></br>
<%
        }
    }

    
	if (nMode == YPublishConstants.IOX_VIEW || nMode == YPublishConstants.IOX_POST ||
            nMode == YPublishConstants.IOX_REMOVE )
	{
		if (!oCcoPostHelper.isCryptoUser()){
				strWarning = "Sorry - You are not a member of Group CRYPTO and so you may not post images to CCO.";
				cryptocheck = true;
            }
	}

if (!cryptocheck) {
    if( nMode == YPublishConstants.IOX_POST || 
            nMode == YPublishConstants.IOX_REMOVE ) {
        if(summary.getNoOfImagesWithoutImageFile() > 0 ) {
            strWarning = "Some of the images don't have image files in Archive directory.<br>" +
                        " Please contact build engineer before post it.";
				
        } else if(summary.getNoOfImagesBeingPosted() > 0) {
                strWarning = "This release is being posted. Please wait until it finished.";
        } else if(summary.getNoOfImagesReadyToBePosted() == 0) {
                strWarning = "There are no images to do " + YpublishPostStatusUtil.getPostingString(nMode,"IOX") + ".";
        } else {
            if (nMode == YPublishConstants.IOX_POST || nMode == YPublishConstants.IOX_REMOVE )
                allowed = spritAccessManager.isAdminHFR() ;
            if(!allowed) {
                strWarning = "You don't have permission to post this release. You should be either IOX admin," +
                        " Release owner, or CCO Milestone owner to post it.";
            } else {
                if(!oCcoPostHelper.isCryptoUser()) {
                    strWarning = "Sorry - You are not a member of Group CRYPTO and so you may not post images to CCO.";
				}
            }
        }
    } else {
        allowed = true;
    }
}
	
    if( ( nMode == YPublishConstants.IOX_POST ||
            nMode == YPublishConstants.IOX_REMOVE ) && strWarning != null && !"".equals(strWarning))
     
           {
%>

<center>
<table>

  <table border="0" cellpadding="0" cellspacing="0" width="60%">
     <tr bgcolor="#ffffff">
    <td align="left" valign="top">
       <center><font face="Arial,Helvetica" color="#FF0000"><b><blink>ERROR</blink>
</b></font></center><br><font color="#FF0000">
    <%=strWarning%></font></td>
     </tr>
     </table>
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

    var check = <%=(nMode == YPublishConstants.IOX_REMOVE || nMode == YPublishConstants.IOX_POST)
        ? "true" : "false"%>;
    var strMode='<%=nMode%>';
    var exp=<%=( nMode == YPublishConstants.IOX_POST ||
				 nMode == YPublishConstants.IOX_REMOVE) ? "true" : "false"%>;

    if(exp) {
		
       var nImagesBeingPosted = document.forms['ccoPost'].imagesBeingPosted.value;
<%--       alert( 'nImagesWithoutImageFileCount - ' + nImagesWithoutImageFileCount );--%>

       if( nImagesBeingPosted > 0 ) {

         alert( "This release is currently posting images to CCO.\nPlease wait until it finishes." );
         return false;
       }

       var nImagesWithoutImageFileCount = document.forms['ccoPost'].imagesWithoutImageFileCount.value;
<%--       alert( 'nImagesWithoutImageFileCount - ' + nImagesWithoutImageFileCount );--%>
<%--
       if( nImagesWithoutImageFileCount > 0 ) {
         alert( "Some of the images doesn't have image file. \n Please contact build team at kuong-team@cisco.com." );
         return false;
       }
--%>

       var nImagesReady = document.forms['ccoPost'].imagesReadyTobePostedCount.value;
<%--       alert( 'nImagesReady - ' + nImagesReady );--%>
  <%--     if( nImagesReady == 0 ) {
         alert( "It seems either all the images are posted or being posted." );
         return false;
       }--%>
		  
     }
  
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
         alert( 'Atleast one image should be selected to submit the post' );
         return false;
       }
    }
	
    // Make a shortcut to our form's objects.
    formObj = document.forms['ccoPost'];
    elements = formObj.elements;
		
    // See if we've already submitted this form.  If so then halt!
    if( elements['_submitformflag'].value==0 ) {
         elements['_submitformflag'].value=1;
         setImg('btnSubmit1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
         setImg('btnSubmit2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
		 document.forms['ccoPost'].submit();
    }  // if( elements['_submitformflag'].value==0 )
  }
	
  function trim(str) {
       for (var k=0; k<str.length && str.charAt(k)<=" " ; k++) ;
       var newString = str.substring(k,str.length)
       for (var j=newString.length-1; j>=0 && newString.charAt(j)<=" " ; j--) ;

       return newString.substring(0,j+1);
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
   
	if(nMode != YPublishConstants.CCO_CONFORM) {

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
      <tr bgcolor="#d9d9d9">
	<td align="center" valign="top"><span class="dataTableTitle">
	  Total Images</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Missing</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Already Posted</span></td>
<%if(nMode != YPublishConstants.IOX_REMOVE) {%> 
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Ready to be Posted</span></td>
 <% } else {%>
	   <td align="center" valign="top"><span class="dataTableTitle">
	  Images Ready to be Removed</span></td>
	<%}%> 
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Images being Posted</span></td>
     </tr>
     <tr bgcolor="#ffffff">
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfTotalImages()%></span></td>
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

     </td></tr></table></td></tr></table></table></center>
<%
		 
    }

	 if((!cryptocheck) && allowed && (nMode == YPublishConstants.IOX_POST ||
       ( nMode == YPublishConstants.CCO_CONFORM &&
            (""+YPublishConstants.IOX_POST).equals(request.getParameter("repedit"))))) {

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
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
             IOX CCO POST Complete Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(nMode == YPublishConstants.IOX_POST)  {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IoxCcoCompletedAliasList"))%>&nbsp;<br><input type="text" name="ccoList" size="60">
      <%
        } else {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IoxCcoCompletedAliasList"))%>
      <%
        }
      %>
              </span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </table></center>


<%
    }


  if( nMode == YPublishConstants.IOX_POST || nMode == YPublishConstants.IOX_REMOVE ) {
%>
   <input type="hidden" name="imagesWithoutImageFileCount" value="<%=summary.getNoOfImagesWithoutImageFile()%>">
   <input type="hidden" name="imagesReadyTobePostedCount" value="<%=summary.getNoOfImagesReadyToBePosted()%>">
   <input type="hidden" name="imagesBeingPosted" value="<%=summary.getNoOfImagesBeingPosted()%>">

<%
  }
%>

<%
	  
	if((!cryptocheck) && allowed ) {
%>
<br><center><%=(nMode == YPublishConstants.IOX_VIEW ||
                    nMode == YPublishConstants.IOX_REPORT)? "" :
               (nMode == YPublishConstants.CCO_CONFORM ? (htmlButtonSubmit3 +
                  "&nbsp;&nbsp;" + htmlButtonSubmit1 )
                   : "<font face=\"Arial,Helvetica\" color=\"#FF0000\"></font><br>" + htmlButtonSubmit1 )%></center><br>
<%
    }else {
%>
	<br>	
<%
}
%>

<center>
<table>

  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1">
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
<%
    if(nMode == YPublishConstants.IOX_POST || nMode == YPublishConstants.IOX_REMOVE ) {
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
   	  Type</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Status</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Original CCO Post date</span></td>
<%
    if(spritAccessManager.isAdminHFR()) {
%>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Encrypt Value</span></td>
<%
    }
%>
   </tr>
<%

	  while(enu.hasMoreElements()) {
        CcoInfo info = (CcoInfo) enu.nextElement();
        String strCssVal;

		strCssVal = "dataTableData";
		String LengthOfSourceImageFile = Long.toString(info.getLengthOfSourceImageFile());

%>
     <tr bgcolor="#ffffff">
<%
        if( nMode == YPublishConstants.IOX_POST ||
            nMode == YPublishConstants.IOX_REMOVE              
            ) {

%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
<%

            boolean allowEdit = true;
            boolean isSelected = ("Y".equals(info.getSelected())) ? true : false;

            if(nMode == YPublishConstants.IOX_REMOVE ||  nMode == YPublishConstants.IOX_POST  )
                allowEdit = info.getAllowedToPost();

            if(allowEdit && allowed) {
%>
              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="checkbox" name="img_<%=info.getImageId()%>" value="<%=info.getImageId()%>"/>
<%
		   } else {
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
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		<%=((info.getLengthOfSourceImageFile() == -1) ? imagenotExist : LengthOfSourceImageFile )%> </span></td>
	 <td align="right" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getType()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getImageStatus()%></span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=(nMode == YPublishConstants.IOX_VIEW && "N".equals(info.getIsPostedToCco()))
               ? "--" : ((info.getCcoPostTime() == null)
                    ? "" : info.getCcoPostTime().toString()) %> </span></td>
<%
    if(spritAccessManager.isAdminHFR()) {
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getEncryption()%> </span></td>
<%
    }
%>
     </tr>
<%
	}
%>
     </table>
     </td></tr></table></td></tr></table></table></center>
<%
    if( (!cryptocheck) && allowed && !postStopper) {
%>
     <center><br><%=(nMode == YPublishConstants.IOX_VIEW || nMode == YPublishConstants.IOX_REPORT)? "" :
               (nMode == YPublishConstants.CCO_CONFORM ? (htmlButtonSubmit4 +
                  "&nbsp;&nbsp;" + htmlButtonSubmit2 )
                   : "<font face=\"Arial,Helvetica\" color=\"#FF0000\"><br>" + htmlButtonSubmit2 )%></center>
<%
    }
%>
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
