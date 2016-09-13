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
                 java.util.Vector,java.util.Iterator,
				 com.cisco.eit.sprit.logic.ypublishion.*,
                 com.cisco.eit.sprit.logic.ypublish.*" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
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

<%@taglib uri="spritui" prefix="spritui"%>

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
  String            osType = "ION";
//  String 			pathGfx;
  String 			releaseNumber = null;
  boolean			postStopper = false;
  String strMissingMD5Checksum = "";
    
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
//  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  String user =  spritAccessManager.getUserId();

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
    String parameter = request.getParameter("mode");
    int nMode = 1;
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

//try{
     // Set osType based on session attribute IF it exists
  //  osType = (String) session.getAttribute("osType");
         
 // }catch( Exception e ) {
    //do nothing
//  }
  // Get release number information.
  rnmInfo = null;
  try {
    // Setup
    jndiName = "ejblocal:ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup(jndiName);
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
<%= SpritReleaseTabs.getTabs(globals,"ioncco") %>
<%
   } else {
       response.setContentType("application/vnd.ms-excel");
   }
%>

<%
//  String webParamsDefault = ""
//        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
  if(nMode != YPublishConstants.ION_REPORT) {
      boolean [] access;
      String [] urls, titles;

	  if ( (spritAccessManager.isAdminION())){

				access = new boolean [] {
                                   (nMode == YPublishConstants.ION_VIEW) ? false : true,
                                   (nMode == YPublishConstants.ION_MP_POST) ? false : true,
                                   (nMode == YPublishConstants.ION_MP_REMOVE) ? false : true,
								   (nMode == YPublishConstants.ION_PATCH_POST) ? false : true,
								   (nMode == YPublishConstants.ION_PATCH_REMOVE) ? false : true,
                                   (nMode == YPublishConstants.ION_REPORT) ? false : true,
                                                         
                                 };
				urls = new String [] {
                                   "CsprIonCcoView.jsp?releaseNumberId=" + releaseNumberId,
                                   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_MP_POST + "&releaseNumberId=" + releaseNumberId,
								   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_MP_REMOVE + "&releaseNumberId=" + releaseNumberId,
                                   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_PATCH_POST + "&releaseNumberId=" + releaseNumberId,
								   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_PATCH_REMOVE + "&releaseNumberId=" + releaseNumberId,
                                   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_REPORT + "&releaseNumberId=" + releaseNumberId                    

                                 };
				titles = new String [] { "View", "Maintenance Pack Post", "Maintenance Pack Remove", "Patch post", "Patch Remove", "Report" };
				           
      }else if(spritAccessManager.isUserION()) {
				 access = new boolean [] {
									   (nMode == YPublishConstants.ION_VIEW) ? false : true,
									   (nMode == YPublishConstants.ION_MP_POST) ? false : true,
									   (nMode == YPublishConstants.ION_REPORT) ? false : true
									 };
				urls = new String [] {
									   "CsprIonCcoView.jsp?releaseNumberId=" + releaseNumberId,
									   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_MP_POST + "&releaseNumberId=" + releaseNumberId,
									   "CsprIonCcoView.jsp?mode=" + YPublishConstants.ION_REPORT + "&releaseNumberId=" + releaseNumberId
									 };
				titles = new String [] { "View", "Maintenance Pack Post", "Report" };
      }else {
		   
				access = new boolean [] {
                                   (nMode == YPublishConstants.ION_VIEW) ? false : true
                                 };
				urls = new String [] {
                                   "CsprIonCcoView.jsp?releaseNumberId=" + releaseNumberId
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
    <%=YpublishPostStatusUtil.getPostingString(nMode,"ION")%></b>
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

<form name="ccoPost" method="post" action="CsprIonCcoProcessor?releaseNumberId=<%=releaseNumberId%>">
<br /><div id="outageMessage" class="warningDiv" style="display: none;"></div>

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

    IonPostHelper oCcoPostHelper = null;
    CcoSummary summary = null;
    Enumeration enu = null;
    String strErrorMessage = null;
	String imagenotExist = "Image Does Not Exist";
	ReleaseCcoPostVO vo = null;
	String strReleaseUrlAsString = "";
    
    try {
        oCcoPostHelper = (IonPostHelper)
                session.getAttribute("IonPostHelper");

        if(oCcoPostHelper == null || nMode != YPublishConstants.CCO_CONFORM ||
                !releaseNumberId.equals(oCcoPostHelper.getReleaseNumberId())) {
            oCcoPostHelper = new IonPostHelper(rnmInfo, user, (short)nMode, null );
            session.setAttribute("IonPostHelper", oCcoPostHelper);
        }

        summary = oCcoPostHelper.getCcoSummary();
		vo = oCcoPostHelper.getReleaseInfo();
		if( vo != null ) {
			StringBuffer buff = new StringBuffer("");
			String [] arrReleaseLabel = vo.getReleaseLabel();
			String [] arrReleaseURL = vo.getReleaseURL();
			
			if (arrReleaseLabel != null && arrReleaseURL != null) {
				for(int i=0;i<arrReleaseURL.length;i++) {
					buff.append("<tr valign=\"top\" bgcolor=\"#ffffff\">")
							.append( "<td align=\"left\" valign=\"top\"><span class=\"dataTableData\">" )
							.append( arrReleaseLabel[i] ).append("</span></td>" )
							.append( "<td align=\"left\" valign=\"top\"><span class=\"dataTableData\">" )
							.append( arrReleaseURL[i] ).append("</span></td>" ). 
						append("</tr>");
				}
			}
			strReleaseUrlAsString = buff.toString();
		}
		
		if(nMode == YPublishConstants.CCO_CONFORM){
            enu = oCcoPostHelper.getSelectedCcoInfo();
            System.out.println("In getSelectedCcoInfo()");
            }
        else {
            enu = oCcoPostHelper.getAllImagesCcoInfo();
            System.out.println("In getAllImagesCcoInfo()");
            }
    } catch(CcoPostException e) {
        e.printStackTrace();
        strErrorMessage = e.getMessage();
    }
    
    if ( nMode == YPublishConstants.CCO_REPOST || nMode == YPublishConstants.CCO_DELETE ) {
        Vector imagesWithoutMD5ChecksumValues = (Vector) oCcoPostHelper.getProperty("imagesWithoutMD5ChecksumValues");
        if ( imagesWithoutMD5ChecksumValues != null && imagesWithoutMD5ChecksumValues.size() > 0 ) {
            strMissingMD5Checksum = YPublishConstants.MISSING_MD5_CHECKSUM_MSG + "<br>";
            Iterator listImagesWithoutMD5ChecksumValues = imagesWithoutMD5ChecksumValues.iterator();
            while ( listImagesWithoutMD5ChecksumValues.hasNext() ) {
                strMissingMD5Checksum += "<br>" + (String)listImagesWithoutMD5ChecksumValues.next();
            }
            strMissingMD5Checksum += "<br>";
        }     
    }
    
  MonitorUtil monUtil = new MonitorUtil();
  monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "ION CCOPost");
    
    boolean allowed = false;
	boolean isIssue = false;
	boolean cryptocheck = false;

	String isChecked = "false";
	
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

     
if ( nMode == YPublishConstants.ION_MP_POST || 
	nMode == YPublishConstants.ION_MP_REMOVE || nMode == YPublishConstants.ION_PATCH_POST ||
                nMode == YPublishConstants.ION_PATCH_REMOVE )
	{
		if (!oCcoPostHelper.isCryptoUser()){
				strWarning = "Sorry - You are not a member of Group CRYPTO and so you may not post images to CCO.";
				cryptocheck = true;
            }
	}

if (!cryptocheck) {
    if( nMode == YPublishConstants.ION_MP_POST || 
            nMode == YPublishConstants.ION_MP_REMOVE ) {
        if(summary.getNoOfIonMPImagesWithoutImageFile() > 0 ) {
            strWarning += "Some of the images don't have image files in Archive directory." +
                        " Please contact build engineer.<br>";
			isIssue = true;
							
        	// get the vector of images which does not have the src loc
			Vector ionMPImagesWithoutImageFiles = oCcoPostHelper.getIonMPImagesWithoutImageFile();
			for(int i=0; i<ionMPImagesWithoutImageFiles.size(); i++) {
				strWarning += "&emsp;&emsp;&emsp;" + ionMPImagesWithoutImageFiles.get(i) + "<br>";
			}
			strWarning += "<br>";
        } 
        
        if (summary.getNoOfMPImagesExceedFileSize() > 0 && nMode != YPublishConstants.ION_MP_REMOVE ) {        
        	// CSCtj32260 file size validation - show the list of images which are exceeding the file size limit
        	strWarning += "Some of the following images have exceeded the 5GB limit set for publishing systems. Please split the image and publish.<br>"; 
        	isIssue = true;
										
        	// get the vector of images which exceed the 5gb limit
			Vector ionMPImagesExceedFileSize = oCcoPostHelper.getIonMPImagesExceedFileSize();
			for(int i=0; i<ionMPImagesExceedFileSize.size(); i++) {
				strWarning += "&emsp;&emsp;&emsp;" + ionMPImagesExceedFileSize.get(i) + "<br>";
			}	
			strWarning += "<br>";					
        } 
        
        if(summary.getNoOfIonMPImagesBeingPosted() > 0) {
                strWarning += "This release is being posted. Please wait until it finished.";
				isIssue = true;
			strWarning += "<br>";
        }
        
        if(summary.getNoOfIonMPImagesReadyToBePosted() == 0) {
                strWarning += "There are no images to do " + YpublishPostStatusUtil.getPostingString(nMode,"ION") + ".";
				isIssue = true;
			strWarning += "<br>";
        } 
        
        if (!oCcoPostHelper.isCryptoUser()){
				strWarning += "Sorry - You are not a member of Group CRYPTO and so you may not post images to CCO.";
				isIssue = true;
			strWarning += "<br>";
            }
	}
}
		if (!isIssue) {		
			allowed = true;
		 }

if (!cryptocheck) {
	if ( nMode == YPublishConstants.ION_PATCH_POST ||
                nMode == YPublishConstants.ION_PATCH_REMOVE){
		if (allowed)
			allowed = false;
		if(summary.getNoOfIonPatchImagesWithoutImageFile() > 0 ) {
            strWarning += "Some of the images don't have image files in Archive directory." +
                        " Please contact build engineer.<br>";
			isIssue = true;
							
        	// get the vector of images which exceeds 5gb limit
			Vector ionPatchImagesWithoutImageFiles = oCcoPostHelper.getIonPatchImagesWithoutImageFile();
			for(int i=0; i<ionPatchImagesWithoutImageFiles.size(); i++) {
				strWarning += "&emsp;&emsp;&emsp;" + ionPatchImagesWithoutImageFiles.get(i) + "<br>";
			}
			strWarning += "<br>";
        } 
        
        if (summary.getNoOfIonPatchImagesExceedFileSize() > 0 && nMode != YPublishConstants.ION_PATCH_REMOVE) { 
        	strWarning += "Some of the images have exceeded the 5GB limit set for publishing systems. Please split the image and publish.<br>"; 
        	isIssue = true;
							
        	// get the vector of images which does not have the src loc
			Vector ionPatchImagesExceedFileSize = oCcoPostHelper.getIonPatchImagesExceedFileSize();
			for(int i=0; i<ionPatchImagesExceedFileSize.size(); i++) {
				strWarning += "&emsp;&emsp;&emsp;" + ionPatchImagesExceedFileSize.get(i) + "<br>";
			}
			strWarning += "<br>";
        }  
        
        if(summary.getNoOfIonPatchImagesBeingPosted() > 0) {
                strWarning += "This release is being posted. Please wait until it finished.";
				isIssue = true;
			strWarning += "<br>";
        }
        
        if(summary.getNoOfIonPatchImagesReadyToBePosted() == 0) {
                strWarning += "There are no images to do " + YpublishPostStatusUtil.getPostingString(nMode,"ION") + ".";
				isIssue = true;
			strWarning += "<br>";
		}
		
		if (!oCcoPostHelper.isCryptoUser()){
				strWarning += "Sorry - You are not a member of Group CRYPTO and so you may not post images to CCO.";
				isIssue = true;
			strWarning += "<br>";
            }
	}

}
	if (!isIssue) {		
			allowed = true;
		 }

	
    if( ( nMode == YPublishConstants.ION_MP_POST ||  nMode == YPublishConstants.ION_VIEW ||
            nMode == YPublishConstants.ION_MP_REMOVE ||
            nMode == YPublishConstants.ION_PATCH_POST ||
                nMode == YPublishConstants.ION_PATCH_REMOVE ) && strWarning != null && !"".equals(strWarning))
     
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
<%
     if ( strMissingMD5Checksum != null && !"".equals(strMissingMD5Checksum) ) {
 %>
 <center>
 <table border="1" cellpadding="0" cellspacing="0" width="60%">
     <tr bgcolor="#ffffff">
     <td align="left" valign="top">
        <font color="#FF0000"><%=strMissingMD5Checksum%></font>
     </td>
     </tr>
 </table>
 <%
    }
 %> 

<script language="javascript"> <!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================
	
	function releaseNoteIsRequired(objLabel, objNote) {
		var isEitherOneEmpty = false;
		var message = '';
		if (objLabel != null) {
			for(i=0;i<objLabel.length;i++) {
				//If both Label and URL are empty its not an error
				if((trim(objLabel[i].value).length == 0) && (trim(objNote[i].value).length == 0))
					continue;
				
				if (trim(objLabel[i].value).length == 0) {
					message = 'Release Note Label is Required\n';
					isEitherOneEmpty = true;
				}
				
				if(trim(objNote[i].value).length == 0) {
					message = message + 'Release Note URL is Required\n';
					isEitherOneEmpty = true;
				}
				
				if(isEitherOneEmpty)
					return message;
			}
		}
		
		return message;			
	}
  
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

    var check = <%=(nMode == YPublishConstants.ION_MP_REMOVE || nMode == YPublishConstants.ION_PATCH_REMOVE ||
		nMode == YPublishConstants.ION_MP_POST || nMode == YPublishConstants.ION_PATCH_POST )
        ? "true" : "false"%>;
    var strMode='<%=nMode%>';
    var exp=<%=( nMode == YPublishConstants.ION_MP_POST ||
				 nMode == YPublishConstants.ION_MP_REMOVE ||
				 nMode == YPublishConstants.ION_PATCH_POST ||
				 nMode == YPublishConstants.ION_PATCH_REMOVE ) ? "true" : "false"%>;

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

<% if(nMode == YPublishConstants.ION_MP_POST ||
		 nMode == YPublishConstants.ION_PATCH_POST) { %>
    var errorMessage = objReleaseNotes.validateReleaseNotes();
       if(errorMessage != '') {
	   alert('Error:\n'+errorMessage);
          return false;
    }
<%
    }
%>
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

function checkRequiredPatches() {
		
	formObj = document.forms['ccoPost'];
    elements = formObj.elements;

	if (elements['requiredpatches'].checked == true)
	{
		isChecked = "true";
		elements['requiredpatches'].value = "true";
	}else{
		isChecked = "false";
		elements['requiredpatches'].value = "false";
	}
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
	<td align="center" valign="top"><span class="dataTableTitle">
	  Images Ready to be Posted</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Images being Posted</span></td>
   	<td align="center" valign="top"><span class="dataTableTitle">
   	  Images exceed 5GB file size</span></td>
     </tr>
	 <%
	 if( nMode == YPublishConstants.ION_MP_POST ||
            nMode == YPublishConstants.ION_MP_REMOVE               
            ){
	%>
     <tr bgcolor="#ffffff">
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonMPTotalImages()%></span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonMPImagesWithoutImageFile()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonMPImagesAlreadyPosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonMPImagesReadyToBePosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonMPImagesBeingPosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfMPImagesExceedFileSize()%></span></td>
     </tr>
	<%
		 }
	%>
	<%
	 if( nMode == YPublishConstants.ION_PATCH_POST ||
            nMode == YPublishConstants.ION_PATCH_REMOVE               
            ){
	%>
     <tr bgcolor="#ffffff">
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonPatchTotalImages()%></span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonPatchImagesWithoutImageFile()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonPatchImagesAlreadyPosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonPatchImagesReadyToBePosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonPatchImagesBeingPosted()%> </span></td>
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfIonPatchImagesExceedFileSize()%> </span></td>
     </tr>
	<%
		 }
	%>

	<%
	 if( nMode == YPublishConstants.ION_VIEW  ){
	%>
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
    <td align="center" valign="top"><span class="dataTableData">
		  <%=summary.getNoOfImagesExceedFileSize()%> </span></td>
     </tr>
	<%
		 }
	%>

	 </table>

     </td></tr></table></td></tr></table></table></center>
<%
		 
    }
%>

<% if( nMode == YPublishConstants.ION_PATCH_POST || nMode == YPublishConstants.ION_MP_POST ) { 
	MonitorUtil.cesMonitorCall("SPRIT-6.8-CSCsi53282-ION UI Release Notes Enhancement", request);
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
                <jsp:include page="inc_ccopostinfo.jsp">
				    <jsp:param name="releaseNumberId" value="<%=releaseNumberId%>" />
				    <jsp:param name="osTypeId" value="39" />
				</jsp:include>
        </table></td></tr></table>
      </td></tr></table>
    </table>
</center>
<% } %>				

<%	if(nMode == YPublishConstants.CCO_CONFORM) { %>
 <center>
    <table>
    <br>
     <br>
      <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
				  Release Notes Location</span></td>
				<td valign="top" bgcolor="#ffffff">
				  <span class="dataTableData">
						<table border="0" cellpadding="0" cellspacing="0" width="100%">   <tr>      <td bgcolor="#3D127B">         <table border="0" cellpadding="0" cellspacing="0" width="100%">            <tr>               <td bgcolor="#BBD1ED">                  <table border="0" cellpadding="3" cellspacing="1" width="100%">
							<tr valign="top" bgcolor="#ffffff">
								<td align="left" valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
									Release Note Label
								</span></td>
								<td align="left" valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
									Release Note Label URL
								</span></td>
							</tr>
							<%=strReleaseUrlAsString%>
						</table></td></tr></table></td></tr></table>
				   </span></td>
		    </tr>
			<tr>
				<td valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
				  Release Message</span></td>
				<td valign="top" bgcolor="#ffffff"><span class="dataTableData">
				  <%=(vo != null && vo.getReleaseMessage() != null) ? vo.getReleaseMessage() : ""%></span></td>
		    </tr>
        </table></td></tr></table>
      </td></tr></table>
    </table>
 </center>
<% } %>				


<%
if((!cryptocheck) && allowed && (nMode == YPublishConstants.ION_MP_POST ||  
	nMode == YPublishConstants.ION_PATCH_POST ||
       ( nMode == YPublishConstants.CCO_CONFORM &&
            ((""+YPublishConstants.ION_MP_POST).equals(request.getParameter("repedit")) || (""+YPublishConstants.ION_PATCH_POST).equals(request.getParameter("repedit")) ))))

        {

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
             ION CCO POST Complete Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(nMode == YPublishConstants.ION_MP_POST || nMode == YPublishConstants.ION_PATCH_POST )  {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IonCcoCompletedAliasList"))%>&nbsp;<br><input type="text" name="ccoList" size="60">
      <%
        } else {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IonCcoCompletedAliasList"))%>
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


  if( nMode == YPublishConstants.ION_MP_POST || nMode == YPublishConstants.ION_PATCH_POST ||
	  nMode == YPublishConstants.ION_MP_REMOVE ||  nMode == YPublishConstants.ION_PATCH_REMOVE ) {
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
<br><center>
		<spritui:outage name="ypublish">
			<%=(nMode == YPublishConstants.ION_VIEW ||
			                    nMode == YPublishConstants.ION_REPORT)? "" :
			               (nMode == YPublishConstants.CCO_CONFORM ? (htmlButtonSubmit3 +
			                  "&nbsp;&nbsp;" + htmlButtonSubmit1 )
			                   : "<font face=\"Arial,Helvetica\" color=\"#FF0000\"><br>" + htmlButtonSubmit1 )%>
		</spritui:outage>
</center><br>
<% 
	if(!(nMode == YPublishConstants.ION_VIEW) && (nMode == YPublishConstants.CCO_CONFORM) ){

		if ((""+YPublishConstants.ION_MP_POST).equals(request.getParameter("repedit"))){
%>
	<br><center><input type="checkbox" name="requiredpatches" value="<%=isChecked%>" onClick="checkRequiredPatches()" /><font size="-1" face="Arial,Helvetica"><b>&nbsp; Do you Want Required Patches To Post Along With this Selected Maintenance Pack</b></font></center><br>
<%
			}
		}
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
    if(nMode == YPublishConstants.ION_MP_REMOVE 
            ||  nMode == YPublishConstants.ION_PATCH_REMOVE || nMode == YPublishConstants.ION_MP_POST
			|| nMode == YPublishConstants.ION_PATCH_POST ) {
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
	  Patch/Maintenance Pack Id</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  Description</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Image Size</span></td>
   	  <td align="center" valign="top"><span class="dataTableTitle">
   	  Type</span></td>
   	  <td align="center" valign="top"><span class="dataTableTitle">
   	  Prod Type</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Status</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Original CCO Post date</span></td>
<%
    if(spritAccessManager.isAdminION()) {
%>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Encrypt Value</span></td>
<%
    }
%>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Messages (PST)</span></td>
   </tr>
<%
if( nMode == YPublishConstants.ION_VIEW ||
            nMode == YPublishConstants.ION_REPORT              
            )
	{	

	  while(enu.hasMoreElements()) {
        CcoInfo info = (CcoInfo) enu.nextElement();
        String strCssVal;
	    strCssVal = "dataTableData";
		String LengthOfSourceImageFile = Long.toString(info.getLengthOfSourceImageFile());
%>
	<tr bgcolor="#ffffff">
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
		  <%=info.getProdType()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getImageStatus()%></span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=(nMode == YPublishConstants.ION_VIEW && "N".equals(info.getIsPostedToCco()))
               ? "--" : ((info.getCcoPostTime() == null)
                    ? "" : info.getCcoPostTime().toString()) %> </span></td>

<%
    if(spritAccessManager.isAdminION()) {
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getEncryption()%> </span></td>
		  <%System.out.println("in info.getEncryption()2");%>
<%

}
%>

  
  <!-- added for messaging -->

<% String message = "";
		System.out.println("entered in to my code");
		ArrayList mes = info.getMessages();
		System.out.println("got messages");
		System.out.println("messages : "+ mes);
		int mesSize = mes.size();
		System.out.println("message size = "+mesSize);
		if(mes != null){
		if(mesSize<=2){
		Iterator e1 = mes.iterator(); %>
		<td align="left" valign="top" ><span class="<%=strCssVal%>">
		<% while(e1.hasNext()){ %>
        <ul>
  		<li>
		<%= e1.next() %>
		<% System.out.println("-------In the less than two messges block---------");%>
		</li>
		</ul>		
		<% } %>
		</span></td>
	<% }else{
		Iterator e2 = mes.iterator(); %>
		<td align="left" valign="top" ><span class="<%=strCssVal%>">
		<ul>
  		<li>
		<%=  mes.get(0)  %>
		 </li>
  		<li>
		<%= mes.get(1) %>
	</li>
	<%while(e2.hasNext()){
	//message += e2.next()+"$"+"\n";
	message += e2.next()+"$";
	System.out.println("In the less than two messges block");
	}%>
  		<li>	
    <h4><a href="javascript:MessagePopup('<%=message%>')" onMouseOver="MessagePopup('<%=message%>')"> more </a></h4>
    </li>
  
	</ul>
	</span></td>
		<%
	}
	}
		%>
	
    
<!-- end of adding for messaging -->
  
<%
	  }
}else if( ( nMode == YPublishConstants.ION_MP_POST ||  nMode == YPublishConstants.ION_MP_REMOVE ||
			nMode == YPublishConstants.CCO_CONFORM &&            ((""+YPublishConstants.ION_MP_POST).equals(request.getParameter("repedit")) || 
			((""+YPublishConstants.ION_MP_REMOVE).equals(request.getParameter("repedit"))))
            ))
{

    while(enu.hasMoreElements()) {
        CcoInfo info = (CcoInfo) enu.nextElement();
        String strCssVal;

		strCssVal = "dataTableData";
		String LengthOfSourceMPImageFile = Long.toString(info.getLengthOfSourceImageFile());
		 
        if (info.getType().equalsIgnoreCase("MAINTENANCE PACK")) 

		{

%>
     <tr bgcolor="#ffffff">
<%
        if( nMode == YPublishConstants.ION_MP_POST ||
            nMode == YPublishConstants.ION_MP_REMOVE               
            ) {
           
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
<%
            boolean allowEdit = true;
          
            if(nMode == YPublishConstants.ION_MP_REMOVE || nMode == YPublishConstants.ION_MP_POST )
                allowEdit = info.getAllowedToPost();

            if(allowEdit && allowed) {

%>
              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="hidden" name="imgdesc_<%=info.getImageId()%>" value="<%=info.getDescription()%>"/>
              <input type="checkbox" name="img_<%=info.getImageId()%>" value="<%=info.getImageId()%>"/>
<%

            } else {
%>
<%
            }
%>
        </span></td>
<%
        }
%>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getImageName()%> </span></td>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getCcoDir()%> </span></td>
    <td align="left" valign="top"><span class="<%=strCssVal%>">
		  <%=((info.getDescription() == null) ? "<center>--</center>" : info.getDescription())%> </span></td>
     <td align="center" valign="top"><span class="<%=strCssVal%>">
	<%=((info.getLengthOfSourceImageFile() == -1) ? imagenotExist : LengthOfSourceMPImageFile)%> </span></td> 
	 <td align="right" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getType()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getProdType()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getImageStatus()%></span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=(nMode == YPublishConstants.ION_VIEW && "N".equals(info.getIsPostedToCco()))
               ? "--" : ((info.getCcoPostTime() == null)
                    ? "" : info.getCcoPostTime().toString()) %> </span></td>
<%
    if(spritAccessManager.isAdminION()) {
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getEncryption()%> </span></td>
		  <%System.out.println("in info.getEncryption()1");%>
		  <!-- added for messaging -->

<% String message = "";
		System.out.println("entered in to my code");
		ArrayList mes = info.getMessages();
		System.out.println("got messages");
		System.out.println("messages : "+ mes);
		int mesSize = mes.size();
		System.out.println("message size = "+mesSize);
		if(mes != null){
		if(mesSize<=2){
		Iterator e1 = mes.iterator(); %>
		<td align="left" valign="top" ><span class="<%=strCssVal%>">
		<% while(e1.hasNext()){ %>
        <ul>
  		<li>
		<%= e1.next() %>
		<% System.out.println("-------In the less than two messges block---------");%>
		</li>
		</ul>		
		<% } %>
		</span></td>
	<% }else{
		Iterator e2 = mes.iterator(); %>
		<td align="left" valign="top" ><span class="<%=strCssVal%>">
		<ul>
  		<li>
		<%=  mes.get(0)  %>
		 </li>
  		<li>
		<%= mes.get(1) %>
	</li>
	<%while(e2.hasNext()){
	message += e2.next()+"$"+"\n";
	System.out.println("In the less than two messges block");
	}%>
  		<li>	
    <h4><a href="javascript:MessagePopup('<%=message%>')" onMouseOver="javascript:MessagePopup('<%=message%>')"> more </a></h4>
    </li>
  
	</ul>
	</span></td>
		<%
	}
	
	}
		%>
	
    
<!-- end of adding for messaging -->
<%
    }
%>

     </tr>
<%
		}
	}

}else  if( nMode == YPublishConstants.ION_PATCH_POST ||
            nMode == YPublishConstants.ION_PATCH_REMOVE || nMode == YPublishConstants.CCO_CONFORM               
            )
	{	


	  while(enu.hasMoreElements()) {
        CcoInfo info = (CcoInfo) enu.nextElement();
        String strCssVal;

		strCssVal = "dataTableData";

		String LengthOfSourcePatchImageFile = Long.toString(info.getLengthOfSourceImageFile());
		
        if (info.getType().equalsIgnoreCase("PATCH"))
		{

%>
     <tr bgcolor="#ffffff">
<%
        if( nMode == YPublishConstants.ION_PATCH_POST ||
            nMode == YPublishConstants.ION_PATCH_REMOVE              
            ) {

%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
<%

            boolean allowEdit = true;

            if(nMode == YPublishConstants.ION_PATCH_REMOVE ||  nMode == YPublishConstants.ION_PATCH_POST  )
                allowEdit = info.getAllowedToPost();

            if(allowEdit && allowed ) {
%>
              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="hidden" name="imgdesc_<%=info.getImageId()%>" value="<%=info.getDescription()%>"/>
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
	<%=((info.getLengthOfSourceImageFile() == -1) ? imagenotExist : LengthOfSourcePatchImageFile)%> </span></td>
	 <td align="right" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getType()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getProdType()%> </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getImageStatus()%></span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=(nMode == YPublishConstants.ION_VIEW && "N".equals(info.getIsPostedToCco()))
               ? "--" : ((info.getCcoPostTime() == null)
                    ? "" : info.getCcoPostTime().toString()) %> </span></td>
<%
    if(spritAccessManager.isAdminION()) {
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
		  <%=info.getEncryption()%> </span></td>
		  <%System.out.println("in info.getEncryption()0");%>
		  
		  <!-- added for messaging -->

<% String message = "";
		System.out.println("entered in to my code");
		ArrayList mes = info.getMessages();
		System.out.println("got messages");
		System.out.println("messages : "+ mes);
		int mesSize = mes.size();
		System.out.println("message size = "+mesSize);
		if(mes != null){
		if(mesSize<=2){
		Iterator e1 = mes.iterator(); %>
		<td align="left" valign="top" ><span class="<%=strCssVal%>">
		<% while(e1.hasNext()){ %>
        <ul>
  		<li>
		<%= e1.next() %>
		<% System.out.println("-------In the less than two messges block---------");%>
		</li>
		</ul>		
		<% } %>
		</span></td>
	<% }else{
		Iterator e2 = mes.iterator(); %>
		<td align="left" valign="top" ><span class="<%=strCssVal%>">
		<ul>
  		<li>
		<%=  mes.get(0)  %>
		 </li>
  		<li>
		<%= mes.get(1) %>
	</li>
	<%while(e2.hasNext()){
	message += e2.next()+"$"+"\n";
	System.out.println("In the less than two messges block");
	}%>
  		<li>	
    <h4><a href="javascript:MessagePopup('<%=message%>')" onMouseOver="javascript:MessagePopup('<%=message%>')"> more </a></h4>
    </li>
  
	</ul>
	</span></td>
		<%
	}
	}
		%>
	
    
<!-- end of adding for messaging -->
<%
    }
%>


     </tr>
<%
		}
	}
}
%>
	 </tr>
     </table>
     </td></tr></table></td></tr></table></table></center>
<%
    if((!cryptocheck) && allowed && !postStopper) {
%>
     <center><br>
 		<spritui:outage name="ypublish">
     		<%=(nMode == YPublishConstants.ION_VIEW || nMode == YPublishConstants.ION_REPORT)? "" :
               (nMode == YPublishConstants.CCO_CONFORM ? (htmlButtonSubmit4 +
                  "&nbsp;&nbsp;" + htmlButtonSubmit2 )
                   : "<font face=\"Arial,Helvetica\" color=\"#FF0000\"><br>" + htmlButtonSubmit2 )%>
		</spritui:outage>
	</center>
<%
    }
%>
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
