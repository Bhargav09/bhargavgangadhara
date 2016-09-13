<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004-2013 by Cisco Systems, Inc.
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
                 com.cisco.eit.sprit.logic.ypublish.*" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.Timestamp" %> <!-- added by javvaji -->
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.beans.ACLImageInfo" %>
<%@ page import="com.cisco.eit.sprit.logic.cisrommapi.CisrommAPI" %>
<%@ page import="com.cisco.eit.sprit.logic.bom.CacheOPUS" %>
<%@ page import="com.cisco.eit.sprit.logic.imagelist.*" %>

<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleaseccopost.CsprReleaseCcoPostLocalHome" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleaseccopost.CsprReleaseCcoPostLocal" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleasenote.CsprReleaseNoteLocal" %>
<%@ page import="com.cisco.eit.sprit.model.opus.OpusJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.AdditionsInfo" %>

<%@ page import = "com.cisco.eit.sprit.logic.partnosession.*" %>
<%@ page import = "com.cisco.eit.sprit.model.dempartno.*" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.util.exceptions.DataBaseException" %>

<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntity" %>
<%@ page import = "com.cisco.eit.sprit.model.demmfglabel.DemMfgLabelEntityHome" %>

<%@ taglib uri="http://ajaxtags.org/tags/ajax" prefix="ajax" %>
<%@taglib uri="spritui" prefix="spritui"%>

<%
  Context ctx;
  Integer           releaseNumberId;
  ReleaseNumberModelHomeLocal   rnmHome;
  ReleaseNumberModelInfo        rnmInfo;
  ReleaseNumberModelLocal       rnmObj;
  SpritAccessManager        spritAccessManager;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  String            jndiName;
//  String          pathGfx;
  String            releaseNumber = null;
  boolean           postStopper = false;
  boolean 			bCheckBoxEnabled = false;
  String            psirtMsg = "";
  //added by javvaji for calender
  Integer           postingTypeId;
  //String          Posting_Type   = request.getParameter("repedit");
  String            strexpiryDate  = request.getParameter("expiryDate");
  Timestamp         nowTimestamp   = SpritUtility.nowTimestamp();
  Timestamp         dbTsExpiryDate = null;
  String            formattedDate  = SpritUtility.getMMddyyFomat2(nowTimestamp); //"";
  
  // javvaji end 
	  
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
  

    //----------------------------------------------------------------
    // Added after SPRIT_ISSU collape. 2/21/2007. nadialee: BEGIN
    //----------------------------------------------------------------
  MonitorUtil monUtil = new MonitorUtil();

    //----------------------------------------------------------------
    // Added after SPRIT_ISSU collape. 2/21/2007. nadialee: END 
    //----------------------------------------------------------------
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 12/07/2006 nadialee: BEGIN
    //----------------------------------------------------------------
    HashMap imageId2IssuStateInfoHash  = null;
    Vector  issuStateVect              = null;
    String  issuState                  = null;
    Vector  issuStateAlertVect         = new Vector();
    boolean foundIssuImage             = false;   // used for adoption rate

    issuStateAlertVect.addElement("UNKNOWN");
    issuStateAlertVect.addElement("ENABLED");
    issuStateAlertVect.addElement("INCAPABLE");
    issuStateAlertVect.addElement("GEN");
    issuStateAlertVect.addElement("ISSU_OFF");

    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 12/07/2006  nadialee: END
    //----------------------------------------------------------------
  MonitorUtil.cesMonitorCall("CCO Post", request);

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
String releaseNotedRequire = "Y";
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber(); // getting release number
	// javvaji start 04/14 ; 05/15
	dbTsExpiryDate =rnmObj.getTsExpiryDate(releaseNumberId); // getting expiry date
	postingTypeId =rnmInfo.getPostingTypeId();
	if(postingTypeId.intValue()==3) {
		MonitorUtil.cesMonitorCall("SPRIT-6.3-CSCse13328-IOS Hidden Posting", request);
	}
	
    releaseNotedRequire = (nMode == YPublishConstants.CCO_POST && postingTypeId.intValue() != 3) ? "Y" : "N";  //public static final int CCO_POST  = 2;
	
	if(dbTsExpiryDate != null){
        formattedDate=SpritUtility.getMMddyyFomat2(dbTsExpiryDate);
      }
     if( nMode == YPublishConstants.CCO_CONFORM){
         formattedDate=strexpiryDate;
     }
      // System.out.println("dbTsExpiryDate is null........");
      //else
        //formattedDate = SpritUtility.getMMddyyFomat2(nowTimestamp);
    // javvaji end

  } catch( Exception e ) {
  e.printStackTrace();
    throw e;
  }  // catch

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addReleaseNumberElement( request,"releaseNumberId" ); //CSCsj36148
  //banner.addContextNavElement( "REL:",SpritGUI.renderReleaseNumberNav(globals,releaseNumber));

 //html macros
