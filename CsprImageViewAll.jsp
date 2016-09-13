<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
: @author Kelly Hollingshead (kellmill) CSCsc19024, modified for clone function.
:
: Copyright (c) 2005-2008, 2010, 2012-2013 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import = "com.cisco.eit.sprit.ui.SpritGUI,
                   com.cisco.eit.sprit.ui.SpritGUIBanner,
                   com.cisco.eit.sprit.ui.SpritReleaseTabs,
                   com.cisco.eit.sprit.ui.SpritSecondaryNavBar" %>
<%@ page import = "com.cisco.eit.sprit.gui.Footer" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import = "com.cisco.rtim.util.StringUtils" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import = "com.cisco.eit.sprit.logic.managmentMetadata.ManagementMetadataHelper"%>
<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprSoftwareTypeMetaDataJdbc" %>


<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.util.*" %>

<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprImageDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprImageRecordInfo" %>
<%@ page import="com.cisco.eit.sprit.model.csprimagemdf.*"%>
<%@ page import="com.cisco.eit.sprit.model.csprmachineostype.*"%>
<%@ page import = "com.cisco.eit.sprit.dataobject.PlatformMdfVo"%>
<%@page import="com.cisco.eit.sprit.util.StringComparator"%>

<%

  Integer               osTypeId            = null;
  String                osType              = null;
  String                releaseNumber       = null;
  NonIosCcoPostHelper   nonIosCcoPostHelper = null;
  SpritAccessManager    spritAccessManager;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  boolean               isSoftwareTypePM    = false;
  String   filterReleaseNumber              = "";
  String   filterImageName                  = "";
  String   filterTransactionType              = "";
  String   filterPostingType                  = "";
  
  String   message                          ="";
  
  String                imageName           ="";
  
   // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );

  nonIosCcoPostHelper = new NonIosCcoPostHelper();
  String strMode = nonIosCcoPostHelper.getMode(request);
  
  
    if(osType == null || osType.equals("")) {
     osType = (String) request.getAttribute("osType");
     osTypeId = (Integer) request.getAttribute("osTypeId");
  }


  // Get os type ID.  Try to convert it to an Integer from the web value!
  try {
	    if(osType == null || osType.equals("")) {
	     osTypeId = nonIosCcoPostHelper.getOSTypeId(request); 
	     osType = nonIosCcoPostHelper.getOSType(osTypeId);
	     
	    }
	  } catch ( Exception e ) {
	%>	  
		  <jsp:forward page="<%= NonIosCcoPostHelper.NO_OS_TYPE_ID_URL %>"/>
	<% 	    
	    //response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
    }
  

