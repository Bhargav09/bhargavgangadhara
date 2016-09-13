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
<%@ page import="java.util.*" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.model.cco.CcoJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
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
  String thisFile = "CcoPostStstusView.jsp";
  
  Context                     ctx;
  SpritAccessManager          spritAccessManager;
  SpritGlobalInfo             globals;
  SpritGUIBanner              banner;
  String                      jndiName;
  String                      pathGfx;
  Integer                     releaseNumberId = null;;  
  Vector                      ccoRecords = new Vector();
  String                      htmlNoValue;
  int                         displayCount = 0;
  String                      osType = null;
  String                      osTypeURL = null;
  String                      osTypeRnmInfo = null;
  String                      releaseNumberString=null;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo      rnmInfo = null;
  ReleaseNumberModelLocal     rnmObj;
  
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );
  CcoInfo ccoInfo;
  //html macros
  htmlNoValue = "<span class=\"noData\">---</span>";
  

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


  osType = (String) session.getAttribute("osType");
     
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
   
  
  // See notes in CcoPostRecordsSelect.jsp regarding ION 
  osTypeRnmInfo  = rnmInfo.getOsType(); //from database
//  System.out.println(thisFile + " osTypeRnmInfo "+osTypeRnmInfo);
  
  try {
    osTypeURL = new String(WebUtils.getParameter(request,"osTypeURL"));
    //System.out.println("Inside CCOPostRecordselect.jsp  osTypeURL "+osTypeURL);
  } catch( Exception e ) {
       // Nothing to do.
  }
  if(osTypeRnmInfo.equalsIgnoreCase("IOS"))
  {
     if( osTypeURL.equalsIgnoreCase("ION")|| osType.equalsIgnoreCase("ION")){
       osType = "ION";
       rnmInfo.setOsType("ION");
    }
  }
  
  
  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
         SpritGUI.renderReleaseNumberNav(globals,releaseNumberString,osType));
  
