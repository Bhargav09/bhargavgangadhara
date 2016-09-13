<!--.........................................................................
: DESCRIPTION:
: CCO Post
:
: AUTHORS:
: @author Ian Slattery (ipslatte@cisco.com)
:
: Copyright (c) 2003-2005, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="java.util.Properties" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.model.cco.CcoJdbc" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.ReleaseNumberFormat" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CcoInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>

<%
  String thisFile = "CcoPostConfirm.jsp";
  
  Context                     ctx;
  SpritAccessManager          spritAccessManager;
  SpritGlobalInfo             globals;
  SpritGUIBanner              banner;
  String                      jndiName;
  String                      pathGfx;
  Integer                     releaseNumberId = null;  
  Vector                      ccoRecords = new Vector();
  String                      htmlNoValue;
  int                         displayCount = 0;
  String                      osType = null;
  String                      releaseNumberString = null;
  ReleaseNumberModelInfo      rnmInfo = null;
  Vector                      vccoPostRecords = new Vector();
  int totalImagesToPost = Integer.parseInt(request.getParameter("totalImagesToPost"));
  boolean                     isAllowedToPostToCco=false;
  String                     patchType = request.getParameter("patch_type");
  
  //System.out.println(thisFile + " " +  totalImagesToPost);
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );    
  CcoInfo ccoInfo;
  //html macros
  htmlNoValue = "<span class=\"noData\">---</span>";
  //get release info from the session attribute 
  rnmInfo = (ReleaseNumberModelInfo) session.getAttribute("rnmInfo");
   
  System.out.println(thisFile + " rnmInfo  " + rnmInfo);
  osType              = rnmInfo.getOsType();
  releaseNumberString = rnmInfo.getFullReleaseNumber();
  releaseNumberId     = rnmInfo.getReleaseNumberId(); 
 
 if("IOX".equalsIgnoreCase(osType)) {
   isAllowedToPostToCco= spritAccessManager.isAdminHFR();
 }
 else if("ION".equalsIgnoreCase(osType)) {
   isAllowedToPostToCco= spritAccessManager.isAdminION();
   
 }
  
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
%>
    <jsp:forward page="ReleaseNoId.jsp" />
<%
  }
    
  // Need to pass only those records which have been selected and not the entire 
  // list of possible records.
   
   for(int displayRecord=1; displayRecord <= totalImagesToPost; displayRecord++)
   {
           //collecting the parameternames and values
           String paramSeqId                = "_"+displayRecord+"SeqId";
           String paramIsChecked            = "_"+displayRecord+"_select";
           String paramImageName            = "_"+displayRecord+"ImageName";
           String paramCcoDir               = "_"+displayRecord+"CcoDir";
           String paramDescription          = "_"+displayRecord+"Description";
           String paramSrcLocation          = "_"+displayRecord+"SrcLocation";
           String paramPackageName          = "_"+displayRecord+"PackageName";
           String paramIsPostedToCco        = "_"+displayRecord+"IsPostedToCco";
           String paramCcoPostTime          = "_"+displayRecord+"CcoPostTime";
           String paramEncryption           = "_"+displayRecord+"Encryption";
           String paramCrypto               = "_"+displayRecord+"Crypto";
           String paramImageType            = "_"+displayRecord+"ImageType";
           String paramBuildNumber          = "_"+displayRecord+"BuildNumber";
           String paramReleaseNumberId      = "_"+displayRecord+"ReleaseNumberId";
           String paramPlatformId    	    = "_"+displayRecord+"PlatformId";
 
   
          if ((request.getParameter(paramIsChecked))!=null) {
            // Create new holding record.
            ccoInfo = new CcoInfo();
           // Populate holding record.
            ccoInfo.setSeqId(new Integer (request.getParameter(paramSeqId)));
            ccoInfo.setImageName(request.getParameter(paramImageName));
            ccoInfo.setCcoDir(request.getParameter(paramCcoDir));
            ccoInfo.setDescription(request.getParameter(paramDescription));
            ccoInfo.setSrcLocation(request.getParameter(paramSrcLocation));
            ccoInfo.setPackageName(request.getParameter(paramPackageName));
            ccoInfo.setIsPostedToCco(request.getParameter(paramIsPostedToCco));
            //ccoInfo.setCcoPostTime(request.getParameter(paramCcoPostTime));
            ccoInfo.setEncryption(request.getParameter(paramEncryption));
            ccoInfo.setIsCrypto( ( "true".equalsIgnoreCase(
                    request.getParameter(paramCrypto))) ? true : false);
            ccoInfo.setType(request.getParameter(paramImageType));
            ccoInfo.setBuildNumber(request.getParameter(paramBuildNumber));
            ccoInfo.setReleaseNumberId(new Integer(request.getParameter(paramReleaseNumberId)));
            ccoInfo.setPlatform(request.getParameter(paramPlatformId));
   
            vccoPostRecords.add( (Object) ccoInfo );
          }
       }//end of for loop displayCount=0      
   
 // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
        SpritGUI.renderReleaseNumberNav(globals,releaseNumberString,osType)); 
  
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
  // Changes the up/over images if the form hasnot been submitted.
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
<%= SpritGUI.pageHeader( globals,"CCO Post Confirm","" ) %>
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
             	strMode="SPPost";
     }
   if (spritAccessManager.isAdminION() ) {
      
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
	        isAllowedToPostToCco,
	        true, 
	        "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId,
	        "CcoPostRecordsSelect.jsp?releaseNumberId=" + releaseNumberId,
                "CcoPostStatusView.jsp?releaseNumberId=" + releaseNumberId)));
  }  
    
  boolean anyError = false;
  boolean anyDup = false;
  if( servletMessages != null ) {
%>
        <br/>
        <%=servletMessages%>
        <br/><br/>
<%
    anyError = true;
  }  // if( servletMessages!=null )