try{ 
    message = (String) session.getAttribute("message");
    if(message==null || "null".equalsIgnoreCase(message)) message="";
    session.removeAttribute("message");
  } catch ( Exception e ) {
      //do nothing
  }


  if(osType == null || osType.equals("")) {
   // No os type!  Bad! Redirect to error page.
  %>
  <jsp:forward page="<%= NonIosCcoPostHelper.NO_OS_TYPE_ID_URL %>"/>
  <% 
    //response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

  releaseNumber =WebUtils.getParameter(request,"releaseName");
 
   
  //CSCuh63229 (Solve Null pointer exception while software switching)
  int n = 0;
  if (request.getQueryString() != null){
  n = request.getQueryString().indexOf("&");
  }

  //if(releaseNumber==null || releaseNumber.equals("")){
	 if(osTypeId!=null && n==-1){
           int noOfReleases=-1; 
	/*
	 java.sql.Connection conn=null;
   	     int noOfReleases=-1;
   	     java.sql.PreparedStatement pst=null;
        try{
       	 conn = SpritDb.jdbcGetConnection();
       	 String sql="select count(*) no_of_releases from cspr_release_number where os_type_id=?";
       	 pst= conn.prepareStatement(sql);
       	 pst.setInt(1, osTypeId.intValue());
            java.sql.ResultSet rSet = pst.executeQuery();
            
            if(rSet.next()){
           	 noOfReleases= rSet.getInt(1);
            }
            rSet.close();
            pst.close();
            conn.close();
        }catch(Exception e){
       	 out.println(e);
           //return noOfImages;	
        }finally{
            try{
          	  if(pst!=null) pst.close();
          	  if(conn!=null) conn.close();
          	  
            }catch(Exception e1){}
         }
     */
	noOfReleases=SpritUtility.contReleasesForSW(osTypeId.intValue());
     
     
 if(noOfReleases>5){
 %>
   <jsp:forward page="NonIOSSelectRelease.jsp">
     <jsp:param name="osTypeId" value="<%= osTypeId %>" />
     <jsp:param name="selectedTab" value="MetaData" />
     <jsp:param name="mode" value="View" />
   </jsp:forward>
      
  <%   
	 // response.sendRedirect("./NonIOSSelectRelease.jsp?osTypeId="+osTypeId+"&selectedTab=MetaData&mode=View");
  }
  }
  

  
 filterReleaseNumber = StringUtils.elimSpaces(WebUtils.getParameter(request,"filterReleaseNumber"));
 filterImageName     = StringUtils.elimSpaces(WebUtils.getParameter(request,"filterImageName"));
 filterTransactionType = StringUtils.elimSpaces(WebUtils.getParameter(request,"filterTransactionType"));
 filterPostingType     = StringUtils.elimSpaces(WebUtils.getParameter(request,"filterPostingType"));
 
 filterReleaseNumber = CsprImageDataJdbc.getFilterString(filterReleaseNumber);
 filterImageName = CsprImageDataJdbc.getFilterString(filterImageName);
 filterTransactionType = CsprImageDataJdbc.getFilterString(filterTransactionType);
 filterPostingType = CsprImageDataJdbc.getFilterString(filterPostingType);
 
 releaseNumber       = (releaseNumber==null ||"".equalsIgnoreCase(releaseNumber.trim())?SpritUtility.replaceString(filterReleaseNumber,"*",""):releaseNumber);
 imageName           = SpritUtility.replaceString(filterImageName,"*","");
 String ttype        = SpritUtility.replaceString(filterTransactionType,"*","");
 String ptype        = SpritUtility.replaceString(filterPostingType,"*","");
 
 if ( filterReleaseNumber == null || "".equals( filterReleaseNumber ) )
      filterReleaseNumber = (releaseNumber==null ||"".equalsIgnoreCase(releaseNumber.trim())?"*":releaseNumber);
 if ( filterImageName == null || "".equals( filterImageName ) )
      filterImageName = "*";
 if ( filterTransactionType == null || "".equals( filterTransactionType ) )
      filterTransactionType = "*";
 if ( filterPostingType == null || "".equals( filterPostingType ) )
      filterPostingType = "*";


  
  isSoftwareTypePM = spritAccessManager.isSoftwareTypePM(osTypeId); 

  if (!isSoftwareTypePM && !NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
 
	  String url=NonIosCcoPostHelper.REDIRECT_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_VIEW + "&" +
      NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId;
  %>
  <jsp:forward page="<%= url %>"/>
  <%	  
    //response.sendRedirect(NonIosCcoPostHelper.REDIRECT_URL + NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_VIEW + "&" + NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId);
  }

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  if(strMode != null && NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                                 SpritGUI.renderOSTypeNav(globals,osType)
    );
  } else {
    banner.addContextNavElement( NonIosCcoPostHelper.OS_TYPE_BANNER,
                                 SpritGUI.renderOSTypeNav(globals,osType,releaseNumber)
    );
  }

  // html macros
  String pathGfx = globals.gs( SpritConstants.PATH_GFX );

  
