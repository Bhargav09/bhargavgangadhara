<!--.........................................................................
: DESCRIPTION:
: Image List Report page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2002-2006 by Cisco Systems, Inc. All rights reserved.
:.........................................................................-->

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.dataobject.*" %>
<%@ page import="com.cisco.eit.sprit.logic.imagelist.*" %>
<%@ page import="com.cisco.eit.sprit.model.imagetype.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>
<%@ page import="com.cisco.eit.sprit.ui.ImageListGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.util.ImageDbUtil" %>

<jsp:useBean id="sortBean" scope="session" class="com.cisco.eit.sprit.util.ImageListSortAsc">
</jsp:useBean>
<% //Getting the filters and values
 // Get Platform, Image Filters.
  String platformFilter = null;
  String imageFilter = null;
  try {
    platformFilter = WebUtils.getParameter(request,"PlatformFilter");
    imageFilter = WebUtils.getParameter(request,"ImageFilter");
  } catch( Exception e ) {
    // Nothing to do.
  }

    MonitorUtil monUtil = new MonitorUtil();
        monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Image List Report");

  if( platformFilter==null ) {
    // No platformFilter!  Default it to *
    platformFilter = "*";

  }
  if( imageFilter==null ) {
    // No imageFilter!  Default it to *
    imageFilter = "*";
  }

  Context ctx;

  Integer releaseNumberId;
  ReleaseNumberModelHomeLocal rnmHome;
  ReleaseNumberModelInfo rnmInfo;
  ReleaseNumberModelLocal rnmObj;
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
//  String ImageFilter = "*";
  String jndiName;
//  String pathGfx;
//  String PlatformFilter = "*";
  String releaseNumber = null;
  Integer postingTypeId = new Integer(0);
  response.setContentType("application/vnd.ms-excel");

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
//  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );

  // Get release number ID.  Try to convert it to an Integer from the web value!
  releaseNumberId = null;
  try {
    releaseNumberId = new Integer(
        WebUtils.getParameter(request,"releaseNumberId"));
  } catch( Exception e ) {
    // Nothing to do.
  }
  if( releaseNumberId==null ) {
    // No release number!  Bad!  Redirect to error page.
    %>
      <jsp:forward page="ReleaseNoId.jsp" />
    <%
  }


  rnmInfo = null;
  try {
    // Setup
    jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    ctx = new InitialContext();
    rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    rnmObj = rnmHome.create();
    rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    releaseNumber = rnmInfo.getFullReleaseNumber();
    postingTypeId = rnmInfo.getPostingTypeId();
  } catch( Exception e ) {
    throw e;
  }  // catch

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,releaseNumber )
      );
%>

<%
 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
 //----------------------------------------------------------------
 HashMap imageId2IssuStateInfoHash  = null;
 Vector  issuStateVect              = null;
 String  issuState                  = null;
 String  fontTagOpen                = null;
 String  fontTagClose               = null;
 Vector  issuStateDispHighlightVect = new Vector();
 boolean foundIssuImage             = false;  //will be used for adoption rate

 issuStateDispHighlightVect.addElement("ISSU_OFF");
 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 11/07/2006  nadialee: END
 //----------------------------------------------------------------
%>



<%

String releaseId =request.getParameter("releaseNumberId");
Iterator ImageListInfoVector = null;
Collection ImageListCollection = null;
ImageListSessionHome mImageListSessionHome = null;
ImageListSession mImageListSession = null;
ImageListInfo mImageListInfo = null;

try
{
    Context cntx = JNDIContext.getInitialContext();
        Object homeObject = cntx.lookup("ImageListSessionBean.ImageListSessionHome");
        mImageListSessionHome = (ImageListSessionHome)PortableRemoteObject.narrow(homeObject, ImageListSessionHome.class);
        mImageListSession = mImageListSessionHome.create();
}
catch(Exception e)
{
    System.out.println("in platform create block");
    e.printStackTrace();
 }

 try
 {
 ImageListCollection = mImageListSession.getAllImageListInfoUtil(new Integer(releaseId));
 //mImageListSession.getAllImageListInfo(new Integer(releaseId)).iterator();
 //imageListInfoVector = mImageListSession.getAllImageListInfoUtil(new Integer(releaseId)).iterator();

      //----------------------------------------------------------------
      // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
      //----------------------------------------------------------------
      if( "IOS".equals(rnmInfo.getOsType()) ) {
          imageId2IssuStateInfoHash = mImageListSession.getAllImageListIssuState(new Integer(releaseId));
      }
      //----------------------------------------------------------------
      // SPRIT-ISSU. Added 11/07/2006 nadialee: END
      //----------------------------------------------------------------

 } catch(Exception e)
 {
    System.out.println("in platform get block");
    e.printStackTrace();
 }