%>
 <%

   	try {
		if ( patchType != null && patchType.equalsIgnoreCase("SP") &&  vccoPostRecords.size() != 0 ) {
   			vccoPostRecords = CcoJdbc.getIONPatchesAndServicePacksToPost(vccoPostRecords, rnmInfo);
	  		System.out.println(" vccoPostRecords = " +vccoPostRecords );
		}
  	 } catch ( Exception e ) {
		e.printStackTrace();
		//out.println("<b bgColor=\"#ff0000\"> ERROR: " + e.getMessage() );
		out.println(SpritGUI.renderErrorBox(globals, "ERROR!!!", e.getMessage() ));
		anyError = true;
		out.println( Footer.pageFooter(globals));
		return;
		//throw e;
  	}

   session.setAttribute("CcoReport", vccoPostRecords); 
   session.setAttribute("rnmInfo", rnmInfo );
   
   System.out.println( "DEBUG " + thisFile + " anyError " + anyError + " " + releaseNumberId + " size " + vccoPostRecords.size() );
 if( !anyError && vccoPostRecords !=null && vccoPostRecords.size() != 0 ) {

 %>
   <br><br><br><center>
   <table border="0" cellpadding="0" cellspacing="0">
   <tr>
   <td bgcolor="#3D127B">
      <table border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td bgcolor="#BBD1ED">
        <table cellspacing="0" cellpadding="3" border="1">
         <tr>
          <td align="center"><span class="dataTableData"><font size="2"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CCO Post Selection - Confirm records to post
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


 <form action="CcoProcessor" method="post" name="CcoSelectSubmit" >
 <input type="hidden" name="_submitformflag" value="0" />
 <input type="hidden" name="patch_type" value="<%=patchType%>" />
 <center>
    <table border="0" cellpadding="1" cellspacing="0">
    <tr>
    <td bgcolor="#3D127B">
       <table border="0" cellpadding="0" cellspacing="0">
       <tr>
       <td bgcolor="#BBD1ED">

<% 
 if ( patchType != null && patchType.equalsIgnoreCase("SP")	)
{ 
%>
   <br> The following service packs along with the required service packs or patches will be posted to CCO. Please confirm <br>
     <table cellspacing="0" cellpadding="3" border="1">
      <tr bgcolor="#d9d9d9">
           <td align="center"><span class="dataTableTitle">Build Number</span></td>
           <td align="center"><span class="dataTableTitle">Service Pack Name</font></span></td>          
           <td align="center"><span class="dataTableTitle">Service Pack / Patch Id</span></td>
           <td align="center"><span class="dataTableTitle">Description</span></td> 
     </tr>
<%
   }
   else {
%>
   <table cellspacing="0" cellpadding="3" border="1">
         <tr bgcolor="#d9d9d9">
              <td align="center"><span class="dataTableTitle">Build Number</span></td>
              <td align="center"><span class="dataTableTitle">Image Name</font></span></td>          
              <td align="center"><span class="dataTableTitle">CCO Dir</span></td>
              <td align="center"><span class="dataTableTitle">Description</span></td> 
     </tr>

<% 
   } 
%>


<%
     Iterator iter = vccoPostRecords.iterator(); // records that are to post
         
     int imageTotal = ccoRecords.size();     
     while( iter.hasNext() ) {
      ccoInfo = (CcoInfo) iter.next();
      displayCount++;
%>   
    
     <tr bgcolor="#ffffff">  
       <input type="Hidden" name="<%="_"+displayCount+"SeqId"%>" value="<%= ccoInfo.getSeqId() %>" />
       
       <td valign="top" align="left"><span class="dataTableData"><font size="1"><%= ccoInfo.getBuildNumber() %></font></span></td>       

       <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1"><%= ccoInfo.getImageName()  %></font></nobr></span></td>
       <input type="Hidden" name="<%="_"+displayCount+"ImageName"%>" value="<%= ccoInfo.getImageName() %>" />
       
       <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1"><%= ccoInfo.getCcoDir()  %></font></nobr></span></td>
       <input type="Hidden" name="<%="_"+displayCount+"CcoDir"%>" value="<%= ccoInfo.getCcoDir() %>" />
       <td valign="top" align="left"><span class="dataTableData"><nobr><font size="1"><%= StringUtils.nvl(ccoInfo.getDescription(),htmlNoValue) %></font></nobr></span></td>
       <input type="Hidden" name="<%="_"+displayCount+"Description"%>" value="<%= ccoInfo.getDescription() %>" />
       
       <input type="Hidden" name="<%="_"+displayCount+"SrcLocation"%>" value="<%= ccoInfo.getSrcLocation() %>" />
       <input type="Hidden" name="<%="_"+displayCount+"PackageName"%>" value="<%= ccoInfo.getPackageName() %>" />
       <input type="Hidden" name="<%="_"+displayCount+"ImageType"%>" value="<%= ccoInfo.getType() %>" />
       <input type="Hidden" name="<%="_"+displayCount+"Encryption"%>" value="<%= ccoInfo.getEncryption() %>" />
       <input type="Hidden" name="<%="_"+displayCount+"BuildNumber"%>" value="<%= ccoInfo.getBuildNumber() %>" />
       <input type="Hidden" name="<%="_"+displayCount+"ReleaseNumberId"%>" value="<%= ccoInfo.getReleaseNumberId() %>" />
       <input type="Hidden" name="<%="_"+displayCount+"PlatformId"%>" value="<%= ccoInfo.getPlatform() %>" />
       
              
       <input type="Hidden" name="<%="totalImagesToPost"%>" value="<%= displayCount %>" />
       <input type="Hidden" name="<%="releaseNumberString"%>" value="<%= releaseNumberString %>" />
       <input type="Hidden" name="<%="releaseNumberId"%>" value="<%= releaseNumberId %>" />
       <input type="Hidden" name="<%="osType"%>" value="<%= osType %>" />       
     </tr>
     <%
     }  // while( iter.hasNext() )
     
     
     
     %>
 </table></td></tr></table></td></tr></table>
 <br/>
 <br/><br/>
 <%
   
//  if(isAllowedToPostToCco) {
if(true){
       if(displayCount > 0) {
 %>
             <%= htmlButtonSubmit1 %>
 <%      } else {
 %>
              <center><br><br><br>
                    <table cellspacing="0" cellpadding="3" border="1">
                      <tr bgcolor="#d9d9d9">
                        <td align="center"><span class="dataTableData">
                           No records were selected to post to CCO for this release - 
                             <%=releaseNumberString%></span></td>                        
                      </tr>
                      <tr bgcolor="#d9d9d9">
                        <td align="center"><span class="dataTableData">
                          Please hit the back button and select records to Post</td>                        
                      </tr>
                    </table>
                   </center>
 <%
             
         }
     } // isAllowedToPostToCco
     else {
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
   } // else if( spritAccessManager.isMilestoneOwner(r
 %>
 <br/><br/>
</center>

</form>
 <%
    }// if( !anyError && vccoPostRecords.size() != 0 )  
    else {        
%>
              <center><br><br><br>
                    <table cellspacing="0" cellpadding="3" border="1">
                      <tr bgcolor="#d9d9d9">
                        <td align="center"><span class="dataTableData">
                        No records were selected to post to CCO for this release - 
                        <%=releaseNumberString%></span></td>                        
                      </tr>
                      <tr bgcolor="#d9d9d9">
                        <td align="center"><span class="dataTableData">
                          Please hit the back button and select records to Post</td>                        
                      </tr>
                    </table>
                   </center>
 <%

        }//else if( !anyError && vccoPostRecords.size() != 0 ) 
    
 %>
<%= Footer.pageFooter(globals) %>
<!-- end -->