%>
<form name="csprImageViewAll" method="post" action="CsprImageViewAll.jsp">
<%= SpritGUI.pageHeader( globals,"mmd","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getOSTypeTabs(globals,"mmd") %>
<%
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript">
<!--
// ==========================
// CUSTOM JAVASCRIPT ROUTINES
// ==========================

//added for MdfConcept window

var popupWindow = null;


//======================================================================
// Make MDF Navigator popup window.
//======================================================================
function popup(popupName, fName, eName, swType )
{

    var THIS_FUNC = "[popup] ";

    // dummy value for testing.
    swType = 'VxWorks';

//    alert( THIS_FUNC + "debug 1");

    var windowWidth  = 500;
    var windowHeight = 600;
    var locX = 500;
    var locY = 200;
    var windowFeatures = "width=" + windowWidth
                     + ",height=" + windowHeight
                     + ",scrollbars=yes"
                     + ",resizable=yes"
                     + ",screenX=" + locX
                     + ",screenY=" + locY
                     + ",left=" + locX
                     + ",top=" + locY;

    if( popupName==null || popupName=="" ) {
        alert( THIS_FUNC + ": Parameter 'popupName' is not defined. " +
            "This is an application error. Please contact application admin." );
        return;
    }


    //-----------------------------------------------------------------
    // Pass current MDF IDs and MDF names in $-delimited format.
    //-----------------------------------------------------------------
    var listObj     = document.forms[fName].elements[eName];
    var paramMdf    = "";

    for( var i=0; i<listObj.length; i++ )
    {
        paramMdf +=
            "&mdf=" + listObj.options[i].value + "$" +
            listObj.options[i].text;
    }

    //-----------------------------------------------------------------
    // Attach calling object names as parameter.
    //-----------------------------------------------------------------
    urlParam = "?f=" + fName + "&e=" + eName +
        "&swType=" + swType + paramMdf;

    popupName = popupName + urlParam;

    //-----------------------------------------------------------------
    // Close window first to make sure that our window has the desired
    // features
    //-----------------------------------------------------------------
    if ( popupWindow != null  && !popupWindow.closed ) {
        popupWindow.close();
    }

//    alert( THIS_FUNC + "debug 90: popupName = " + popupName );
    //-----------------------------------------------------------------
    // Open the new popup window, Owner is the name of the window.
    //-----------------------------------------------------------------
    popupWindow = window.open(popupName, 'Owner', windowFeatures );
//    popupWindow.focus();

} // function popup

function changeSoftwareType() {
   document.csprImageViewAll.submit();
   return true;
}

-->
</script>

<form action="<%= globals.gs("currentPage")  %>" method="get">


<table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr bgcolor="#BBD1ED">
    <td valign="middle" width="100%" align="left">
      
    <%
    
    secNavBar.addFilters(
            "filterReleaseNumber", filterReleaseNumber, 12,
            pathGfx+"/"+"release_number.gif",
            "Sorry, no Help available.",
            "Release Number filter" //CSCsi59809
            );
    secNavBar.addFilters(
                "filterImageName", filterImageName, 22,
                pathGfx+"/"+"filter_label_imgname.gif",
                "Sorry, no Help available.",
                "Image Name filter" //CSCsi59809
         );
    secNavBar.addFilters(
                "filterTransactionType", filterTransactionType, 22,
                pathGfx+"/"+"filter_label_transaction_status.gif",
                "Sorry, no Help available.",
                "Transaction Status filter"
         );
    secNavBar.addFilters(
                "filterPostingType", filterPostingType, 22,
                pathGfx+"/"+"filter_label_posting_status.gif",
                "Sorry, no Help available.",
                "Posting Type filter"
         );
    
    if((isSoftwareTypePM ||spritAccessManager.isAdminSprit()) && !SpritUtility.isSoftwareTypeEndOfSupport(osTypeId.toString())) {
       if (SpritUtility.isProductizationSupportedBySoftwareType(osType)) {
           out.println(SpritGUI.renderTabContextNav(
                   globals,secNavBar.render( new boolean [] {true,true,false,true},
                          new String [] { "Create","Delete", "View All", "Productization" },
                          new String [] { "CsprCreateMetaData.jsp?osTypeId=" + osTypeId,
                                          "CsprDeleteImage.jsp?osTypeId=" + osTypeId,
                                          "CsprImageViewAll.jsp?osTypeId=" + osTypeId,
                                          "ProductizationEdit.jsp?osTypeId=" + osTypeId}
                          ))); 
       } else {
           out.println(SpritGUI.renderTabContextNav(
                   globals,secNavBar.render( new boolean [] {true,true,false},
                          new String [] { "Create","Delete", "View All", },
                          new String [] { "CsprCreateMetaData.jsp?osTypeId=" + osTypeId,
                                          "CsprDeleteImage.jsp?osTypeId=" + osTypeId,
                                          "CsprImageViewAll.jsp?osTypeId=" + osTypeId}
                          ))); 
       }      
    } 
    else {
    out.println(SpritGUI.renderTabContextNav(
                  globals,secNavBar.render( new boolean [] {false,true,true},
                         new String [] { "View All" },
                         new String [] { "CsprImageViewAll.jsp?osTypeId=" + osTypeId}
                         ))); 
    }
    
  
      %>
    </td>
  </tr>
</table>
    <input name="osTypeId" value=<%=osTypeId%> type="hidden">
</form>

  

<font size="+1" face="Arial,Helvetica"><b>
<center>
 
  View All Image Metadata
</center>
</b></font>


<input name="callingForm" value="CsprImageViewAll" type="hidden">
<input name="fromWhere" value="View" type="hidden">
<input name="_submitformflag" value="0" type="hidden">
<%  Vector csprSoftwareTypeMetaDataNameV = null;
	csprSoftwareTypeMetaDataNameV =CsprSoftwareTypeMetaDataJdbc.getCsprSoftwareTypeMetadataNameVector(osTypeId); %>
 
<!-- start here -->
<%=message %>
<table border="0" cellpadding="1" cellspacing="0" width="100%">
  <tbody><tr><td bgcolor="#3d127b">
    <table border="0" cellpadding="0" cellspacing="0">
    <tbody><tr><td bgcolor="#bbd1ed">
      <span class="dataTableData">
      </span><table border="0" cellpadding="3" cellspacing="1">
      <tbody><tr bgcolor="#d9d9d9">
    <%if(csprSoftwareTypeMetaDataNameV.contains("RELEASE_NUMBER") ) { %>
    	<td align="center" valign="top"><span class="dataTableTitle">
	  		Release Number</span></td>
	<%}if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_NAME") ) { %>
		<td align="center" valign="top"><span class="dataTableTitle">
	  		Image Name</span></td>
	<%}if (csprSoftwareTypeMetaDataNameV.contains("INDIVIDUAL_PLATFORM_NAME"))  { %>  
		<td align="center" valign="top"><span class="dataTableTitle">
	  		Platform</span></td> 
	<%}if(csprSoftwareTypeMetaDataNameV.contains("MIN_FLASH") ) {%>  
		<td align="center" valign="top"><span class="dataTableTitle">
	  		Min Flash</span></td>
	<%}if(csprSoftwareTypeMetaDataNameV.contains("DRAM") ) {%>
		<td align="center" valign="top"><span class="dataTableTitle">
	 	 	Min Dram</span></td>   
	<%}if (csprSoftwareTypeMetaDataNameV.contains("MDF_ID") ) { %>
		<td align="center" valign="top"><span class="dataTableTitle">
	 		MDF Based Cisco Product</span></td>
	<%}if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_DESCRIPTION") ) {%>
		<td align="center" valign="top"><span class="dataTableTitle">
	  		Image Description</span></td>
	<%} %>  
    <td align="center" valign="top"><span class="dataTableTitle">
      Transaction Status</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Posting Type</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Post date</span></td>
    <%if(csprSoftwareTypeMetaDataNameV.contains("IS_SOFTWARE_ADVISORY") ) { %>  
		<td align="center" valign="top"><span class="dataTableTitle">
   	  		Software Advisory</span></td>
   	<%}if(csprSoftwareTypeMetaDataNameV.contains("IS_DEFERRED") ) { %>  
	<td align="center" valign="top"><span class="dataTableTitle">
   	  Deferred</span></td>
   	<%} %>  
	<td align="center" valign="top"><span class="dataTableTitle">
   	  CCO Post</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  </span></td>
     </tr>
     
     <% 

        Iterator csprImageRecordsVector = null;
      	Collection csprImageRecordsColl = null;
      	CsprImageRecordInfo csprImageRecordInfo = null;
      	
      	Collection csprImageMdfRecordsColl =null;      
      	
      	HashMap  machineOsTypeNameHmap;
      	
      	try
               {
                csprImageRecordsColl = CsprImageDataJdbc.getAllCsprImageRecord(osTypeId,releaseNumber,imageName, ttype, ptype);
                ArrayList csprImageRecordsArray = new ArrayList(csprImageRecordsColl);
                
                if (csprImageRecordsArray != null) {
                	Collections.sort(csprImageRecordsArray,new StringComparator());
                	csprImageRecordsVector = csprImageRecordsArray.iterator();
     	    while (csprImageRecordsVector.hasNext()) {
                    csprImageRecordInfo = (CsprImageRecordInfo) csprImageRecordsVector.next();
                    
                    
%>

    <tr bgcolor="#ffffff">
    <%if(csprSoftwareTypeMetaDataNameV.contains("RELEASE_NUMBER") ) { %>
    <td align="left" valign="top" width="10%"><span class="dataTableData">
		  <%=csprImageRecordInfo.getReleaseName()%> </span></td>
		  
	<%}if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_NAME") ) { %>	  
    <td align="left" valign="top" width="5%"><span class="dataTableData">
		  <%=csprImageRecordInfo.getImageName()%> </span></td>
		  
	<%}if (csprSoftwareTypeMetaDataNameV.contains("INDIVIDUAL_PLATFORM_NAME"))  { %>  	  
    <td align="left" valign="top" width="10%" NOWRAP><span class="dataTableData">
    	<%List platformMdfList = ManagementMetadataHelper.getPlatformAndMdfByImageId(csprImageRecordInfo.getImageId());
	      for (int i=0; i< platformMdfList.size(); i++){
	         	PlatformMdfVo vo  = (PlatformMdfVo)platformMdfList.get(i);%>
	                         <li> <%=vo.getPlatformName()%>- <%=vo.getMdfName()%>
         <%} %>
		  
	 </span></td>
	 
	<%}if(csprSoftwareTypeMetaDataNameV.contains("MIN_FLASH") ) {%>  
	<td align="left" valign="top" width="10%"><span class="dataTableData">
		<%if (!csprImageRecordInfo.getMinFlash().toString().equalsIgnoreCase("0")){ %>
		  <%=csprImageRecordInfo.getMinFlash()%> <%} %></span></td>	
		  	
	<%}if(csprSoftwareTypeMetaDataNameV.contains("DRAM") ) {%>		    
	<td align="left" valign="top" width="10%"><span class="dataTableData">
		<%if (!csprImageRecordInfo.getDram().toString().equalsIgnoreCase("0")){ %>
		  <%=csprImageRecordInfo.getDram()%> <%} %></span></td>	
		    
	<%}if (csprSoftwareTypeMetaDataNameV.contains("MDF_ID") ) { %>	  		  
    <td align="left" valign="top" NOWRAP><span class="dataTableData">
	<%
		
		try{
		  machineOsTypeNameHmap = csprImageRecordInfo.getMdfConceptName();
		  Set machineOsTypeNameSet  = machineOsTypeNameHmap.entrySet();
		  Iterator  machineOsTypeNameIterator = machineOsTypeNameSet.iterator();
		  while (machineOsTypeNameIterator.hasNext() ) {
		  Map.Entry machineOsTypeNameHmapEntry = (Map.Entry) machineOsTypeNameIterator.next();
		  
		   %>
	             <li> <%=machineOsTypeNameHmapEntry.getValue().toString()%>  <%
		  
		  }
                }catch (Exception e) {
                  e.printStackTrace();
                }// end of try
	        
	        %>
		
	</span></td>	
	<%}if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_DESCRIPTION") ) {
		String imgDesc = (csprImageRecordInfo.getImageDescription() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getImageDescription()))
						? csprImageRecordInfo.getImageDescription() : "";
	%> 
    <td align="left" valign="top" width=10%><span class="dataTableData">
		<%=imgDesc%></span></td>
    <%} %>
    
    <td align="left" valign="top" width=5%><span class="dataTableData">
        <%=csprImageRecordInfo.getTransactionStatus()%></span></td>
    <td align="left" valign="top" width=5%><span class="dataTableData">
    <%
    	String postType = (csprImageRecordInfo.getPostingType() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getPostingType()))
    						? csprImageRecordInfo.getPostingType() : "";
    %>
        <%=postType%></span></td>
  <%  
    String ccoPostedTime="";
  
    if(csprImageRecordInfo.getCcoPostedTime()!=null)  ccoPostedTime=csprImageRecordInfo.getCcoPostedTime().toString();

     if("null".equals(ccoPostedTime)) ccoPostedTime="";
 %>

    <td align="center" valign="top" width="5%"><span class="dataTableData"> 
          <%=ccoPostedTime%></span></td>

    <%if(csprSoftwareTypeMetaDataNameV.contains("IS_SOFTWARE_ADVISORY") ) { %>        
    <td align="center" valign="top" width="5%"><span class="dataTableData">
		 <% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsSoftwareAdvisory()) ){ %>
		            <img src="../gfx/ico_check.gif" /> 
		         <% } else { %>
		            <img src="../gfx/ico_cross.gif" />
        <% } %>
		  
    </span></td>
    <%}if(csprSoftwareTypeMetaDataNameV.contains("IS_DEFERRED") ) { %>
    <td align="center" valign="top" width="5%"><span class="dataTableData">
		  <% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsDeferred()) ){ %>
		  	 <img src="../gfx/ico_check.gif" /> 
		  	<% } else { %>
		  	 <img src="../gfx/ico_cross.gif" />
        <% } %>
		  
	<%} %>	  
    </span></td>
    <td align="center" valign="top" width="5%"><span class="dataTableData">
		 <% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsPostedToCco()) ){ %>
		 		  	 <img src="../gfx/ico_check.gif" /> 
		 		  	<% } else { %>
		 		  	 <img src="../gfx/ico_cross.gif" />
		         <% } %>
		  
		  
		  </span></td>

    <td align="center" valign="top" width="10%"><span class="dataTableData">
       <a href="CsprImageView.jsp?osTypeId=<%=csprImageRecordInfo.getOsTypeId()%>&releaseName=<%= csprImageRecordInfo.getReleaseName() %>&imageName=<%= csprImageRecordInfo.getImageName()  %>">
        View</a>
      <%      
       if((isSoftwareTypePM ||spritAccessManager.isAdminSprit()) && !SpritUtility.isSoftwareTypeEndOfSupport(osTypeId.toString())) {
           String monActionStr = "SPRIT-6.6-CSCsc19024-NonIos Clone Feature ViewAll";
           String pageAction ="clone";
      %>  
       <a href="CsprImageEdit.jsp?osTypeId=<%=csprImageRecordInfo.getOsTypeId()%>&releaseName=<%= csprImageRecordInfo.getReleaseName() %>&imageName=<%= csprImageRecordInfo.getImageName()  %>">
         Edit</a>
  
       <a href=
         "CsprCreateMetaData.jsp?osTypeId=<%=csprImageRecordInfo.getOsTypeId()%>
         &releaseName=<%= csprImageRecordInfo.getReleaseName() %>
         &imageName=<%= csprImageRecordInfo.getImageName()  %>
         &monActionStr=<%=monActionStr%>
         &pageAction=<%=pageAction%> ">
         Clone</a>
      <% } %> 
      </span>
     </td>

     </tr>
   
   <%  
      }//end of while loop
                     }//end of if statement
                    } catch (Exception e) {
                     System.out.println(" Exception in CsprImageViewAll.jsp" );
                     e.printStackTrace();
      }
               
   %>   
   
      
    <input name="osTypeId" value=<%=osTypeId%> type="hidden">
    
    </tbody></table>
    </td></tr></tbody></table></td></tr></tbody></table>
      
    <!-- start footer -->
    <%= Footer.pageFooter(globals) %>
    <!-- end of footer -->

<!-- end -->
</form></body>
</html>

