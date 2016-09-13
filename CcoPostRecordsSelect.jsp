<!--.........................................................................
: DESCRIPTION:
: CCO Post
:
: AUTHORS:
: @author Ian Slattery (ipslatte@cisco.com)
:
: Copyright (c) 2003-2006, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Vector" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.model.cco.CcoJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.logic.cco.CcoPost" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CcoInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.YPublishConstants"%>

<%
  String thisFile = "CcoPostRecordsSelect.jsp";
  
  Context                     ctx;
  SpritAccessManager          spritAccessManager;
  SpritGlobalInfo             globals;
  SpritGUIBanner              banner;
  String                      jndiName;
  String                      pathGfx;
  Integer                     releaseNumberId = null;;  
  Vector                      ccoRecords = new Vector();
  String                      htmlNoValue = "<span class=\"noData\">---</span>";;
  int                         displayCount = 0;
  String                      osType = null;
  String                      osTypeURL = null;
  String                      osTypeRnmInfo = null;
  String                      releaseNumberString=null;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo      rnmInfo = null;
  ReleaseNumberModelLocal     rnmObj;
  boolean                     isAllowedToPostToCco=false;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );
  CcoInfo ccoInfo;

  try {
   releaseNumberId = new Integer(WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
      // Nothing to do.
  }
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
%>
    <jsp:forward page="ReleaseNoId.jsp" />
<%
  }

  // "osType" is a release attribute that is atored in the DB.
  // However osType "ION" is not stored in the database. If ION is selected on the release selection page
  // we override the osType "IOS" with "ION" using the session attribute.
  try{
     // Set osType based on session attribute IF it exists
    osType = (String) session.getAttribute("osType");
     //  System.out.println("Inside " + thisFile + " osType " + osType );
  }catch( Exception e ) {
    //do nothing
  }
  
  // Get the release info object
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId,osType );
    releaseNumberString = rnmInfo.getFullReleaseNumber();
  } catch( Exception e ) {
    throw e;
  }  // catch  
   
  // First we populate the release info object (rnmInfo) based on the release ID. We now mostly 
  // pass the info object rather that the values. 
  //  
  // ION IMPACT
  // ION creates a unique situation for CCO post. ION has OS Type of IOS as it is an IOS release
  // that posts PATCHES. 
  // ***Currently IOS is not supported for CCO post. Only ION and IOX are supported.
  // If the user selects the ION radio button in the release selection page the user wants to post ION Patches.
  // As the osType for ION is IOS we need to "override" the ostype in the info object
  // by using setOSType in the rnmInfo Object.
  // 1. Standard way :as a request.Attribute - requires user to use the release selection
  // 2. non-stanard: as a URL param. A way of overriding the ostype for ION so a short URL can be  

  //Get the osType as stored in the database
  osTypeRnmInfo  = rnmInfo.getOsType(); //from database
  //System.out.println(thisFile + "  osTypeRnmInfo "+osTypeRnmInfo);
  
  //Get the osType from the URL if it exists
  //******NOTE
  // To access this page as a link for ION the osTypeURL=ION nust be part of the URL
  // e.g. http://servername/sprit/web/jsp/CcoPostRecordsSelect.jsp?releaseNumberId=2088&osTypeURL=ION
  try {
    osTypeURL = new String(WebUtils.getParameter(request,"osTypeURL"));
    //System.out.println(thisFile + " osTypeURL '"+osTypeURL+"'");
  } catch( Exception e ) {
       // Nothing to do.
  }  
  
  //-------------------------
  // If the osType in the database is IOS (and only IOS) then we can overide the osType with ION
  // through the session attribute (osType) or the URL value (osTypeURL)
  // This can be done ONLY if the osType in the database is IOS
  if(osTypeRnmInfo.equalsIgnoreCase("IOS")){
     if( "ION".equalsIgnoreCase(osTypeURL)|| "ION".equalsIgnoreCase(osType)){
       osType = "ION";
       rnmInfo.setOsType("ION");
     }
  }
  
  // If the session attribute osType is not set we must set the osType to the database value
  if((osType == null)){
    osType = osTypeRnmInfo;
    //System.out.println(thisFile + " NULLS = " + osType);
  }  
  //ostype must not be reset after this line
  //System.out.println(thisFile + " isallowed  osType = " + osType);
  if("IOX".equalsIgnoreCase(osType)) {
    isAllowedToPostToCco = spritAccessManager.isAdminHFR();
  }
  else if("ION".equalsIgnoreCase(osType)) {
    isAllowedToPostToCco = spritAccessManager.isAdminION();
  }  
  
  
  
  //System.out.println(thisFile + " isAllowedToPostToCco " + isAllowedToPostToCco);
  
  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
         SpritGUI.renderReleaseNumberNav(globals, releaseNumberString,osType));

  // Submit button setup
  String htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
      globals,
      "btnSubmit1",
      "Submit",
      "javascript:submitCco()",
      pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT,
      "actionBtnSubmit('btnSubmit1')",
      "actionBtnSubmitOver('btnSubmit1')"
      );