// htmlNoValue = "<span class=\"noData\"><center>---</center></span>";
  String pathGfx = globals.gs( "pathGfx" );
  
  String  htmlButtonSaveUpdates1 = SpritGUI.renderButtonRollover(
        globals,
        "btnSU1",
        "Save modified data and submit transaction later",
        "javascript: savedata() ",
        pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
        "actionBtnSubmit('btnSU1', '" + SpritConstants.GFX_BTN_SAVE_UPDATES + "')",
        "actionBtnSubmitOver('btnSU1', '" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER + "')"
    );
    
  String htmlButtonSaveUpdates2 = SpritGUI.renderButtonRollover(
        globals,
        "btnSU2",
        "Save modified data and submit transaction later",
        "javascript: savedata() ",
        pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
        "actionBtnSubmit('btnSU2', '" + SpritConstants.GFX_BTN_SAVE_UPDATES + "')",
        "actionBtnSubmitOver('btnSU2', '" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER + "')"
    );
      
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

  String htmlButtonSubmit5 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit5",
      "Submit",
      "javascript:submitMissingImageFileEmail()",
      pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT,
      "actionBtnSubmit('btnSubmit5', '" + SpritConstants.GFX_BTN_SUBMIT + "')",
      "actionBtnSubmitOver('btnSubmit5', '" + SpritConstants.GFX_BTN_SUBMIT_OVER + "')"
      );

    String htmlButtonSubmit6 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit6",
      "Resend IAR and/or ReadMe",
      "javascript:resendEmailSubmit()",
      pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT,
      "actionBtnSubmit('btnSubmit6', '" + SpritConstants.GFX_BTN_SUBMIT + "')",
      "actionBtnSubmitOver('btnSubmit6', '" + SpritConstants.GFX_BTN_SUBMIT_OVER + "')"
      );


   if(nMode != YPublishConstants.CCO_REPORT) {
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
//  String webParamsDefault = ""
//        + "releaseNumberId=" + WebUtils.escUrl(releaseNumberId.toString());

  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
  if(nMode != YPublishConstants.CCO_REPORT) {
 %>
  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
        <td valign="middle" width="70%" align="left">
          <%
             out.println( CcoPostHelper.getIOSSecondaryToolBar(globals, spritAccessManager, releaseNumberId, nMode));
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

<%
 if(CcoPostStatusUtil.getPostingString(nMode)==null || "null".equals(CcoPostStatusUtil.getPostingString(nMode))){
%>
 <font size="+1" face="Arial,Helvetica"><b><center></b>
<% }else {  %>
  <font size="+1" face="Arial,Helvetica"><b><center>
<%
    out.println(CcoPostStatusUtil.getPostingString(nMode));
 }
%>
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

<br /><div id="outageMessage" class="warningDiv" style="display: none;"></div>
<br /><div id="invalidAclList" class="warningDiv" style="display: none;"></div>

<form name="ccoPost" method="post" action="CsprIosCcoProcessor?releaseNumberId=<%=releaseNumberId%>">

<input type="hidden" name="_releaseNotesData" value="">
<input type="hidden" name="_savingonly" value="false">
<input type="hidden" name="_releaseMessage" value="">

<input type="hidden" name="fromWhere" value="<%=nMode%>">
<input type="hidden" name="postingTypeId"  value="<%=postingTypeId%>">
<input type="hidden" name="_expiryDate" value="<%=strexpiryDate%>">
<input type="hidden" name="saveonly" value="">

<%
    if(!SpritUtility.isNullOrEmpty(request.getParameter("repedit"))) {
%>
<input type="hidden" name="PostingType" value="<%=request.getParameter("repedit")%>"/>
<%
    }
%>
<%

    session.setAttribute("rnmInfo", rnmInfo);

    CcoPostHelper oCcoPostHelper = null;
    CcoSummary summary = null;
    //CSCuf35307 : WAS 8 Testing (changing Enumeration from enum to en)
    //Enumeration enum = null;
    Enumeration en = null;
    String strErrorMessage = null;
    boolean isIARRequired = false;

    try {
        oCcoPostHelper = (CcoPostHelper)
                session.getAttribute("CcoPostHelper");

        if(oCcoPostHelper == null || nMode != YPublishConstants.CCO_CONFORM ||
                !releaseNumberId.equals(oCcoPostHelper.getReleaseNumberId())) {
            oCcoPostHelper = new CcoPostHelper(rnmInfo, user, (short)nMode, null );
            session.setAttribute("CcoPostHelper", oCcoPostHelper);
        }

        summary = oCcoPostHelper.getCcoSummary();
        if(nMode == YPublishConstants.CCO_CONFORM)
            en = oCcoPostHelper.getSelectedCcoInfo();
        else
            en = oCcoPostHelper.getAllImagesCcoInfo();

        isIARRequired = oCcoPostHelper.isIARRequired();
    } catch(CcoPostException e) {
        e.printStackTrace();
        strErrorMessage = e.getMessage();
    }
%>
<%
   if ( spritAccessManager.isAdminSprit()
      && (nMode == YPublishConstants.CCO_VIEW || nMode == YPublishConstants.CCO_POST)
      && summary.getNoOfImagesAlreadyPosted() > 0
      ) {
%>
<br>
<input type="hidden" name="resendEmailForm" value="N" />
<!--<form name="resendEmailForm" method="post" action="CsprIosCcoProcessor?releaseNumberId=<%=releaseNumberId%>">-->
Resend Emails:  <input type="hidden" name="userId" value="<%=user%>" />
<select name ="_emailToResend"><option value='IAR'>IAR</option><option value='ReadMe'>ReadMe</option><option value='IARandReadMe'>IAR and Readme</option></select>
<%=htmlButtonSubmit6 %>
<!--</form>-->
<br><br>
<% }  // if(spritAccessManager.isAdminSprit()) %>
<%
    Vector listOfImagesWithoutFs = null;

    if(nMode == YPublishConstants.CCO_POST ||
            nMode == YPublishConstants.CCO_REPOST ||
                nMode == YPublishConstants.CCO_DELETE) {
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
    String missingImageFilesNote = "";
    String missingImageFiles = "";
    String missingImageFilesComment = "";
    String strMissingImageFilesWarning = "";
    String strMissingMD5Checksum = "";
    boolean missingMD5Found = false;
    
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

	//CSCsr29014 - Validate Product/Release Notes URLs - START
	//Displays error invalid Release/Product notes URL table. 
	//If any urls are invalid release cannot be CCO Posted/Reposted. Only SaveUpdate of Release/Product notes is permitted
    if(nMode == YPublishConstants.CCO_POST ||
            nMode == YPublishConstants.CCO_REPOST){ 
            String invalidNoteUrlMsg = CcoPostUtility.getInvalidUrlMessage(releaseNumberId, rnmInfo.getOsType());
            %>
            <center><%=invalidNoteUrlMsg%></center><br/><br/>
    <%}
  	//CSCsr29014 - Validate Product/Release Notes URLs - END
    
    if(nMode == YPublishConstants.CCO_POST || nMode ==YPublishConstants.CCO_VIEW) {
    	
    	postStopper = CcoPostUtility.isPostStopper(releaseNumberId);
    	psirtMsg = CcoPostUtility.getPsirtMsg(releaseNumberId);
    }
    
    if ( nMode == YPublishConstants.CCO_REPOST || nMode == YPublishConstants.CCO_DELETE ) {
        Vector imagesWithoutMD5ChecksumValues = (Vector) oCcoPostHelper.getProperty("imagesWithoutMD5ChecksumValues");
        if ( imagesWithoutMD5ChecksumValues != null && imagesWithoutMD5ChecksumValues.size() > 0 ) {
        
            // Do not show the submit button.
            missingMD5Found = true;
            
            // Create the error string.
            strMissingMD5Checksum = YPublishConstants.MISSING_MD5_CHECKSUM_MSG + "<br>";
            Iterator listImagesWithoutMD5ChecksumValues = imagesWithoutMD5ChecksumValues.iterator();
            while ( listImagesWithoutMD5ChecksumValues.hasNext() ) {
                strMissingMD5Checksum += "<br>" + (String)listImagesWithoutMD5ChecksumValues.next();
            }
            strMissingMD5Checksum += "<br>";
        }     
    }
    
    if(nMode == YPublishConstants.CCO_POST ||
         nMode == YPublishConstants.CCO_REPOST ||
            nMode == YPublishConstants.CCO_DELETE) {

        if(summary.getNoOfImagesWithoutImageFile() > 0 && nMode != YPublishConstants.CCO_DELETE) {
        
            strMissingImageFilesWarning = "Some of the images don't have image files in the archive directory.<br>" +
                        "See below for a list of the images and an email recipients list.<br>" +
                        "Please email this list to the build engineer before attempting to post your release.";

            missingImageFilesNote = "The following message will be sent when you press the submit button.<p>";
            missingImageFilesComment = "Your help is needed in determining if these image files were copied to the archive area successfully.";
           
			Vector imagesWithoutImageFiles = oCcoPostHelper.getAllImagesWithoutImageFile();

			System.out.println("jsp CsprIosCcoView: before getAllImagesCcoInfo");
            Enumeration missImageEnum = oCcoPostHelper.getAllImagesCcoInfo();

            while ( missImageEnum.hasMoreElements() ) {
                CcoInfo imageInfo = (CcoInfo) missImageEnum.nextElement();

                if ( imagesWithoutImageFiles.contains(imageInfo.getImageName()) ) {
                    missingImageFiles += YPublishUtil.getFileLocation(imageInfo.getImageName(), imageInfo.getIsDeferred(), rnmInfo)+"\n";
                }
            }
/*
            if( nMode == YPublishConstants.CCO_DELETE) {
            	allowed = true;
            }
*/
        } else if(summary.getNoOfImagesExceedFileSize() > 0 && nMode != YPublishConstants.CCO_DELETE) {
        // CSCtj32260 file size validation
        	strWarning += "Some of the following images have exceeded the 5GB limit set for publishing systems. Please split the image and publish.<br>";       	
										
        	// get the vector of images which exceed the 5gb limit
			Vector imagesExceedFileSize = oCcoPostHelper.getAllImagesExceedFileSize();
			for(int i=0; i<imagesExceedFileSize.size(); i++) {
				strWarning += "&emsp;&emsp;&emsp;" + imagesExceedFileSize.get(i) + "<br>";
			}	
			strWarning += "<br>";       	
        } else if(summary.getNoOfImagesBeingPosted() > 0) {
                strWarning = "This release is being posted. Please wait until it finished.";
        } else if( (strWarning = oCcoPostHelper.isValidRelease()) != null){
            // do nothing
//with 24x7 CCO posting,the following block is commented as they are no longer valid.
/*
        } else if(!spritAccessManager.isAdminSprit() &&
                    !spritAccessManager.isAdminCco() &&
                        !CcoPostUtil.canIPostToday()) {
            strWarning = "We are allowing posting of the releases only Monday and Thursdays.<br> \n" +
                "Please contact Andy(andyng)/Heather(hdeng) for any further help.";
*/
        } else if(summary.getNoOfImagesReadyToBePosted() == 0) {
                strWarning = "There are no images to do " + CcoPostStatusUtil.getPostingString(nMode) + ".";
        } /* else if(oCcoPostHelper.getMissingReleaseMdfConceptId().equals("") && 
           	(postingTypeId.intValue() != 3) ) {
                //strWarning = "This Release has Missing Mdf Concept Id to do " + CcoPostStatusUtil.getPostingString(nMode) + ".";
        } */ else if(summary.getNoOfMissingMdfConceptImages() > 0) {
                strWarning = "Some of the Images has Missing Mdf Concept Id to do " + CcoPostStatusUtil.getPostingString(nMode) + ".";
        } else {
        
          	allowed = spritAccessManager.isAdminSprit() || spritAccessManager.isAdminCco() 
          		|| oCcoPostHelper.checkUserPermissionToPost();

            if(!allowed) {
                strWarning = "You don't have permission to post this release. You should be either SPRIT admin," +
                        " Release owner, or CCO Milestone owner to post it." + oCcoPostHelper.checkUserPermissionToPost();
            } else {
                allowed = ("prod".equals(strEnvMode)) ? oCcoPostHelper.isCryptoUser() : true;
               if(!allowed){
            	//   if(true){
                	strWarning = "You can't post this release as you are not Crypto user.";
//Append below text. CDETS CSCud45855
                	strWarning+="<a href=\"../../help/faq.shtml#post1.2\">Please refer to FAQ page </a>";
                }
                    
                
            }
        }
        
        
		//Sprit 7.3 CSCsu77910, stop posting 
        boolean stopFlag = false;
        try {
        	stopFlag = oCcoPostHelper.getPostingTypeForStopPost(releaseNumberId);
         }catch (DataBaseException dbe){
        	 strWarning += dbe.getMessage();
         }	 
         if(stopFlag)
        	 strWarning += "The Posting type of the release has been changed in CISROMM since the Image List in SPRIT was created. You need to correct this inorder to publish images in right location on Cisco.com. Please contact sprit-team@cisco.com";
        	 
        

        // Msg sent to sprit-team if URL isn't available.
        StringBuffer additionalMsgText = new StringBuffer();
        additionalMsgText.append("An issue occurred while attempting to access the yPublish system, "+YPublishUtil.getEnv("YPublishServletUrl")+".  The server may be down.  Please investigate.  The release number is "+releaseNumber+". The user initiating the request is "+user+".  The action attempted is "+CcoPostStatusUtil.getPostingString(nMode)+".");
        String yPublishStatus =
            YPublishUtil.emanCheck(additionalMsgText);

        if ( ! YPublishConstants.SUCCESS.equals(yPublishStatus) ) {

            String yPublishWarningMsg = "<br>The yPublish system is currently unavailable.  The SPRIT team has been notified.<br><br>";

            if ( strWarning == null || "".equals(strWarning) ) {
                strWarning = yPublishWarningMsg;
            } else {
                strWarning += "<br>"+yPublishWarningMsg;
            }

            // Do not show the submit button.
            allowed = false;
        }
    } else {
        allowed = true;
    }

    String strObsReleaseError = null;
    if((strWarning == null || "".equals(strWarning)) && !spritAccessManager.isAdminCco()) {
	    try {
	        if( IOSMetadataCheck.isReleaseObsolete(rnmInfo.getFullReleaseNumber()) ) {
	        
	        	strObsReleaseError = 
	        	    new String("This release has been Obsoleted in QOT.");
	        	    
	            MonitorUtil.cesMonitorCall("SPRIT-6.2-CSCsd41186-Admin Post Obsolete", request);
	        }
	    } catch(CcoPostException e) {
	    	// Ignore it...
	    }
    }

    if( nMode == YPublishConstants.CCO_POST ||
            nMode == YPublishConstants.CCO_REPOST ||
            nMode == YPublishConstants.CCO_DELETE) {
                if(strWarning != null && !"".equals(strWarning)) {
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
    } else if(strObsReleaseError != null && !"".equals(strObsReleaseError)) {
%>
<center>
<table>

  <table border="0" cellpadding="0" cellspacing="0" width="60%">
     <tr bgcolor="#ffffff">
    <td align="left" valign="top">
       <center><font face="Arial,Helvetica" color="#FF0000"><b><blink>WARNING:</blink>
</b></font><font color="#FF0000"><%=strObsReleaseError%></font></center></td>
     </tr>
     </table>
</table>
 </center>
 <br>
 <%
                }
    }

    // Platform to MDF Concept ID mapping check - Start
    //Collection imageListCollection = null;
    ImageListSessionHome mImageListSessionHome = null;
    ImageListSession mImageListSession = null;

    try
    {
        ctx = JNDIContext.getInitialContext();
        Object homeObject = ctx.lookup("ImageListSessionBean.ImageListSessionHome");
        mImageListSessionHome = (ImageListSessionHome)PortableRemoteObject.narrow(homeObject, ImageListSessionHome.class);
        mImageListSession = mImageListSessionHome.create();
        //imageListCollection = mImageListSession.getAllImageListInfoUtil(releaseNumberId);

        //----------------------------------------------------------------
        // SPRIT-ISSU. Added 12/07/2006 nadialee: BEGIN
        //----------------------------------------------------------------
        if( "IOS".equals(rnmInfo.getOsType()) ) {
            imageId2IssuStateInfoHash = mImageListSession.getAllImageListIssuState(releaseNumberId);
        }
        //----------------------------------------------------------------
        // SPRIT-ISSU. Added 12/07/2006 nadialee: END
        //----------------------------------------------------------------

    }
    catch(Exception e)
    {
        e.printStackTrace();
    }


    MonitorUtil.cesMonitorCall("SPRIT-6.2-CSCsd41193-Report missing MDF", request);
    // Platform to MDF Concept ID mapping check - End
        
    if( (nMode == YPublishConstants.CCO_POST ||
        nMode == YPublishConstants.CCO_REPOST ||
        nMode == YPublishConstants.CCO_DELETE) &&
        strMissingImageFilesWarning != null && !"".equals(strMissingImageFilesWarning)
        )
    {
%>
       <input type="hidden" name="missingImageFilesList" value="<%=missingImageFiles%>">
       <input type="hidden" name="missingImageFilesComment" value="<%=missingImageFilesComment%>">
       <input type="hidden" name="missingImageFilesListEmail" value="true">
<br>
<center>
<table>
  <table border="0" cellpadding="0" cellspacing="0" width="60%">
       <tr bgcolor="#ffffff">
         <td align="left" valign="top">
           <center><font face="Arial,Helvetica" color="#FF0000"><b><blink>ERROR</blink></b></font></center>
           <br><font color="#FF0000"><%=strMissingImageFilesWarning%></font>
         </td>
       </tr>
     <tr bgcolor="#ffffff">
    <td align="left" valign="top">
       <center><font face="Arial,Helvetica" ><b><%=missingImageFilesNote%></b></font></center><br>
       <%=SpritUtility.replaceLineBreakWithBR(
           oCcoPostHelper.getMissingImageFilesMailContent(rnmInfo.getFullReleaseNumber(), missingImageFiles, missingImageFilesComment))%>
    </td>
     </tr>
     <tr bgcolor="#ffffff">
       <td align="left" valign="top">
         <br><font face="Arial,Helvetica" ><b>Email to (separated by one blank space):</b></font></center>
         <input type="text" value="<%=user%>" name="missingImageFilesEmailList" size="50">
       </td>
     </tr>
     <tr bgcolor="#ffffff">
       <td align="left" valign="top">
         <center><font face="Arial,Helvetica" ><%=htmlButtonSubmit5%></font></center>
       </td>
     </tr>
 </table>
<br>
<%
    }
    if ((nMode == YPublishConstants.CCO_POST || nMode == YPublishConstants.CCO_VIEW) ) { 
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
 <% }
    
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

 <%
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/07/2006 nadialee: BEGIN
     //----------------------------------------------------------------

     //
     // Checking for ISSU_OFF.
     // - Generate ISSU warning message if if any image is found to be ISSU_OFF.
     // - However this doesn't prevent the user from their action.
     //

//     boolean issuAlertGenerated = false;
//     String  saTest = String.valueOf(issuAlertGenerated);

     if("IOS".equals(rnmInfo.getOsType()) &&
        ( nMode == YPublishConstants.CCO_VIEW ||
          nMode == YPublishConstants.CCO_POST ||
          nMode == YPublishConstants.CCO_REPOST ||
          nMode == YPublishConstants.CCO_DELETE ||
          nMode == YPublishConstants.CCO_CONFORM ) ) {

         if( imageId2IssuStateInfoHash !=null )  {
             Set         k =  imageId2IssuStateInfoHash.keySet();
             Iterator    iter = null;
             boolean     foundIssuNotVerified = false;

             if( k!=null ) {
                 iter = k.iterator();

                 Integer     imageId;
                 Vector      v = null;
                 String      issuVal = null;

                 while( iter.hasNext() ) {

                     imageId = (Integer) iter.next();
                     v = (Vector) imageId2IssuStateInfoHash.get(imageId);

                     if( v!=null ) {
                         issuVal = (String) v.elementAt(1);
                     }
                     if( issuVal!=null &&
                         issuStateAlertVect.contains(issuVal) ) {

                         foundIssuNotVerified = true;
                         break;
                     } // if

                 } // while

                 if( foundIssuNotVerified) {

//                     issuAlertGenerated = true;

                    monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "CCO Post ISSU Alert");

                     String issuMsg = "There are ISSU-capable image(s) with ISSU State other than 'VER' (verified).";

                     String issuWarning =
                         "<br> \n" +
                         "<center> \n" +
                         "<table> \n" +
                         "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"60%\"> \n" +
                         "    <tr bgcolor=\"#ffffff\"> \n" +
                         "        <td align=\"center\" valign=\"top\"> \n" +
                         "            <font face=\"Arial,Helvetica\" color=\"#FF0000\"> \n" +
                         "                <b>ISSU Capable Image Alert</b>\n" +
                         "            </font> \n" +
                         "            <br><br> \n" +
                         "            <font color=\"#FF0000\">" +
                         "                " + issuMsg + "\n" +
                         "            </font> \n" +
                         "        </td> \n" +
                         "    </tr> \n" +
                         "</table> \n";

                         out.println(issuWarning );

                 } //  if( foundIssuNotVerified)
             } // if( k!=null )

         } // if( imageId2IssuStateInfoHash !=null )

     }// Checking for ISSU_OFF.

     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/07/2006 nadialee: END
     //----------------------------------------------------------------
%>

<script language="javascript"> <!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================
  
   
   function savedata() {
        
        if( validateCcoPost() ) {

            //validate Release Components
            <% if(nMode == YPublishConstants.CCO_POST 
                    || nMode == YPublishConstants.CCO_REPOST) { %>

		        //CSCsr29014 - Validate URL. Display warning message for invalid URL on SaveUpdate
				var warningBuffer = isReleaseURLValid();
		        if( warningBuffer != '' && !confirm(warningBuffer.replace(/<br>/g,'\n') + 'These URLs must be valid at the time of CCO Post/Repost. However, you can save and continue now. \nDo you wish to continue?' )){
            		return false;
		        }

                var result = getResultString();
                if( result != '' && result.substring(0, 'Error'.length ) == 'Error') {
                    Ext.MessageBox.alert('Error', result.substring('Error!'.length ) );
                    return false;
                } else { 
                    document.forms['ccoPost']._releaseNotesData.value = result;
                    document.forms['ccoPost']._savingonly.value = true;
                    document.forms['ccoPost']._releaseMessage.value = document.getElementById('releaseMessage').value;

/*                    
                    document.getElementById('_releaseNotesData').value = result;                    
                    document.getElementById('_savingonly').value = true;                  
                    document.getElementById('_releaseMessage').value = document.getElementById('releaseMessage').value;
*/                      
                    
                    if( !formSubmitted ) {
                         formSubmitted = true;
                         setImg('btnSubmit1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
                         setImg('btnSubmit2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
                         document.forms['ccoPost'].saveonly.value = 'Y';
                         document.forms['ccoPost'].submit();
                    }  // if( !formSubmitted )

                }
                    
            <%} %>
        }
        
        return false;
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
    if( !formSubmitted ) {
      setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
  }
  function actionBtnSubmitOver(elemName, imagename) {
    if( !formSubmitted ) {
      setImg( elemName,"<%=pathGfx + "/"%>" + imagename);
    }  // if
  }

  function submitMissingImageFileEmail() {
      var emailList = document.forms['ccoPost'].missingImageFilesEmailList.value;

      if ( emailList == "" ) {
          alert("Please enter at least one email recipient.");
          return false;
      }
      document.forms['ccoPost'].submit();
  }

  function resendEmailSubmit() {

     document.forms['ccoPost'].resendEmailForm.value = "Y";
     document.forms['ccoPost'].submit();

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
<!-- added by njavvaji -->
<!--  <script language="JavaScript" src="../js/sprit.js"></script> -->
  <script language="JavaScript" src="../js/calendar.js"></script>

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
    <td align="center" valign="top"><span class="dataTableData">
          <%=summary.getNoOfImagesExceedFileSize()%> </span></td>
     </tr>
     </table>

     </td></tr></table></td></tr></table></table></center>
<%
    }

    if(allowed && (nMode == YPublishConstants.CCO_POST ||
       ( nMode == YPublishConstants.CCO_CONFORM &&
            (""+YPublishConstants.CCO_POST).equals(request.getParameter("repedit"))))) {

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
        if(nMode == YPublishConstants.CCO_POST) {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IARAliasList"))%>,&nbsp;<br><input type="text" name="iarList" size="50">
      <%
        } else {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IARAliasList"))%>
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
        if(nMode == YPublishConstants.CCO_POST) {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("ReadMeAliasList"))%>,&nbsp;<br><input type="text" name="readmeList" size="50">
      <%
        } else {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("ReadMeAliasList"))%>
      <%
        }
      %>
              </span></td>
          </tr>
<%--
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              CCO POST Log Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(nMode == YPublishConstants.CCO_POST) {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("CcoLogAliasList"))%>,&nbsp;<br><input type="text" name="ccoLogList" size="50">
      <%
        } else {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("CcoLogAliasList"))%>
      <%
        }
      %>
              </span></td>
          </tr>
--%>
          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              CCO POST Complete Alias List</span></td>
            <td align="left" valign="top"><span class="dataTableData">
      <%
        if(nMode == YPublishConstants.CCO_POST) {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IosCcoCompletedAliasList"))%>,&nbsp;<br><input type="text" name="ccoList" size="50">
      <%
        } else {
      %>
            <%=WebUtils.escHtml((String)oCcoPostHelper.getProperty("IosCcoCompletedAliasList"))%>
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

//  if( nMode == YPublishConstants.CCO_CONFORM &&
//            (""+YPublishConstants.CCO_BINARY_REPOST).equals(request.getParameter("repedit"))) {
//    <input type="hidden" name="isRepost" value="true">
//  }

  if( nMode == YPublishConstants.CCO_POST || nMode == YPublishConstants.CCO_REPOST) {
%>
   <input type="hidden" name="imagesWithoutImageFileCount" value="<%=summary.getNoOfImagesWithoutImageFile()%>">
   <input type="hidden" name="imagesReadyTobePostedCount" value="<%=summary.getNoOfImagesReadyToBePosted()%>">
   <input type="hidden" name="imagesBeingPosted" value="<%=summary.getNoOfImagesBeingPosted()%>">

<%
  }
%>

<%
      if(allowed
    		  && (nMode == YPublishConstants.CCO_POST
    		  	|| nMode == YPublishConstants.CCO_REPOST)) {
    	  System.out.println("releaseNumberId before="+releaseNumberId);
    	  CsprReleaseCcoPostLocal releaseCcoPost = CcoPostHelper.getReleaseCcoPostInfo(releaseNumberId);
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
            <% String engr=  (releaseCcoPost!=null)? releaseCcoPost.getIntgrEngr():""; %>
                 <input type="Text" name="integrationEngr" size="35" value="<%= engr!=null? engr :"" %>"></span></td>
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
              <%String advisory  = releaseCcoPost!=null?releaseCcoPost.getSoftwareAdvisory():""; %>
              <input type="Text" name="softwareAdvisory" size="35" value="<%=advisory!=null? advisory:""%>"></span></td>
          </tr>
<%
          }
%>
<jsp:include page="inc_releasenotes.jsp">
   <jsp:param name="releaseNumberId" value="<%=releaseNumberId%>" />
   <jsp:param name="releaseName" value="<%=rnmInfo.getFullReleaseNumber()%>" />
   <jsp:param name="osTypeId" value="<%= rnmInfo.getOsTypeId()%>" />
   <jsp:param name="readOnly" value="N" />
   <jsp:param name="releaseMessageRequired" value="Y" />
   <jsp:param name="releaseNotesRequired" value="<%= releaseNotedRequire%>" />
</jsp:include>

          <tr bgcolor="#ffffff">
            <td bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">
              Comments</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <%String comments = releaseCcoPost!=null?	releaseCcoPost.getComments():""; %>
              <textarea name="comments" rows=4 cols="50"><%= comments!=null? comments:""%></textarea></span></td>
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
              Release Message</span></td>
            <td align="left" valign="top"><span class="dataTableData">
              <span class="elementInfo">Note: HTML &lt;b&gt;, &lt;i&gt;, &lt;br&gt; & &lt;a&gt; tags are allowed for formatting. This field can contain maximum 350 characters.</span><br />
              <div id="release_message"></div></span></td>
          </tr>
        </table></td></tr></table>
      </td></tr></table>
    </table></center>

<%
      }
%>

<%
      if(((postingTypeId.intValue()==3) && (nMode == YPublishConstants.CCO_POST ||
        nMode == YPublishConstants.CCO_REPOST))) {
%>
    <center>
    <table>
    <br>
     <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="3" cellspacing="1" width="100%">
          <tr bgcolor="#ffffff">
            <td colspan="2" align="center" valign="top">
              <font size="+1" face="Arial,Helvetica"><b>
                 Hidden IOS Release Posting Details
                </b></font></td>
           </tr>
           <tr bgcolor="#ffffff">
             <td bgcolor="#d9d9d9" width ="30%" align="center" valign="top"><span class="dataTableTitle">
              Expiration Date</span></td>
            <td align="left" valign="top">
                <span class="dataTableData">
                <input type="hidden" name="releaseNumberId" value="<%=releaseNumberId%>">
                <input name="expiryDate" size="12" maxlength="8"
                               value=" <%=formattedDate%>"
                               onChange="verifyDate(this);"
                               onFocus="this.blur();">
                         <a href="javascript:show_calendar('ccoPost.expiryDate');"
                            onmouseover="window.status='Date Picker';return true;"
                            onmouseout="window.status='';return true;"><img
                                src="../gfx/calendar.gif" width=24 height=22 border=0
                                align="absmiddle"></a>
                        <a href="javascript:clearField(document.forms['ccoPost'].elements['expiryDate']);">clear</a>
                </span>
            </td>
          </tr>
         </table>
        </td></tr></table>
      </td></tr></table>
    </table>
   </center>

<%
      } else if(((postingTypeId.intValue()==3) && (nMode == YPublishConstants.CCO_VIEW ||
        nMode == YPublishConstants.CCO_CONFORM || nMode == YPublishConstants.CCO_DELETE ))) {
%>
    <center>
    <table>
    <br>
     <table border="0" cellpadding="0" cellspacing="0" width="70%">
      <tr><td bgcolor="#3D127B">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr><td bgcolor="#BBD1ED">
          <table border="0" cellpadding="3" cellspacing="1" width="100%">
          <tr bgcolor="#ffffff">
            <td colspan="2" align="center" valign="top">
              <font size="+1" face="Arial,Helvetica"><b>
                 Hidden IOS Release Posting Details
                </b></font></td>
           </tr>
           <tr bgcolor="#ffffff">
             <td bgcolor="#d9d9d9" width ="30%" align="center" valign="top"><span class="dataTableTitle">
              Expiry Date</span></td>
            <td align="left" valign="top">
                <!--<span class="dataTableData"><%= formattedDate %></span> -->
                <span class="dataTableData"> <%=((nMode == YPublishConstants.CCO_CONFORM) ? formattedDate : (((dbTsExpiryDate == null)
                    ? "" : SpritUtility.getMMddyyFomat2(dbTsExpiryDate))))%> </span>
            </td>
          </tr>
         </table>
        </td></tr></table>
      </td></tr></table>
    </table>
   </center>

<%
    }
%>
<!-- JAVVAJI END -->

<%
      if((nMode == YPublishConstants.CCO_CONFORM) &&
              ((""+YPublishConstants.CCO_POST).equals(request.getParameter("repedit"))
            	|| (""+YPublishConstants.CCO_REPOST).equals(request.getParameter("repedit")))
        ) {
%>
<center>

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
      if ( allowed && (spritAccessManager.isAdminSprit()||!postStopper) && !missingMD5Found ) {
      //if ( allowed && ( !postStopper && !missingMD5Found ) {
%>
<br><center>
		<spritui:outage name="ypublish">
			<%=(nMode == YPublishConstants.CCO_VIEW ||
                nMode == YPublishConstants.CCO_REPORT)? "" :
               (nMode == YPublishConstants.CCO_CONFORM ? (htmlButtonSubmit3 +
                  "&nbsp;&nbsp;" + htmlButtonSubmit1 )
                   :(htmlButtonSubmit1 + "&nbsp;&nbsp;" + htmlButtonSaveUpdates1))%>
		</spritui:outage>
	</center>
<%
    }
%>

<center>
<table>
 <BR>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1">
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
<%
    if(nMode == YPublishConstants.CCO_DELETE ) {
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
      CCO Directory</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Description</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Image Size</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Status</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Image Posting Type</span></td>
    
<%      
    if(oCcoPostHelper.isAnyHiddenACL()) {
        MonitorUtil.cesMonitorCall("SPRIT-6.10-CSCsk94891-Hidden Post ACL IOS", request);
%>  
    <td align="center" valign="top"><span class="dataTableTitle">
       Customer Id</span></td>
<%
    }      
%>  
    <td align="center" valign="top"><span class="dataTableTitle">
      Latest CCO Post date</span></td>
<%
    if(spritAccessManager.isAdminSprit()) {
%>
    <td align="center" valign="top"><span class="dataTableTitle">
      Encrypt Value</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Access Level</span></td>
<%
    }
%>
<%
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 12/07/2006 nadialee: BEGIN
    //----------------------------------------------------------------
    if( "IOS".equals(rnmInfo.getOsType()) ) {
%>
    <td align="center" valign="top"><span class="dataTableTitle">
      ISSU State</span></td>
<%
    } // If IOS
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 12/07/2006 nadialee: END
    //----------------------------------------------------------------
%>



    <!-- javvaji -->
<%
//    if((postingTypeId.intValue()==3)) {
%>
    <!--<td align="center" valign="top"><span class="dataTableTitle">
      Expiration Date</span></td> -->
    <td align="center" width ="10%" valign="top"><span class="dataTableTitle">
      CCO Location Url</span></td>
<%
//    }
%>
<!-- javvaji end -->

<!-- -----Added for CSCtj32292 Messaging Enhancements---- -->

    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Messages (PST)</span></td>
     </tr>

<%
    while(en.hasMoreElements()) {
        CcoInfo info = (CcoInfo) en.nextElement();
        int rowspan = 1;

        if(info.isHiddenACLImage() && info.getACLUsers().size()>0 && nMode != YPublishConstants.CCO_POST && 
            !( nMode == YPublishConstants.CCO_CONFORM && (""+YPublishConstants.CCO_POST).equals(request.getParameter("repedit")))) { 
           rowspan = info.getACLUsers().size();
        }
        
        for(int i=0;i<rowspan;i++) {

            ACLImageInfo aclImageInfo = null;
            if(info.getACLUsers().size() > 0) {
                aclImageInfo = (ACLImageInfo) info.getACLUsers().get(i);
            }
        
        String strCssVal;
        if(listOfImagesWithoutFs.contains(info.getImageName()) ||
                (!info.getIsDeferred() && info.getLengthOfSourceImageFile() == -1) ||
                (info.getIsDeferred() && nMode == YPublishConstants.CCO_REPOST && info.getLengthOfSourceImageFile() == -1))
            strCssVal = "dataTableDataRed";
        else
            strCssVal = "dataTableData";

/*
        if(nMode == YPublishConstants.CCO_REPOST &&
            "N".equals(info.getIsPostedToCco()))
            continue;
*/


%>
     <tr bgcolor="#ffffff">
<%
        if(nMode == YPublishConstants.CCO_POST ||
            nMode == YPublishConstants.CCO_REPOST ||
                nMode == YPublishConstants.CCO_DELETE) {
            if(nMode == YPublishConstants.CCO_DELETE) {
                    if( i == 0 ) {
%>
    <td align="center" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
<%
                    }
            }
            boolean allowEdit = true;
            boolean isSelected = ("Y".equals(info.getSelected())) ? true : false;

            if(nMode == YPublishConstants.CCO_DELETE)
                allowEdit = info.getAllowedToPost();

            if(allowEdit) {
                if(nMode == YPublishConstants.CCO_POST || nMode == YPublishConstants.CCO_REPOST) {
                    if(isSelected) {
                         if( i == 0 ) {
%>
              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="hidden" name="img_<%=info.getImageId()%>" value="<%=info.getImageId()%>"/>
<%
                         }
                    }
                } else {
                	bCheckBoxEnabled = true;
                         if( i == 0 ) {
%>

              <input type="hidden" name="imgname_<%=info.getImageId()%>" value="<%=info.getImageName()%>"/>
              <input type="checkbox" name="img_<%=info.getImageId()%>" value="<%=info.getImageId()%>"/>
<%
                         }
                }
            } else {
                         if( i == 0 ) {
%>
         &nbsp;
<%
                         }
            }
            if(nMode == YPublishConstants.CCO_DELETE) {
                         if( i == 0 ) {

%>
        </span></td>
<%
                         }
            }
        }
%>

<%
                         if( i == 0 ) {
%>                         
    <td align="left" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getImageName()%> </span></td>
    <td align="left" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getCcoDir()%> </span></td>
    <td align="left" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=((info.getDescription() == null) ? "<center>--</center>" : info.getDescription())%> </span></td>
    <td align="right" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getLengthOfSourceImageFile()%> </span></td>
    <td align="center" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getImageStatus()%></span></td>
    <td align="center" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getImagePostingType()%></span></td>
<%
                        }
    if(!oCcoPostHelper.isAnyHiddenACL()) {  
%>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
          <%=(nMode == YPublishConstants.CCO_VIEW && "N".equals(info.getIsPostedToCco()))
               ? "--" : ((info.getCcoPostTime() == null)
                    ? "" : info.getCcoPostTimeAsString()) %> </span></td>
<%
    } else if(info.isHiddenACLImage()) {  
       if( (nMode == YPublishConstants.CCO_POST || nMode == YPublishConstants.CCO_CONFORM )) {
%>

    <td align="center" valign="top"><span class="<%=strCssVal%>">
<%
          if( nMode == YPublishConstants.CCO_POST ) {
%>
           <textarea name="acl_<%=info.getImageId()%>"><%=((aclImageInfo != null) ? info.getActiveAclListAsString() : "")%></textarea>
<%        } else {  %>
           <%=info.getActiveAclListAsString()%>
<%       }   
%>           
          </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>"><%=info.getCcoPostTime()%>
          </span></td>
<%
     } else {
%>   
    <td align="center" valign="top"><span class="<%=strCssVal%>"><%=((aclImageInfo != null) ? aclImageInfo.getUserId() : "&nbsp;")%>
          </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>"><%=((aclImageInfo != null) ? aclImageInfo.getPostedTime() : info.getCcoPostTime()) %>
          </span></td>
<%          
         }
   } else {
 %>
    <td align="center" valign="top"><span class="<%=strCssVal%>">
          </span></td>
    <td align="center" valign="top"><span class="<%=strCssVal%>"><%=info.getCcoPostTime() %>
          </span></td>
 
 <%
    }
    if(spritAccessManager.isAdminSprit()) {
        if( i == 0 ) {
%>
    <td align="center" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getEncryption()%> </span></td>
    <td align="center" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
          <%=info.getAccessLevel()%> </span></td>
<%
         }
    }
%>

<%
    //----------------------------------------------------------------
    // SPRIT-ISSU. Added 12/07/2006 nadialee: BEGIN
    //----------------------------------------------------------------

    if( "IOS".equals(rnmInfo.getOsType()) &&
         imageId2IssuStateInfoHash != null &&
         imageId2IssuStateInfoHash.containsKey(new Integer(info.getImageId()))
       ) {

         foundIssuImage = true;

         issuStateVect = (Vector) imageId2IssuStateInfoHash.get(new Integer(info.getImageId()));

         issuState = (String) issuStateVect.elementAt(1);

         issuState = (issuState==null || issuState.trim().length()==0 ) ? "N/A" : issuState;

         //------------------------------------------------------------
         // - DELETE page' doesn't generate ISSU alert.
         // - If issuAlert is not generated, take the default font color
         //   for the row.
         //------------------------------------------------------------
         if( issuStateAlertVect != null &&
             issuState != null &&
             issuState.trim().length() > 0 &&
             issuStateAlertVect.contains(issuState) ) {

             strCssVal  = "dataTableDataRed";
         } else {
             strCssVal  = "dataTableData";
         }
        if( i == 0 ) {
%>
    <td align="center" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
        <%=issuState%>
    </span></td>
<%
        }
    } // if( "IOS".equals(rnmInfo.getOsType()) && . . .
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/07/2006 nadialee: END
     //----------------------------------------------------------------
%>


<!-- njavvaji -->
<%
        if( i == 0 ) {                    
%>
    <!--<td align="center" valign="top"><span class="<%=strCssVal%>">
     <%=((info.getExpiryDate() == null)
                    ? "" : info.getExpiryDate().toString())%></span></td> -->
    <td align="left"  valign="top" rowspan=<%=rowspan%>>
    <span class="<%=strCssVal%>"> <%=((info.getCco_download_url() == null) ? "Not available" : "<a href='" + info.getCco_download_url() + "'>CCO download URL</a>")%>
       </span></td>

<%
    }
%>
<!-- -----Added for CSCtj32292 Messaging Enhancements---- -->
		<% String message = "";
		ArrayList mes = info.getMessages();
		int mesSize = mes.size();
		if(mes != null){
		if(mesSize<=2){
		Iterator e1 = mes.iterator(); %>
		<td align="left" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
		<% while(e1.hasNext()){ %>
        <ul>
  		<li>
		<%= e1.next() %>
		</li>
		</ul>		
		<% } %>
		</span></td>
	<% }else{
		Iterator e2 = mes.iterator(); %>
		<td align="left" valign="top" rowspan=<%=rowspan%>><span class="<%=strCssVal%>">
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
		
         
<!-- -----End CSCtj32292 Messaging Enhancements --> 
    </tr>
<%
    }
    }
%>
     </table>
     </td></tr></table></td></tr></table></table></center>
<%
    boolean bSubmit = false;
    if( nMode == YPublishConstants.CCO_DELETE && bCheckBoxEnabled && 
    	(spritAccessManager.isAdminSprit() || spritAccessManager.isAdminCco()) && oCcoPostHelper.isCryptoUser() ) {
         	bSubmit = true;
    }
   //if ( !missingMD5Found && ( bSubmit || (allowed && !postStopper) ) ) {
    if ( !missingMD5Found && ( bSubmit || (allowed && (spritAccessManager.isAdminSprit()||!postStopper)) ) ) {
%>
     <center><br>
     	<spritui:outage name="ypublish">
	     	<%=(nMode == YPublishConstants.CCO_VIEW || nMode == YPublishConstants.CCO_REPORT)? "" :
	               (nMode == YPublishConstants.CCO_CONFORM ? (htmlButtonSubmit4 +
	                  "&nbsp;&nbsp;" + htmlButtonSubmit2 )
	                   :htmlButtonSubmit2  + "&nbsp;&nbsp;" + htmlButtonSaveUpdates2)%>
		</spritui:outage>
	</center>
<%
    }
%>

<%
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/20/2006 nadialee: BEGIN
     //----------------------------------------------------------------
      if( foundIssuImage ) {
         monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "CCO Post ISSU State Display");
      } //if( foundIssuImage )
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 12/20/2006 nadialee: END
     //----------------------------------------------------------------
%>

<input type="hidden" name="callingForm" value="ccoSubmitForm" />
</form>
	<script type="text/javascript">
	var formSubmitted = false;
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
     
		  function validateCcoPost() {
            var strMode='<%=nMode%>';
		  
		      <!--        <% if(isIARRequired) { %> -->
            if(strMode == '<%=YPublishConstants.CCO_POST%>'
                || strMode == '<%=YPublishConstants.CCO_REPOST%>'){
        <%
            if( oCcoPostHelper.isRebuild()) {
        %>
               var softwareAdvisary = document.forms['ccoPost'].softwareAdvisory;
               if( trim(softwareAdvisary.value) == '' ) {
               <% if( postingTypeId.intValue() != 3 ) { %>
                   alert( "Software Advisory# can't be empty." );
                   return false;
               <% } else { %>
                   softwareAdvisary.value="-NA-";
               <% } %>
               }
        <%
            } // if( oCcoPostHelper.isRebuild())
        %>
            }
    <!--    <%
            } //if(isIARRequired)
            
        %> -->
        
            return true;
        
		  } // enf of validateCcoPost()
		  
		  function submitCco() {
		  	var check = <%=(nMode == YPublishConstants.CCO_DELETE)
		        ? "true" : "false"%>;
		    var strMode='<%=nMode%>';
		    var exp=<%=(nMode == YPublishConstants.CCO_POST ||
		                        nMode == YPublishConstants.CCO_REPOST ||
		                        nMode == YPublishConstants.CCO_DELETE ) ? "true" : "false"%>;
		
		    if( exp == 'true') {
		
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
		         alert( "Some of the images do not have an image file.\nPlease contact the build team at buildreq@cisco.com for assistance." );
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
		         alert( 'At least one image should be selected to submit the post' );
		         return false;
		       }
		    }
		    
		    // validate acl list
           var prefixRegex = new RegExp( "^acl_" );
    
           var elems = document.forms['ccoPost'].elements;
           var numElems = elems.length;
           var acllist = '';
           for( e=0; e<numElems; e++ ) {
              var elemName = elems[e].name;
    
              if( prefixRegex.test(elemName) ) {
                 if( elems[e].value == null ) {
                     alert( "ACL list can't be empty." );
                     return false;
                 }
                 if(acllist != '')
                 	acllist += ','
                 acllist += elems[e].value;
              }
           }  // for( e=0; e<numElems; e++ )
           if( acllist != '' ) {
                validateCcoUser(acllist);
                if(anyAclErrors)
                	return false;
           }

            //validate Release Components
            //validate Release Components
            <% if(nMode == YPublishConstants.CCO_POST 
                    || nMode == YPublishConstants.CCO_REPOST) { %>

				//CSCsr29014 - Validate URL. Display error message on Submit. If URLs are invalid release cannot be CCO posted/reposted
				var invalidUrlMessage = isReleaseURLValid();
		        if( invalidUrlMessage != ''){
		        	Ext.MessageBox.alert('Error',' Please enter valid URLs before submission.<br/><br/>' + invalidUrlMessage);
            		return false;
		        }
		        
                var result = getResultString();

                if( result != '' && result.substring(0, 'Error'.length ) == 'Error') {
                    Ext.MessageBox.alert('Error', result.substring('Error!'.length ) );
                    return false;
                } else { 

                    document.forms['ccoPost']._releaseNotesData.value = result;
                    document.forms['ccoPost']._savingonly.value = true;
                    document.forms['ccoPost']._releaseMessage.value = document.getElementById('releaseMessage').value;
                
/*                
                    document.getElementById('_releaseNotesData').value = result;                    
                    document.getElementById('_savingonly').value = false;                      
                    document.getElementById('_releaseMessage').value = document.getElementById('releaseMessage').value;  
*/                    
                }
                    
            <%} %>

		
		    // See if we've already submitted this form.  If so then halt!
		    if( !formSubmitted ) {
		         formSubmitted = true;
		         setImg('btnSubmit1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
		         setImg('btnSubmit2',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>");
		         document.forms['ccoPost'].submit();
		    }  // if( !formSubmitted )
		  } // end of submitCco()
		  
		    <% if(nMode == YPublishConstants.CCO_POST
		    		&& postingTypeId.intValue()!=3){ %>
			    function releaseNoteIsRequired(objLabel, objNote) {
				var isEitherOneEmpty = false;
				var isAtleastOneFilled = false;
				var message = '';
				if (objLabel != null) {
					for(i=0;i<objLabel.length;i++) {
						//If both Label and URL are empty its not an error
						if((trim(objLabel[i].value).length == 0) && (trim(objNote[i].value).length == 0))
							continue;
						else
							isAtleastOneFilled = true;
						
						if (trim(objLabel[i].value).length == 0) {
							message = 'Release Note Label is Required\n';
							isEitherOneEmpty = true;
							isAtleastOneFilled = true;
						}
						
						if(trim(objNote[i].value).length == 0) {
							message = message + 'Release Note URL is Required\n';
							isEitherOneEmpty = true;
							isAtleastOneFilled = true;
						}
						
						if(isEitherOneEmpty)
							return message;
					}
					
					if(!isAtleastOneFilled)
						message = message + 'Release Note Label and URL is Required\n';
				}
				return message;			
			}
		<% } %>	
	</script>		  
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->

<!-- end -->