if ((request.getParameter("ImageFilter") != null) ||(request.getParameter("PlatformFilter") != null)){
if((!request.getParameter("ImageFilter").equals("*")) || (!request.getParameter("PlatformFilter").equals("*"))) {
ImageListCollection = ImageListGUI.htmlFilter(request.getParameter("ImageFilter"),
                      request.getParameter("PlatformFilter"),
                      ImageListCollection);
}
}
%>

<center>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1">
    <tr>
    <td align="center" valign="top">
      ImageName
    </td>
    <td align="center" valign="top">
      Platform
    </td>
    <td align="center" valign="top">
      Min Flash
    </td>
    <td align="center" valign="top">
      Min Dram
    </td>
    <td align="center" valign="top">
      CCO
    </td>
    <td align="center" valign="top">
      Deferral
    </td>
    <td align="center" valign="top">
      SoftwareA
    </td>
    <td align="center" valign="top">
      Type
    </td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay START -->
    <td align="center" valign="top">
      Licensed
    </td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
    <td align="center" valign="top">
      Test
    </td>
     <!--  6.9 CSCsj91893 -->        
    <% if("IOS".equals(rnmInfo.getOsType()) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>        
    <td align="center" valign="top">
      Posting Type
    </td>
    <%} %>
<%
//----------------------------------------------------------------
// SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
//----------------------------------------------------------------
if( "IOS".equals(rnmInfo.getOsType()) ) {
%>
    <td align="center" valign="top">
      ISSU State
    </td>
<%
}
//----------------------------------------------------------------
// SPRIT-ISSU. Added 11/07/2006 nadialee: END
//----------------------------------------------------------------
%>
        </tr>

    <%
      //Following are added for the sort function
      String sortByWhat = request.getParameter("sort");

      ArrayList ImageListArray = new ArrayList(ImageListCollection);
      if(sortByWhat != null)
       ImageListArray = sortBean.getImageListColSorted(sortByWhat, ImageListArray);


      //Using Array list
      Iterator imageListRecords = ImageListArray.iterator();
      //for(int imageIndex=0; imageIndex<ImageListInfoVector.size(); imageIndex++){
      while (imageListRecords.hasNext()) {
        //mImageListInfo = (ImageListInfo) imageListRecords.elementAt(imageIndex);
        mImageListInfo = (ImageListInfo) imageListRecords.next();
          %>
          <tr bgcolor="#ffffff">
        <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getImageName() %>
        </span></td>
        <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getPlatformName() %>
        </span></td>
            <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getMinFlash()%>
        </span></td>
                <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getMinDram()%>
        </span></td>
        <% if (spritAccessManager.isAdminGLA()) {
            Integer cdclvl = mImageListInfo.getCdcAccessLevel();
            %> <td valign="top" align="center"> <%
            if (cdclvl.equals(new Integer(0))) { %>
                Not Going to CCO
            <% } else if (cdclvl.equals(new Integer(1))) { %>
                Guest Registered
            <% } else if (cdclvl.equals(new Integer(2))) { %>
                Contract Registered
            <% } else { %>
                Access Level Not Known
            <% } %> </td> <%
          } else { %>
            <% if(mImageListInfo.getCcoFlag()!= null){
                if(mImageListInfo.getCcoFlag().equals("Y")) { %>
                    <td valign="top" align="center">
                    Y
                    </td>
                <% } else { %>
                    <td valign="top" align="center">
                    N
                    </td>
                        <% }
                    } else { %>
                <td valign="top" align="center">
                N
                </td>
                    <% }
                } %>

                <% if(mImageListInfo.getDeffered()!= null){
                if(mImageListInfo.getDeffered().equals("Y")) { %>
        <td valign="top" align="center">
        <%= mImageListInfo.getDeffered()%>
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <%= mImageListInfo.getDeffered()%>
        </td>
                <% }
                } else { %>
        <td valign="top" align="center">
              N
        </td>
                <% } %>

                <%
                if(mImageListInfo.getSoftwareAdvisory()!= null){
                if(mImageListInfo.getSoftwareAdvisory().equals("Y")) { %>
        <td valign="top" align="center">
        <%= mImageListInfo.getSoftwareAdvisory()%>
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <%= mImageListInfo.getSoftwareAdvisory() %>
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              N
        </td>
                <% } %>
        <td align="center" valign="top"><span class="dataTableData">
            <%= mImageListInfo.getType()%>
        </span></td>
        
        <% 
      //-------------------------------------------------------------------------------
      // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - START
      //-------------------------------------------------------------------------------
        if(mImageListInfo.getLicensed()!= null){
            if(mImageListInfo.getLicensed().equals("Y")) { %>
        		 <td valign="top" align="center">Y</td>
         <% } else { %>
        		<td valign="top" align="center">N</td>
         <% } %>
     <% } else { %>
        	<td valign="top" align="center">N</td>
     <% }
     //-------------------------------------------------------------------------------
     // Licensing and Pseudo Image feature changes May 2008 - Akshay Buradkar - END
     //-------------------------------------------------------------------------------
     %>
        
        <% if(mImageListInfo.getTest()!= null){
                if(mImageListInfo.getTest().equals("T")) { %>
        			<td valign="top" align="center">
        			Test
        			</td>
        		<% } else { %>
        			<td valign="top" align="center">
        			Prod
        			</td>
                <% } %>
        <% } else { %>
        	<td valign="top" align="center">
        	Prod
        	</td>
        <% } %>
        
        <!-- sprit 6.9 CSCsj91893 -->
        <% if("IOS".equals(rnmInfo.getOsType()) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>        
        <td valign="top" align="center">
        <%= mImageListInfo.getMImagePostingType()%>
        </td>  
        <%} %>   
        <!-- end sprit 6.9 CSCsj91893 -->   
<%
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
     //----------------------------------------------------------------

         if( "IOS".equals(rnmInfo.getOsType()) &&
             imageId2IssuStateInfoHash != null &&
             imageId2IssuStateInfoHash.containsKey(mImageListInfo.getImageId())
           ) {

             foundIssuImage = true;  // will be used to call ces monitor.

             issuStateVect = (Vector) imageId2IssuStateInfoHash.get(mImageListInfo.getImageId());

             issuState = (String) issuStateVect.elementAt(1);

             issuState = (issuState==null || issuState.trim().length()==0 ) ? "N/A" : issuState;

             if( issuStateDispHighlightVect != null &&
                 issuState != null &&
                 issuState.trim().length() > 0 &&
                 issuStateDispHighlightVect.contains(issuState) ) {

                 fontTagOpen  = "<font color=\"ff0000\">";
                 fontTagClose = "</font>";
             } else {
                fontTagOpen  = "";
                fontTagClose = "";
             }
%>
        <td valign="top" align="center"><%=fontTagOpen%>
             <%=issuState%>
        <%=fontTagClose%></td>
<%
          } // if( "IOS".equals(rnmInfo.getOsType()) &&....
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 11/07/2006 nadialee: END
     //----------------------------------------------------------------
%>
                </tr>
      <% } %>

      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>
  </center>

<%
//----------------------------------------------------------------
// SPRIT-ISSU. Added 12/20/2006 nadialee: BEGIN
//----------------------------------------------------------------
//
// Use same page title for all Image List for easier tracking.
//
if( foundIssuImage ) {
     monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Image List ISSU State Display");
} //if( foundIssuImage )
//----------------------------------------------------------------
// SPRIT-ISSU. Added 12/20/2006 nadialee: END
//----------------------------------------------------------------
%>


<!-- end -->