%>
  <script language="javascript"> <!--
    // ==========================
    // CUSTOM JAVASCRIPT ROUTINES
    // ==========================
  
    //........................................................................  
    // DESCRIPTION:
    // Changes the up/over images if the form hasn't been submitted.
    //........................................................................  
    function actionBtnSubmit(elemName) {
      if( document.forms['CcoSelectSubmit'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT%>" );
      }  // if
    }
    function actionBtnSubmitOver(elemName) {
      if( document.forms['CcoSelectSubmit'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SUBMIT_OVER%>" );
      }  // if
    }
  
    function submitCco() {  
      var formObj;
      var elements; 
  
      // Make a shortcut to our form's objects.
      formObj = document.forms['CcoSelectSubmit'];
      elements = formObj.elements;   
    
      // See if we've already submitted this form.  If so then halt!
      if( elements['_submitformflag'].value==0 ) {
        // I guess not.  Flag it.  Change the image too.
        elements['_submitformflag'].value=1;
        // setImg( 'btnSubmit1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );

        document.forms['CcoSelectSubmit'].submit();
      }  // if( elements['_submitformflag'].value==0 )
    }  
    -->
  </script>
  <%= SpritGUI.pageHeader( globals,"CCO Post Records Select","" ) %>
  <%= banner.render() %>

  <%
    if(osType.equalsIgnoreCase("IOS")){
      //System.out.println("Inside " + thisFile + " currentView " + "cco" );
      //out.println(SpritReleaseTabs.getTabs(globals, "cco"));    
    } else {
      //System.out.println("Inside " + thisFile + " currentView " + "cco" );
      out.println( SpritReleaseTabs.getNonIosTabs(globals, "cco"));       

    }
%>
  <%
    // See if there were any messages generated
    String servletMessages = (String) request.getAttribute( "errorMessage" );

if("ION".equalsIgnoreCase(osType)) {
     /***
      out.println(SpritGUI.renderTabContextNav(
              globals,navBar.render(
              true,
              false, 
              "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId,
              "CcoServicePackPostSelect.jsp?releaseNumberId=" + releaseNumberId,
              "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId)));
    ****/
   if (spritAccessManager.isAdminION() ) {
    String strMode = request.getParameter("mode");
    if(strMode == null) {
         	strMode="SPPost";
     }
  
    out.println( SpritGUI.renderTabContextNav( globals,
                	navBar.render(
                		new boolean [] { 
                		   (strMode.equals("View")) ? false : true,
				   (strMode.equals("SPPost")) ? false : true,
				   (strMode.equals("Report")) ? false : true,
                                   (strMode.equals("PatchPost")) ? false : true,
                		},
                		new String [] { "View", "Post Maintenance Pack", "Report", "Post Patch" },
                		new String [] { "CcoPostStatusView.jsp?mode=View&releaseNumberId=" + releaseNumberId,
                  		            "CcoServicePackPostSelect.jsp?mode=SPPost&releaseNumberId=" + releaseNumberId,
                  		            "CcoPostStatusView.jsp?mode=Report&releaseNumberId=" + releaseNumberId,
                  		            "CcoPostRecordsSelect.jsp?mode=PatchPost&releaseNumberId=" + releaseNumberId}
                		        ) ) );
   } else {
           out.println(SpritGUI.renderTabContextNav(
   	              globals,navBar.render(
   	              isAllowedToPostToCco,
   	              false, 
   	              "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId,
   	              "CcoServicePackPostSelect.jsp?releaseNumberId=" + releaseNumberId,
                      "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId)));

   }
  

  } else {
	// osType is IOX
	out.println(SpritGUI.renderTabContextNav(
	        globals,navBar.render(
	        isAllowedToPostToCco,
	        true, 
	        "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId,
	        "CcoPostRecordsSelect.jsp?releaseNumberId=" + releaseNumberId,
        "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId)));
  }  
  
  

  boolean anyDup = false;
 
  if( servletMessages != null ) {
%>
        <br/>
        <%=servletMessages%>
        <br/><br/>
<%
  }  // if( servletMessages!=null )

 if ("ION".equalsIgnoreCase(osType))
 {
	response.sendRedirect("CsprIonCcoView.jsp?mode=" +
                    YPublishConstants.ION_VIEW + "&releaseNumberId=" +
                        releaseNumberId);

 }else if ("IOX".equalsIgnoreCase(osType)){

		response.sendRedirect("CsprIoxCcoView.jsp?mode=" +
                    YPublishConstants.IOX_VIEW + "&releaseNumberId=" +
						releaseNumberId);
 } 

%>
<!--
   <br><br><br><center>
   <table border="0" cellpadding="0" cellspacing="0">
   <tr>
   <td bgcolor="#3D127B">
      <table border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td bgcolor="#BBD1ED">
        <table cellspacing="0" cellpadding="3" border="1">
         <tr>
          <td align="center"><span class="dataTableData"><font size="2">
          <b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CCO Post Selection - Select records to Post
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></font></span></td>
         </tr>
        </table>
      </td>
      </tr>
      </table>
    </td>
    </tr>
    </table>
    <br></center>


 <form action="CcoPostConfirm.jsp" method="post" name="CcoSelectSubmit" >
 <input type="hidden" name="_submitformflag" value="0" />

 <center>
   <table border="0" cellpadding="1" cellspacing="0">
   <tr>
   <td bgcolor="#3D127B">
      <table border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td bgcolor="#BBD1ED">
 
    <table cellspacing="0" cellpadding="3" border="1">
     <tr bgcolor="#d9d9d9">
          <td class="tableCell" align="center" valign="top"><span class="dataTableTitle">
          Select<br />
          <a href="javascript:checkboxSelectAll('CcoSelectSubmit','_select')"><img src="../gfx/btn_all_mini.gif" border="0" /></a><br />
          <a href="javascript:checkboxSelectNone('CcoSelectSubmit','_select')"><img src="../gfx/btn_none_mini.gif" border="0" /></a><br />
              </span>
          </td>
          <td align="center"><span class="dataTableTitle">Build Number</span></td>
          <td align="center"><span class="dataTableTitle">Image Name</font></span></td>          
          <td align="center"><span class="dataTableTitle">CCO Dir</span></td>
          <td align="center"><span class="dataTableTitle">Description</span></td> 
     </tr>
    <%
        Iterator iter = ccoRecords.iterator();
         String ptsURLKey = globals.gs("envMode") + "PTS"; 
         String ptsURL = SpritInitializeGlobals.getInstance().getEnvProperty(ptsURLKey);

        int imageTotal = ccoRecords.size();
	
   
   while( iter.hasNext() ) {
     ccoInfo = (CcoInfo) iter.next();
     if (ccoInfo.getIsPostedToCco().equals("Y") ) {
       continue;
     }else{
       displayCount++;
     }
     %>   
   
    <tr bgcolor="#ffffff">  
      <input type="Hidden" name="<%="_"+displayCount+"SeqId"%>" value="<%= ccoInfo.getSeqId() %>" />
      <td align="center" valign="top" class="tableCell"><span class="dataTableData"><input type="checkbox" value='Y' name="<%="_"+displayCount+"_select"%>" /></span></td>
      <td valign="top" align="left"><span class="dataTableData"><font size="1"><%= ccoInfo.getBuildNumber()%></font></span></td>      
      <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1"><%= ccoInfo.getImageName()  %></font></nobr></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"ImageName"%>" value="<%= ccoInfo.getImageName() %>" />
      <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1">
      <a href="<%=ptsURL%><%=ccoInfo.getCcoDir()%>" target="_blank"><%= ccoInfo.getCcoDir()  %></a> </font></nobr></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"CcoDir"%>" value="<%= ccoInfo.getCcoDir() %>" />
      <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1"><%= StringUtils.nvl(ccoInfo.getDescription(),htmlNoValue) %></font></nobr></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"Description"%>" value="<%= ccoInfo.getDescription() %>" />
      
      <input type="Hidden" name="<%="_"+displayCount+"PackageName"%>" value="<%= ccoInfo.getPackageName() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"ImageType"%>" value="<%= ccoInfo.getType() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"IsPostedToCco"%>" value="<%= ccoInfo.getIsPostedToCco() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"Encryption"%>" value="<%= ccoInfo.getEncryption() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"Crypto"%>" value="<%= ccoInfo.getIsCrypto()%>" />
      <input type="Hidden" name="<%="_"+displayCount+"BuildNumber"%>" value="<%= ccoInfo.getBuildNumber() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"ReleaseNumberId"%>" value="<%= ccoInfo.getReleaseNumberId() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"SrcLocation"%>" value="<%= ccoInfo.getSrcLocation() %>" />
     </tr>
<%
    }  // while( iter.hasNext() 
%>
 <input type="Hidden" name="<%="totalImagesToPost"%>" value="<%= displayCount %>" />
 <input type="Hidden" name="<%="releaseNumberId"%>" value="<%= releaseNumberId %>" />
    
</table></td></tr></table></td></tr></table>
<br/>
<br/><br/>
<%

    
  if(isAllowedToPostToCco) {
     if( !anyDup && (displayCount > 0) ) {
%>
            <%= htmlButtonSubmit1 %>
<%        } else {
%>
             <center><br><br><br>
                   <table cellspacing="0" cellpadding="3" border="1">
                     <tr bgcolor="#d9d9d9">
                       <td align="center"><span class="dataTableData">
                          There are no records available to post to CCO for this release - 
                            <%=releaseNumberString%></span></td>                        
                     </tr>
                     <tr bgcolor="#d9d9d9">
                       <td align="center"><span class="dataTableData">
                         If you need to Resubmit Records to CCO, please open a case at <a href="<%=SpritConstants.SRM_CASE_OPEN_LINK%>" target=\"_blank\"><%=SpritConstants.SRM_CASE_OPEN_LINK%></a></td>                        
                     </tr>
                   </table>
                  </center>
<%
            
         }
      } else {
%>
        <center>
            <table cellspacing="0" cellpadding="0" border="0">
             <tr bgcolor="#d9d9d9">
              <td align="center"><span class="dataTableData"><font size="2"><b>
               You don't have permission to Post to CCO</b></font></span></td>
             </tr>
            </table>
            </center>
<%
      }
%>
<br/><br/>
</center>
</form>

	  <center><br><br><br>
        <table cellspacing="0" cellpadding="3" border="1">
         <tr bgcolor="#d9d9d9">
         <td align="center"><span class="dataTableData">
         There are no records POSTED or Otherwise available to post to CCO for this release - 
         <%=releaseNumberString%></span></td>                        
         </tr>
         <tr bgcolor="#d9d9d9">
         <td align="center"><span class="dataTableData">
           If you need to Resubmit Records to CCO, please open a case at <a href="<%=SpritConstants.SRM_CASE_OPEN_LINK%>" target=\"_blank\"><%=SpritConstants.SRM_CASE_OPEN_LINK%></a></td>                        
         </tr>
        </table>
      </center>
<%= Footer.pageFooter(globals) %>
<!-- end -->