%>
  <script language="javascript"> <!--
    // ==========================
    // CUSTOM JAVASCRIPT ROUTINES
    // ==========================
  
    //........................................................................  
    // DESCRIPTION:
    // Changes the up/over images if the form hasn't been submitted.
    //........................................................................  
    function actionBtnSaveUpdates(elemName) {
      if( document.forms['CcoSelectSubmit'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
      }  // if
    }
    function actionBtnSaveUpdatesOver(elemName) {
      if( document.forms['CcoSelectSubmit'].elements['_submitformflag'].value==0 ) {
        setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
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
        // setImg( 'btnSaveUpdates1',"<%=pathGfx + "/" + SpritConstants.GFX_PLEASE_WAIT_108x32%>" );

        document.forms['CcoSelectSubmit'].submit();
      }  // if( elements['_submitformflag'].value==0 )
    }  
    -->
  </script>
  <%= SpritGUI.pageHeader( globals,"Market Matrix","" ) %>
  <%= banner.render() %>

  <%= SpritReleaseTabs.getNonIosTabs(globals, "cco") %>
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
    String strMode = request.getParameter("mode");
         if(strMode == null) {
         	strMode="View";
     }
   if (spritAccessManager.isAdminION() ) {
     
     
  
    out.println( SpritGUI.renderTabContextNav( globals,
                	navBar.render(
                		new boolean [] { 
                		   (strMode.equals("View")) ? false : true,
				   (strMode.equals("SPPost") ) ? false : true,
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
                       out.println( SpritGUI.renderTabContextNav( globals,
	                             	navBar.render(
	                             		new boolean [] { 
	                             		   (strMode.equals("View")) ? false : true,
	             				   (strMode.equals("SPPost")) ? false : true,
	             				   (strMode.equals("Report")) ? false : true,
	                                            
	                             		},
	                             		new String [] { "View", "Post Maintenance Pack", "Report" },
	                             		new String [] {
	                             		            "CcoPostStatusView.jsp?mode=View&releaseNumberId=" + releaseNumberId,
	                               		            "CcoServicePackPostSelect.jsp?mode=SPPost&releaseNumberId=" + releaseNumberId,
	                               		            "CcoPostStatusView.jsp?mode=Report&releaseNumberId=" + releaseNumberId,
	  						    }
                             		             ) ) );

   }
  

  } else {
	// osType is IOX
	out.println(SpritGUI.renderTabContextNav(
	              globals,navBar.render(
	              true,
	              false, 
	              "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId,
	              "CcoPostRecordsSelect.jsp?releaseNumberId=" + releaseNumberId,
                      "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId)));
  }
 
  //System.out.println(" 4 Inside CCOPostRecordselect.jsp  GUI");
  if( servletMessages != null ) {
%>
        <br/>
        <%=servletMessages%>
        <br/><br/>
<%
  }  // if( servletMessages!=null )
%>
 <%
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

   <!-- <br><br><br><center>
   <table border="0" cellpadding="0" cellspacing="0">
   <tr>
   <td bgcolor="#3D127B">
      <table border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td bgcolor="#BBD1ED">
        <table cellspacing="0" cellpadding="3" border="1">
         <tr>
          <td align="center"><span class="dataTableData"><font size="2">
          <b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CCO Post Status View
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
          <td align="center"><span class="dataTableTitle">Build Number</span></td>
          <td align="center"><span class="dataTableTitle">Image Name</font></span></td>          
          <td align="center"><span class="dataTableTitle">CCO Dir</span></td>
          <td align="center"><span class="dataTableTitle">Description</span></td> 
          <td align="center"><span class="dataTableTitle">Type</span></td>          
          <td align="center"><span class="dataTableTitle">Posted</span></td>
          <td align="center"><span class="dataTableTitle">CCO Post Time</span></td>
          <td align="center"><span class="dataTableTitle">Encrypt Value</span></td>
     </tr>
    <%
        Iterator iter = ccoRecords.iterator();
        
        int imageTotal = ccoRecords.size();
        String ptsURLKey = globals.gs("envMode") + "PTS"; 
        String ptsURL = SpritInitializeGlobals.getInstance().getEnvProperty(ptsURLKey);

   
     while( iter.hasNext() ) {
       ccoInfo = (CcoInfo) iter.next();
       displayCount++;
       String ccoPostDateString =  ccoInfo.getCcoPostTimeAsString();
    %>   
   
    <tr bgcolor="#ffffff">  
      <input type="Hidden" name="<%="_"+displayCount+"SeqId"%>" value="<%= ccoInfo.getSeqId() %>" />
      <td valign="top" align="left"><span class="dataTableData"><font size="1"><%= ccoInfo.getBuildNumber() %></font></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"BuildNumber"%>" value="<%= ccoInfo.getBuildNumber() %>" />      
      
      <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1"><%= ccoInfo.getImageName()  %></font></nobr></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"ImageName"%>" value="<%= ccoInfo.getImageName() %>" />
      
      <td valign="top" align="left"><span class="dataTableData"><nobr>
      			<font size="1">
      			<a href="<%=ptsURL%><%=ccoInfo.getCcoDir()%>" target="_blank"><%= ccoInfo.getCcoDir()  %></a>
      			</font> </nobr></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"CcoDir"%>" value="<%= ccoInfo.getCcoDir() %>" />
      
      
      <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1">
              <%= StringUtils.nvl(ccoInfo.getDescription(),htmlNoValue) %></font></nobr></span></td>
      <input type="Hidden" name="<%="_"+displayCount+"Description"%>" value="<%= ccoInfo.getDescription() %>" />
      
      
      <td valign="top" align="center"><span class="dataTableData"><nobr><font size="1">
              <%= StringUtils.nvl(ccoInfo.getType(),htmlNoValue) %></font></nobr></span></td>      
            
      <input type="Hidden" name="<%="_"+displayCount+"PackageName"%>" value="<%= ccoInfo.getPackageName() %>" />
      <input type="Hidden" name="<%="_"+displayCount+"ImageType"%>" value="<%= ccoInfo.getType() %>" />
      
      
      
      <td valign="top" align="center"><span class="dataTableData"><nobr><font size="1">
                    <%= StringUtils.nvl(ccoInfo.getIsPostedToCco(),htmlNoValue) %></font></nobr></span></td>      
      
      <input type="Hidden" name="<%="_"+displayCount+"IsPostedToCco"%>" value="<%= StringUtils.nvl(ccoInfo.getIsPostedToCco(),htmlNoValue) %>" />
       
      <td valign="top" align="center"><span class="dataTableData"><nobr><font size="1">
              <%= StringUtils.nvl(ccoPostDateString,htmlNoValue) %></font></nobr></span></td>   
      
      
      <td valign="top" align="center"><span class="dataTableData"><nobr><font size="1">
              <%= StringUtils.nvl(ccoInfo.getEncryption(),htmlNoValue) %></font></nobr></span></td> 
      
       <input type="Hidden" name="<%="_"+displayCount+"Encryption"%>" value="<%= ccoInfo.getEncryption() %>" />       
       <input type="Hidden" name="<%="_"+displayCount+"Crypto"%>" value="<%= ccoInfo.getIsCrypto()%>" />       

       <input type="Hidden" name="<%="_"+displayCount+"ReleaseNumberId"%>" value="<%= ccoInfo.getReleaseNumberId() %>" />
       
    </tr>
    <%
    }  // while( iter.hasNext() )
    
    
    
    %>
       <input type="Hidden" name="<%="totalImagesToPost"%>" value="<%= displayCount %>" />    
       <input type="Hidden" name="<%="osType"%>" value="<%= osType %>" />
</table></td></tr></table></td></tr></table>
<br/>
<br/><br/>

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
 <%
 %>
<%= Footer.pageFooter(globals) %>
<!-- end -->
