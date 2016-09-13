<!--.........................................................................
: DESCRIPTION:
: Image List page.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
:
: Copyright (c) 2002-2008, 2010 by Cisco Systems, Inc. All rights reserved.
:.........................................................................-->

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.HashMap" %>

<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
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
<%@ page import="com.cisco.eit.shrrda.individualplatform.IndividualPlatformHome" %>
<%@ page import="com.cisco.eit.shrrda.individualplatform.IndividualPlatform" %>
<%@ page import="com.cisco.eit.sprit.ui.ImageListGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
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
  monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Image List View");


  if( platformFilter.length() < 1) {
    // No platformFilter!  Default it to *
    platformFilter = "*";

  }
  if( imageFilter.length() < 1 ) {
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
  String ImageFilter = "*";
  String jndiName;
//  String pathGfx;
  String PlatformFilter = "*";
  String releaseNumber = null;
  Integer postingTypeId = new Integer(0);

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
banner.addReleaseNumberElement(releaseNumberId);

%>

<%= SpritGUI.pageHeader( globals,"Image List","" ) %>
<form action="ImageList.jsp">
<%= banner.render() %>
<%= SpritReleaseTabs.getTabs(globals, "il") %>


<INPUT TYPE="HIDDEN" NAME="releaseNumberId" VALUE="<%=releaseNumberId%>"/>

<%
  SpritSecondaryNavBar navBar =  new SpritSecondaryNavBar( globals );
  if(((request.getParameter("ImageFilter") == null)||(request.getParameter("ImageFilter").equals(""))))
  {  navBar.addFilters( "ImageFilter", "*", 25,
                        "../gfx/filter_label_imgname.gif",
                        "Enter full part/part of the Image Name filter",
                        "Image Name Filter" ); }

  else
  {    navBar.addFilters( "ImageFilter", request.getParameter("ImageFilter"), 25,
                          "../gfx/filter_label_imgname.gif",
                          "Enter full part/part of the Image Name filter",
                          "Image Name Filter" );
  }
    if(((request.getParameter("PlatformFilter") == null)||(request.getParameter("PlatformFilter").equals(""))))
  {    navBar.addFilters( "PlatformFilter", "*", 25,
                          "../gfx/filter_label_platform.gif",
                          "Enter full part/part of the Platform Name filter",
                          "Platform Name Filter" );
  }
   else
  {     navBar.addFilters( "PlatformFilter", request.getParameter("PlatformFilter"), 25,
                            "../gfx/filter_label_platform.gif",
                            "Enter full part/part of the Platform Name filter",
                            "Platform Name Filter" );

  }
  try {
  if ((request.getParameter("ImageFilter") != null) && (request.getParameter("PlatformFilter") != null)) {
    out.println(SpritGUI.renderTabContextNav(
            globals,navBar.render(
        spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber,"IL"),
        true,
        "ImageList.jsp?releaseNumberId=" + releaseNumberId
             + "&ImageFilter=" + imageFilter
             + "&PlatformFilter=" + platformFilter
         + "&sort="+sortBean.ImageSort,
        "ImageListEdit.jsp?releaseNumberId="+ releaseNumberId
              + "&ImageFilter=" + ImageFilter
          + "&PlatformFilter=" + PlatformFilter
          + "&sort=" + sortBean.ImageSort,
          "ImageListReport.jsp?releaseNumberId="+releaseNumberId+"&ImageFilter="+request.getParameter("ImageFilter")+"&PlatformFilter="+request.getParameter("PlatformFilter")+"&sort="+sortBean.ImageSort)));
  } else {
        out.println(SpritGUI.renderTabContextNav(
                globals,navBar.render(
        spritAccessManager.isMilestoneOwner(releaseNumberId, releaseNumber,"IL"),
        true,
        "ImageList.jsp?releaseNumberId=" + releaseNumberId
             + "&ImageFilter=" + imageFilter
             + "&PlatformFilter=" + platformFilter
         + "&sort="+sortBean.ImageSort,
        "ImageListEdit.jsp?releaseNumberId="+ releaseNumberId
              + "&ImageFilter=" + ImageFilter
          + "&PlatformFilter=" + PlatformFilter
          + "&sort=" + sortBean.ImageSort,
                "ImageListReport.jsp?releaseNumberId="+releaseNumberId+"&ImageFilter="+ imageFilter +"&PlatformFilter="+ platformFilter +"&sort="+sortBean.ImageSort)));
 }
 } catch (Exception e) {
 	System.out.println("Exception"+ e);
 }

%>

<INPUT TYPE="HIDDEN" NAME="sort" VALUE="Image"/>
</form>

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

    e.printStackTrace();
 }

 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
 //----------------------------------------------------------------
 HashMap imageId2IssuStateInfoHash  = null;
 Vector  issuStateVect              = null;
 String  issuState                  = null;
 Vector  issuStateDispHighlightVect = new Vector();
 boolean foundIssuImage             = false;   //will be used for adoption rate

 issuStateDispHighlightVect.addElement("ISSU_OFF");

 //----------------------------------------------------------------
 // SPRIT-ISSU. Added 11/07/2006  nadialee: END
 //----------------------------------------------------------------

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

    e.printStackTrace();
 }

if ((request.getParameter("ImageFilter") != null) ||(request.getParameter("PlatformFilter") != null)){
if((!request.getParameter("ImageFilter").equals("*")) || (!request.getParameter("PlatformFilter").equals("*"))) {
ImageListCollection = ImageListGUI.htmlFilter(request.getParameter("ImageFilter"),
                      request.getParameter("PlatformFilter"),
                      ImageListCollection);
}
}

    ArrayList ImageListArray = new ArrayList(ImageListCollection);

if("IOS".equals(rnmInfo.getOsType())) {
      String bootImageRequired = mImageListSession.getBootImageRequiredAndNotPresent(ImageListArray);



if (! bootImageRequired.equals("")) { %>
<br>
<center><table border='1'><tr><td bgcolor='#d9d9d9'><font color="#ff0000"><br></b>Warning <%=bootImageRequired %> platform requires boot image in this release.</b><br><br></font></td></tr></table></center>
<br>
<% } // if (! bootImageRequired.equals(""))
} // if("IOS".equals(rnmInfo.getOsType()))
%>

<center>
<table>
<br>
<%=ImageListGUI.htmlSummarize(ImageListCollection)%>
 <br>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">
      <table border="0" cellpadding="3" cellspacing="1">


      <tr bgcolor="#d9d9d9">
    <td align="center" valign="top"><span class="dataTableTitle">
      <a href="ImageList.jsp?releaseNumberId=<%=request.getParameter("releaseNumberId")%>&ImageFilter=<%=request.getParameter("ImageFilter")%>&PlatformFilter=<%=request.getParameter("PlatformFilter")%>&sort=<%=sortBean.ImageSort%>"/>
      ImageName

    </span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      <a href="ImageList.jsp?releaseNumberId=<%=request.getParameter("releaseNumberId")%>&ImageFilter=<%=request.getParameter("ImageFilter")%>&PlatformFilter=<%=request.getParameter("PlatformFilter")%>&sort=<%=sortBean.PlatformSort%>"/>
      Platform
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
         Software Type
        </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Min Flash
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Min Dram
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      CCO
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Deferral
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      SoftwareA
    </span></td>
        <td align="center" valign="top"><span class="dataTableTitle">
      Type
    </span></td>
    
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay START -->
    <td align="center" valign="top"><span class="dataTableTitle">
      Licensed
    </span></td>
    <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
    
    <td align="center" valign="top"><span class="dataTableTitle">
      Test
    </span></td>
    
    <!-- 6.9 CSCsj91893 -->
    <% if("IOS".equals(rnmInfo.getOsType()) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>
    <td align="center" valign="top"><span class="dataTableTitle">
      Posting type
    </span></td>
    <%} %>
     <!-- end 6.9 CSCsj91893 -->
<%
//----------------------------------------------------------------
// SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
//----------------------------------------------------------------
if( "IOS".equals(rnmInfo.getOsType()) ) {
%>
    <td align="center" valign="top"><span class="dataTableTitle">
      ISSU State
    </span></td>
<%
} // if( "IOS".equals(rnmInfo.getOsType()) )
//----------------------------------------------------------------
// SPRIT-ISSU. Added 11/07/2006 nadialee: END
//----------------------------------------------------------------
%>

        </tr>

    <%
      //Following are added for the sort function
      String sortByWhat = request.getParameter("sort");

      ImageListArray = new ArrayList(ImageListCollection);

      if(sortByWhat != null)
        ImageListArray = sortBean.getImageListColSorted(sortByWhat, ImageListArray);

      //Using Array list
      Iterator imageListRecords = ImageListArray.iterator();
      //for(int imageIndex=0; imageIndex<ImageListInfoVector.size(); imageIndex++){


      while (imageListRecords.hasNext()) {
        //mImageListInfo = (ImageListInfo) imageListRecords.elementAt(imageIndex);
        mImageListInfo = (ImageListInfo) imageListRecords.next();


        // End determine if Boot Image is Required.
          %>
          <tr bgcolor="#ffffff">
        <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getImageName() %>
        </span></td>
        <td align="left" valign="top"><span class="dataTableData">
          <%= mImageListInfo.getPlatformName() %>
        </span></td>
<% if(mImageListInfo.getMdfSwtConceptName()==null || "null".equals(mImageListInfo.getMdfSwtConceptName()) ) mImageListInfo.setMdfSwtConceptName(""); %>
                <td align="left" valign="top"><span class="dataTableData">
                  <%= mImageListInfo.getMdfSwtConceptName()%>
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
                    <img src="../gfx/ico_check.gif" />
                    </td>
                <% } else { %>
                    <td valign="top" align="center">
                       <img src="../gfx/ico_cross.gif" />
                    </td>
                        <% }
                    } else { %>
                <td valign="top" align="center">
                <img src="../gfx/ico_cross.gif" />
                </td>
                    <% }
                } %>

                <% if(mImageListInfo.getDeffered()!= null){
                if(mImageListInfo.getDeffered().equals("Y")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% }
                } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>

                <%
                if(mImageListInfo.getSoftwareAdvisory()!= null){
                if(mImageListInfo.getSoftwareAdvisory().equals("Y")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
        <td align="center" valign="top"><span class="dataTableData">
            <%= mImageListInfo.getType()%>
        </span></td>
        
        <!--Licensing and Pseudo Image feature changes May 2008 - Akshay START -->        
        <% if(mImageListInfo.getLicensed()!= null){
                if(mImageListInfo.getLicensed().equals("Y")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
        <!--Licensing and Pseudo Image feature changes May 2008 - Akshay END -->
        
                <% if(mImageListInfo.getTest()!= null){
                if(mImageListInfo.getTest().equals("T")) { %>
        <td valign="top" align="center">
        <img src="../gfx/ico_check.gif" />
        </td>
        <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
                <% } else { %>
        <td valign="top" align="center">
              <img src="../gfx/ico_cross.gif" />
        </td>
                <% } %>
        
        <!--  6.9 CSCsj91893 -->        
        <% if("IOS".equals(rnmInfo.getOsType()) &&  (postingTypeId.toString().equals("5") || postingTypeId.toString().equals("6"))){%>        
        <td valign="top" align="center"><span class="dataTableData">
        <%= mImageListInfo.getMImagePostingType()%>
        </span></td> 
        <%} %>
        <!-- end  6.9 CSCsj91893 -->     

<%
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 11/07/2006 nadialee: BEGIN
     //----------------------------------------------------------------
         String strCssVal;

         if( "IOS".equals(rnmInfo.getOsType()) &&
             imageId2IssuStateInfoHash != null &&
             imageId2IssuStateInfoHash.containsKey(mImageListInfo.getImageId())
           ) {

             foundIssuImage = true;

             issuStateVect = (Vector) imageId2IssuStateInfoHash.get(mImageListInfo.getImageId());

             issuState = (String) issuStateVect.elementAt(1);

             issuState = (issuState==null || issuState.trim().length()==0 ) ? "N/A" : issuState;

             if( issuStateDispHighlightVect != null &&
                 issuState != null &&
                 issuState.trim().length() > 0 &&
                 issuStateDispHighlightVect.contains(issuState) ) {

                 strCssVal  = "dataTableDataRed";
             } else {
                 strCssVal  = "dataTableData";
             }
    %>
         <td align="center" valign="top"><span class=<%=strCssVal%>>
             <%=issuState%>
         </span></td>
    <%
          } // if( "IOS".equals(rnmInfo.getOsType()) && . . .
     //----------------------------------------------------------------
     // SPRIT-ISSU. Added 11/07/2006 nadialee: END
     //----------------------------------------------------------------
%>

                </tr>
      <% } %>
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

      </table>
    </td></tr>
    </table>
  </td></tr>
  </table>

</table>
</center>


<%=Footer.pageFooter(globals)%>

<!-- end -->
