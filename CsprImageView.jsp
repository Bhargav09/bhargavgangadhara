<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
: @author Kelly Hollingshead (kellmill) CSCsc19024, added clone function.
:
: Copyright (c) 2005-2010, 2012 by Cisco Systems, Inc.
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
<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprSoftwareTypeMetaDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprImageDataJdbc" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import = "com.cisco.eit.sprit.beans.SwtypeReleaseComponent" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import = "com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import = "com.cisco.rtim.util.WebUtils" %>
<%@ page import = "com.cisco.eit.exceptions.EitDatabaseException" %>
<%@ page import = "com.cisco.eit.logging.EitLog" %>
<%@ page import = "com.cisco.eit.sprit.dataobject.PlatformMdfVo"%>
<%@ page import = "com.cisco.eit.sprit.logic.managmentMetadata.ManagementMetadataHelper"%>

<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.Vector" %>
<%@ page import = "java.util.Collection" %>
<%@ page import = "java.util.ArrayList" %>

<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.util.Iterator" %>
<%@ page import = "javax.servlet.http.*" %>
<%@ page import = "java.text.SimpleDateFormat" %>


<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprImageDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprImageRecordInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprReleaseNotesInfo"%>
<%@ page import="com.cisco.eit.sprit.model.csprimagemdf.*"%>
<%@ page import="com.cisco.eit.sprit.model.csprmachineostype.*"%>
<%@ page import="com.cisco.eit.sprit.util.RelatedSoftwareHelper"%>
<%@ page import="com.cisco.eit.sprit.dataobject.PlatformOsTypeObject"%>
<!-- CSCud06651	-->
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<%@ page import="com.cisco.eit.sprit.model.dao.csprfeatureset.CsprFeatureSetDAO"%>
<%@page import="com.cisco.eit.sprit.dataobject.FeatureSetNonIosInfo"%>
<!-- CSCud06651 -->

<%
  //System.out.println(" CsprImageView STEP1   ");
  
  Integer               osTypeId            = null;
  //Integer               releaseNumberId     = null;
  String                osType              = null;
  String                releaseNumber       = null;
  NonIosCcoPostHelper   nonIosCcoPostHelper = null;
  SpritAccessManager    spritAccessManager;
  SpritGlobalInfo       globals;
  SpritGUIBanner        banner;
  boolean               isSoftwareTypePM    = false;
  CsprImageRecordInfo csprImageRecordInfo=null;
  
  Vector csprSoftwareTypeMetaDataNameV = null;
  
  
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );
  
  //6.9 related software
  session.removeAttribute("relatedSoftwareMap");
  session.removeAttribute("platformMap");

  nonIosCcoPostHelper = new NonIosCcoPostHelper();
  String strMode = nonIosCcoPostHelper.getMode(request);
  
 String osTypeStr = WebUtils.getParameter(request,"osTypeId");
  if(osTypeStr != null && osTypeStr.trim().length() > 0 ) {
        osTypeId = new Integer(WebUtils.getParameter(request,"osTypeId"));
     }
   //System.out.println("1-OsTypeId in View jsp is   "+osTypeId);
  /*if(osTypeId == null || osType.equals("")) {
    osType = (String) request.getAttribute("osType");
    osTypeId = (Integer) request.getAttribute("osTypeId");
  }
  */
  
  
System.out.println("2-OsTypeId in View jsp is   "+osTypeId);
  if(osTypeId == null ) {
   try{ csprImageRecordInfo = (CsprImageRecordInfo)session.getAttribute("csprImageRecordInfo");
    
    osType=csprImageRecordInfo.getOsTypeName();
    osTypeId=csprImageRecordInfo.getOsTypeId();
    session.removeAttribute("csprImageRecordInfo");
   }catch( Exception fe ) {
  	  System.out.println("Exception in CsprImageView.jsp page");
  	  fe.printStackTrace();
   }
  }
  
  //System.out.println("3-OsTypeId in View jsp is   "+osTypeId);
 
    //osType   = (String)session.getAttribute("osType");
    //osTypeId = (Integer)session.getAttribute("osTypeId");
    
 //System.out.println("4-OsTypeId in View jsp is   "+osTypeId); 
 
 // Get os type ID.  Try to convert it to an Integer from the web value!
  try {
    if(osTypeId == null ) {
     osTypeId = nonIosCcoPostHelper.getOSTypeId(request); 
     //osTypeId = request.getParameter("osTypeId");
    }
  } catch ( Exception e ) {
      //RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
      //dispatcher.forward(request, response);
      response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

// System.out.println(" STEP2   ");
  osType = nonIosCcoPostHelper.getOSType(osTypeId);
  
  //System.out.println("5-OsTypeId in View jsp is   "+osTypeId);
  
  if(osType == null || osType.equals("")) {
    // No os type!  Bad!  Redirect to error page.
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

  // System.out.println(" STEP3   ");

  
  //Integer osTypeId= new Integer(0);
    String releaseName="1";
    String imageName="image-vxworks-imz";
   try{
     session.removeAttribute("csprImageRecordInfo");
     if(osTypeId==null) {
      osTypeId = new Integer(WebUtils.getParameter(request,"osTypeId"));
     }
      releaseName = WebUtils.getParameter(request,"releaseName");
      imageName = WebUtils.getParameter(request,"imageName");
    
    //System.out.println("6-OsTypeId in View jsp is   "+osTypeId);
      
   //System.out.println(" STEP4   ");
   
    if("".equalsIgnoreCase(releaseName.trim())|| releaseName.trim()==null) { 
      releaseName = (String) session.getAttribute("releaseName");
    }
    if("".equalsIgnoreCase(imageName.trim())|| imageName.trim()==null) {
      imageName = (String) session.getAttribute("imageName");
    }
      
    System.out.println("releaseName is:   "+ releaseName);
    System.out.println("imageName is:   "+ imageName);
  
   
    if("".equalsIgnoreCase(releaseName.trim())|| releaseName.trim()==null) { 
      releaseName ="1";
    }
    if("".equalsIgnoreCase(imageName.trim())|| imageName.trim()==null) {
      imageName ="image-vxworks-imz";
    }
  
   } catch(Exception e) {
     System.out.println("Exception in CsprImageView.jsp "+e);
     e.printStackTrace();
   }
  
   //System.out.println(" STEP7   ");
   
   //////System.out.println("OsTypeId in View jsp is   "+osTypeId);
   //System.out.println("releaseName View in jsp is   "+releaseName);
   //System.out.println("imageName in View jsp is   "+imageName);
   //System.out.println("osTypeName in View jsp is   "+osType);
   //System.out.println("strMode in View jsp is   "+strMode);
   
  
   // System.out.println("Ostype Id in CsprImageView.jsp is "+osTypeId);
    

  isSoftwareTypePM = spritAccessManager.isSoftwareTypePM(osTypeId); 

  if(!isSoftwareTypePM && !NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
    response.sendRedirect(NonIosCcoPostHelper.REDIRECT_URL + 
                          NonIosCcoPostHelper.MODE + "=" + NonIosCcoPostHelper.MODE_VIEW + "&" +
                          NonIosCcoPostHelper.OS_TYPE_ID + "=" + osTypeId);
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
%>

<form name="softwareSelection" action="CsprImageViewAll.jsp" method="get">
 
<%= SpritGUI.pageHeader( globals,"mmd","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getOSTypeTabs(globals,"mmd") %>
<%
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>
 </form>
 
 <form name="csprImageView" method="post" action=""> 
 
<table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr bgcolor="#BBD1ED">
    <td valign="middle" width="70%" align="left">
      <%
   
  if((isSoftwareTypePM ||spritAccessManager.isAdminSprit()) && !SpritUtility.isSoftwareTypeEndOfSupport(osTypeId.toString())) {
      if (SpritUtility.isProductizationSupportedBySoftwareType(osType)) {
          out.println(SpritGUI.renderTabContextNav(
                  globals,secNavBar.render( new boolean [] {true,true,true,true},
                         new String [] { "Create","Delete", "View All", "Productization" },
                         new String [] { "CsprCreateMetaData.jsp?osTypeId=" + osTypeId,
                                         "CsprDeleteImage.jsp?osTypeId=" + osTypeId,
                                         "CsprImageViewAll.jsp?osTypeId=" + osTypeId,
                                         "ProductizationEdit.jsp?osTypeId=" + osTypeId}
                         ))); 
      } else {
          out.println(SpritGUI.renderTabContextNav(
                  globals,secNavBar.render( new boolean [] {true,true,true},
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

<center>

<font size="+1" face="Arial,Helvetica"><b>
<center>
  
  View Image Metadata
</center>
</b></font>

<% 

 
 
 //CsprImageMachineOsType      csprImageMachineOsType     = null;
 //CsprImageMachineOsTypeHome  csprImageMachineOsTypeHome = null;
 //CsprImageMdf                csprImageMdf               = null;
 //CsprImageMdfHome            csprImageMdfHome           = null;
 
 	HashMap  mdfConceptNameHmap;
 	HashMap  machineOsTypeNameHmap;
 
 
        Iterator csprImageRecordsVector = null;
 	Collection csprImageRecordsColl = null;
 	csprImageRecordInfo = null;
 	
 	Collection csprImageMdfRecordsColl =null;         
 	Collection releaseComponentDataColl = null;
 	CsprReleaseNotesInfo releaseNotesInfoVo = null;
 	CsprImageRecordInfo imageNotesInfo = null;
 	//Map imageNotesMap = null;
 	
 	try
          {
           csprImageRecordsColl = CsprImageDataJdbc.getCsprImageRecord(osTypeId,releaseName,imageName);
           ArrayList csprImageRecordsArray = new ArrayList(csprImageRecordsColl);
           
	   csprSoftwareTypeMetaDataNameV = CsprSoftwareTypeMetaDataJdbc.getCsprSoftwareTypeMetadataNameVector(osTypeId);
	   try {
	   releaseComponentDataColl = CsprImageDataJdbc.getReleaseComponentData(osTypeId, releaseName);
	   System.out.println(releaseComponentDataColl.size());
	   } catch(EitDatabaseException ex) {
	   	ex.printStackTrace();
	   		ex.log(EitLog.SEVERE, EitLog.getLogger("sprit"));
	   }
	   

           if (csprImageRecordsArray != null) {
           	csprImageRecordsVector = csprImageRecordsArray.iterator();
	    while (csprImageRecordsVector.hasNext()) {
               csprImageRecordInfo = (CsprImageRecordInfo) csprImageRecordsVector.next();
	    }//end of while loop
           }//end of if statement
           
           // get the release notes info Value object
          releaseNotesInfoVo = CsprImageDataJdbc.getReleaseNotes(releaseName, osTypeId);
          
          //get the image map
          //imageNotesMap = CsprImageDataJdbc.getImageNotes(releaseName, osTypeId, imageName);
          imageNotesInfo = CsprImageDataJdbc.getImageNotes(releaseName, osTypeId, imageName);  
           
           
          } catch (Exception e) {
           System.out.println(" Exception in CsprImageView.jsp" );
           e.printStackTrace();
           
          }

          
%>
  

<input name="fromWhere" value="View" type="hidden">
<input name="_submitformflag" value="0" type="hidden">

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript"> <!--
   
function setAction(target) {
  document.forms['csprImageView'].action = target;
  
}

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

    //----------------------------------------------------------------
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

//............................................................................
// DESCRIPTION:
// Used by the non-ios software type selection drop down menu. 
//
//............................................................................
function changeSoftwareType() {
   document.softwareSelection.submit();
   return true;
}
  -->
</script>




<!-- Added new Table to Image entry -->

  <table border="0" cellpadding="1" cellspacing="0" size=900 align="center">
  <tbody><tr><td bgcolor="#3d127b">
    <table border="0" cellpadding="0" cellspacing="0">
    <tbody><tr><td bgcolor="#bbd1ed">

    <table border="0" cellpadding="3" cellspacing="1">
      <tbody>

<%
 if(csprSoftwareTypeMetaDataNameV.contains("RELEASE_NUMBER") ) {
 //System.out.println(" STEP8 OsTypeId is "+osTypeId +" ImageName is "+imageName+" releaseName is "+releaseName );
 %>
 <tr bgcolor="#d9d9d9">
 	<td align="left" valign="top"><span class="dataTableTitle">
 	<% if(csprImageRecordInfo==null) { %>
	 	 No Image record is found
	 	 <%= csprImageRecordInfo.getReleaseName() %>
 	 <% } %>
 	  Release Number
 	</span></td>
 	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <%= csprImageRecordInfo.getReleaseName() %>
 	</span></td>
 </tr>
 
<% } %>

<%
 if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_NAME") ) {
 %>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Image Name 
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <%= csprImageRecordInfo.getImageName()  %>
	</span></td>
</tr>
<% } %>

<%
 if(csprSoftwareTypeMetaDataNameV.contains("IMAGE_DESCRIPTION") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Image Description 
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<%
		String imgDesc = (csprImageRecordInfo.getImageDescription() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getImageDescription())) 
						? csprImageRecordInfo.getImageDescription() : "";
	%>
          <%= imgDesc  %>
	</span></td>
</tr>
<% } %>

<!-- Sprit 7.0 productization Platform Pop Up window -->
<%
 if(csprSoftwareTypeMetaDataNameV.contains("INDIVIDUAL_PLATFORM_NAME"))  {
 %>
<tr bgcolor="#d9d9d9">
        <td align="left" valign="top"><span class="dataTableTitle">
         Platform 
         <font size="-2"> (Platform - MDF)
        </span></td>
       <td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
       		<%if(csprImageRecordInfo!=null && csprImageRecordInfo.getImageId()!=null){
	  			List platformMdfList = ManagementMetadataHelper.getPlatformAndMdfByImageId(csprImageRecordInfo.getImageId());
          		for (int i=0; i< platformMdfList.size(); i++){
        	   	PlatformMdfVo vo  = (PlatformMdfVo)platformMdfList.get(i);%>
                      <li> <%=vo.getPlatformName()%>- <%=vo.getMdfName()%>
           		<%} 
	  	    }%>
      </span></td>	
 </tr>
<% } %>


<%if(csprSoftwareTypeMetaDataNameV.contains("MDF_ID") ) {
 %>
<tr bgcolor="#d9d9d9">
        <td align="left" valign="top"><span class="dataTableTitle">
         MDF Based Cisco Product
        </span></td>
       <td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
       
      <%
       try{
           mdfConceptNameHmap = csprImageRecordInfo.getMdfConceptName();
           Set mdfConceptNameSet  = mdfConceptNameHmap.entrySet();
           Iterator  mdfConceptNameIterator = mdfConceptNameSet.iterator();
           while (mdfConceptNameIterator.hasNext() ) {
             Map.Entry mdfConceptNameHmapEntry = (Map.Entry) mdfConceptNameIterator.next();
            // System.out.println("Hmap Key is (Mdf concept)   " + mdfConceptNameHmapEntry.getKey().toString() );
            // System.out.println("Hmap Value is (Mdf concept) " + mdfConceptNameHmapEntry.getValue().toString() );
             
                 %>
	    	             <li> <%=mdfConceptNameHmapEntry.getValue().toString()%>  <%
           }
       }catch (Exception e) {
         e.printStackTrace();
       }// end of try
      
      %>
      
  </span></td>	
 </tr>
 <%} %>
 <!-- CSCud06651 to show featureset associated with image -->
												<%
													if (csprSoftwareTypeMetaDataNameV.contains("FEATURE_SET_NAME")) {
												%>
												<tr bgcolor="#d9d9d9">
													<td align="left" valign="top"><span
														class="dataTableTitle"> Feature Set </span></td>
													<td bgcolor="#f5d6a4" align="left" valign="top"><span
														class="dataTableData"> <%
									 	     try {
											 CsprFeatureSetDAO dao = null;
											 dao = (CsprFeatureSetDAO)SpringUtil.getApplicationContext().getBean("csprFeatureSetDAO");					
									 			List featureSetNameList = dao.getImageNonIosRecords(osTypeId,csprImageRecordInfo.getImageId());
									
									 			for (int i = 0; i < featureSetNameList.size(); i++) {
									 				FeatureSetNonIosInfo fsinfo = (FeatureSetNonIosInfo) featureSetNameList
									 						.get(i);
 %>
											 <li><%=fsinfo.getFeatureSetName()%>:<%=fsinfo.getFeatureSetDesc()%>:<%=fsinfo.getIsFSetGoingToCCO()%>
												<%
													}
														} catch (Exception e) {
															e.printStackTrace();
														}// end of try
												%></span></td>
												</tr>
												<%
													}
												%>
												<!-- CSCud06651	 -->

<%
  if(csprSoftwareTypeMetaDataNameV.contains("MACHINE_OS_TYPE_NAME") ) {
%>
<tr bgcolor="#d9d9d9">
   <td align="left" valign="top"><span class="dataTableTitle">
     Machine Operating System 
  </span></td>
  <td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
  <%
  		
  		try{
  		  machineOsTypeNameHmap = csprImageRecordInfo.getMachineOsTypeName();
  		  Set machineOsTypeNameSet  = machineOsTypeNameHmap.entrySet();
  		  Iterator  machineOsTypeNameIterator = machineOsTypeNameSet.iterator();
  		  while (machineOsTypeNameIterator.hasNext() ) {
  		  Map.Entry machineOsTypeNameHmapEntry = (Map.Entry) machineOsTypeNameIterator.next();
  		  //System.out.println("Hmap Key is     "+ machineOsTypeNameHmapEntry.getKey().toString() );
  		  //System.out.println("Hmap Value is   "+ machineOsTypeNameHmapEntry.getValue().toString() );
  		  
  		   %>
  	             <li> <%=machineOsTypeNameHmapEntry.getValue().toString()%>  <%
  		  
  		  }
                  }catch (Exception e) {
                    e.printStackTrace();
                  }// end of try
  	        
	        %>
  

    
    
 </span></td>	
</tr>
<% } %>  

<%
if(csprSoftwareTypeMetaDataNameV.contains("MEMORY_FOOTPRINT") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Memory 
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <%= csprImageRecordInfo.getMemoryFootprint()  %>
	</span></td>
</tr>
<% } %>  

<%
if(csprSoftwareTypeMetaDataNameV.contains("HARD_DISK_FOOTPRINT") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Hard Disk Footprint
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
         <%= csprImageRecordInfo.getHardDiskFootprint()  %>
	</span></td>
</tr>
<% } %>  

<%
if(csprSoftwareTypeMetaDataNameV.contains("IS_CRYPTO") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Crypto
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<%=csprImageRecordInfo.getIsCrypto()  %>
	</span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("MIN_FLASH") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Min Flash
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">	
	<%
		if(csprImageRecordInfo.getMinFlash() != null) {
	%>
	<%=csprImageRecordInfo.getMinFlash() %>
	<% } %>
	</span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("DRAM") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Min Dram
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<%
		if(csprImageRecordInfo.getDram() != null) {
	%>
	<%=csprImageRecordInfo.getDram()  %>
	<% } %>
	</span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("RELEASE_DOC_URL") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Release Notes URL 
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <%= csprImageRecordInfo.getReleaseDocUrl() %> <br>
        </span></td>
</tr>
<% } %> 

<%
String postingTypeChecked1="";
String postingTypeChecked2="";
String postingTypeChecked3="";
String postingTypeChecked4="";
String postingTypeChecked5="";
String postingTypeChecked6="";
String postingTypeChecked7="";
String postingTypeChecked10="";
String postingTypeChecked9="";

if(csprImageRecordInfo.getPostingTypeId().equals(new Integer(2)) ) {
  postingTypeChecked2="<img src=\"../gfx/ico_check.gif\" />" +" CCO Only ";
  //System.out.println("VALUE IS   " +postingTypeChecked1);
 }
else if(csprImageRecordInfo.getPostingTypeId().equals(new Integer(1)) ) {
	  postingTypeChecked1="<img src=\"../gfx/ico_check.gif\" />"+" CCO and MFG ";
	 }
else if(csprImageRecordInfo.getPostingTypeId().equals(new Integer(3)) ) {
  postingTypeChecked3="<img src=\"../gfx/ico_check.gif\" />"+" Hidden Post CCO Only ";
 }
else if(csprImageRecordInfo.getPostingTypeId().equals(new Integer(4)) ) {
  postingTypeChecked4="<img src=\"../gfx/ico_check.gif\" />"+ " Hidden Post MFG Only ";
 }
else if(csprImageRecordInfo.getPostingTypeId().equals(new Integer(7)) ) {
  postingTypeChecked7="<img src=\"../gfx/ico_check.gif\" />" +" Hidden with ACL " ;
 } else if(csprImageRecordInfo.getPostingTypeId().equals(new Integer(9)) ) {
  postingTypeChecked9="<img src=\"../gfx/ico_check.gif\" />" +" Hidden Machine to Machine " ;
 } 
else {
  postingTypeChecked10="<img src=\"../gfx/ico_check.gif\" />"+" Not known";
}

%>

<%
if(csprSoftwareTypeMetaDataNameV.contains("POSTING_TYPE_NAME") ) {
%> 
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Posting Type
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="bottom"><span class="dataTableData">
	<%=postingTypeChecked1%> 
	<%=postingTypeChecked2%> 
	<%=postingTypeChecked3%> 
	<%=postingTypeChecked4%> 
	<%=postingTypeChecked5%>
	<%=postingTypeChecked6%>
	<%=postingTypeChecked7%>
	<%=postingTypeChecked9%>
	<%=postingTypeChecked10%>
	
	<!--
        <%=postingTypeChecked1%> FCS 
	<%=postingTypeChecked2%> Beta
	<%=postingTypeChecked3%> Eval
	<%=postingTypeChecked4%> Hidden
	<%=postingTypeChecked5%> Not known
	-->
        </span></td>
</tr>
<% } %>

<%
if(csprSoftwareTypeMetaDataNameV.contains("INSTALLATION_DOC_URL") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Installation Docs URL
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <%= csprImageRecordInfo.getInstallationDocUrl() %>
	</span></td>
</tr>
<% } %>

<%
if(csprSoftwareTypeMetaDataNameV.contains("PRODUCT_CODE") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Product Code
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<%
		String prodCode = (csprImageRecordInfo.getProductCode() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getProductCode()))
							? csprImageRecordInfo.getProductCode() : "";
	%>
          <%= prodCode %>
        </span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("CCATS") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  CCATS
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<%
		String ccats = (csprImageRecordInfo.getCcats() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getCcats()))
							? csprImageRecordInfo.getCcats() : "";
	%>
          <%= ccats %>
        </span></td>
</tr>
<% } %> 


<%
if(csprSoftwareTypeMetaDataNameV.contains("FCS_DATE") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	CCO FCS Date
	</span></td>
	<% String fcsDate = "";
	   if (csprImageRecordInfo.getCcoFcsDate() !=null){
			SimpleDateFormat format = new SimpleDateFormat("dd-MMM-yyyy hh:mm:ss a");
			fcsDate = format.format(csprImageRecordInfo.getCcoFcsDate());
	  }
	%>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
          <%= fcsDate%>
        </span></td>
</tr>
<% } %> 

<%
if(csprSoftwareTypeMetaDataNameV.contains("IS_SOFTWARE_ADVISORY") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Software Advisories 
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	
	<% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsSoftwareAdvisory()) ){ %>
         <img src="../gfx/ico_check.gif" /> 
        <% } else { %>
         <img src="../gfx/ico_cross.gif" />
        <% } 
         String softAdvDocUrl = (csprImageRecordInfo.getSoftwareAdvisoryDocUrl()!= null && !"null".equalsIgnoreCase(csprImageRecordInfo.getSoftwareAdvisoryDocUrl()))  
         						? csprImageRecordInfo.getSoftwareAdvisoryDocUrl() : "";
        %>          
          <%= softAdvDocUrl %> 
	</span></td>
</tr>
<% } %> 


<%
if(csprSoftwareTypeMetaDataNameV.contains("IS_DEFERRED") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Deferral Advisories 
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	
	<% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsDeferred()) ){ %>
	  <img src="../gfx/ico_check.gif" /> 
	<% } else { %>
	  <img src="../gfx/ico_cross.gif" />
        <% } 
        String defAdvDocUrl = (csprImageRecordInfo.getDeferralAdvisoryDocUrl() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getDeferralAdvisoryDocUrl()))
        						? csprImageRecordInfo.getDeferralAdvisoryDocUrl() : "";
        %>
        <%= defAdvDocUrl %>
	</span></td>
</tr>
<% } %> 

<%Map mapInfo = RelatedSoftwareHelper.getSelectedRelatedSoftware(csprImageRecordInfo.getImageId()); 
//String displayText = RelatedSoftwareHelper.getDisplayText(mapInfo);
  String displayText = RelatedSoftwareHelper.getDisplayData(mapInfo); //group by softwaretype and in Alphabetical order
%>
<%
if(csprSoftwareTypeMetaDataNameV.contains("RELATED_SOFTWARE") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Related Software
	 </span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	
	<%=displayText%> 
        </span></td>
</tr>
<% } %>

<%
String cdcAccessLevel0="";
String cdcAccessLevel1="";
String cdcAccessLevel2="";
String cdcAccessLevel3="";

if(csprImageRecordInfo.getCdcAccessLevelId().equals(new Integer(0)) ) {
  cdcAccessLevel0="<img src=\"../gfx/ico_check.gif\" />" +" Anonymous";
 }
else if(csprImageRecordInfo.getCdcAccessLevelId().equals(new Integer(1)) ) {
  cdcAccessLevel1="<img src=\"../gfx/ico_check.gif\" />" +" Guest Registered";
 }
else if(csprImageRecordInfo.getCdcAccessLevelId().equals(new Integer(2)) ) {
  cdcAccessLevel2="<img src=\"../gfx/ico_check.gif\" />"+" Contract Registered";
 }
 else {
  cdcAccessLevel3="<img src=\"../gfx/ico_check.gif\" />"+" Not known";
  }
%>

<%
if(csprSoftwareTypeMetaDataNameV.contains("CDC_ACCESS_LEVEL_NAME") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Access Levels
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	
	<%=cdcAccessLevel0%>
	<%=cdcAccessLevel1%>
	<%=cdcAccessLevel2%>
	<%=cdcAccessLevel3%>
	
	<!--
         <%=cdcAccessLevel1%> Guest Registered
	 <%=cdcAccessLevel2%> Contract Registered
	 <%=cdcAccessLevel3%> Not known
        -->
        
 	</span></td>
</tr>
<% } %>

<%
if(csprSoftwareTypeMetaDataNameV.contains("SOURCE_LOCATION") ) {
%>
<tr bgcolor="#d9d9d9">
	<td align="left" valign="top"><span class="dataTableTitle">
	  Source Location
	</span></td>
	<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
	<% 
		String sourceLoc = (csprImageRecordInfo.getSourceLocation() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getSourceLocation())) 
							? csprImageRecordInfo.getSourceLocation() : ""; 	
	%>
	
          <%= sourceLoc %>
	</span></td>
</tr>
<% } %>

<!-- Strart Image Notes (URL) -------->
<% if(imageNotesInfo.getImageNotesLabel().length>0){%>
       <tr bgcolor="#d9d9d9">
       	<td align="left" valign="top" ><span class="dataTableTitle">
       	  Image URL
   	</span></td>
   	
   	
   	<td align="left" valign="top" bgcolor="#f5d6a4" >
   	          <table  bgcolor= "#f5d6a4" width="100%" class="dataTable">
   	               <tr bgcolor="#d9d9d9" cellspacing="1">
       				<td align="left" valign="top" ><span class="dataTableTitle">Image Label</span></td>
       				<td align="left" valign="top" ><span class="dataTableTitle">Image URL / Source Location</span></td>
       		       </tr>
       		       <% 
		                String[] imageLabel = imageNotesInfo.getImageNotesLabel();
				String[] imageURL = imageNotesInfo.getImageNotesURL();
				String[] imageSRC = imageNotesInfo.getImageNotesSRC();
				if(imageLabel!=null){
					for (int i=0; i<imageLabel.length; i++){
		          	
   			%>
       		       
       		       <tr bgcolor="#ffffff">
  	     		       
       		       	        <td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
   	          			<%=  imageLabel[i]  %>
   	          		</span></td>
   	          		<td bgcolor="#f5d6a4" align="left" valign="top"><span class="dataTableData">
   	          		 <% if ((imageURL[i] != null) && (!"".equals(imageURL[i]))) { %>
				   	 	<%= imageURL[i] %> 
				   	 <% } %>
				   	 <% if ((imageSRC[i] != null) && (!"".equals(imageSRC[i]))) { %> 
				   	 	SRC: <%=imageSRC[i]%> <% } %>
   	          		</span></td>
   	               </tr>
   	               <%}
   	               }%>
   	               </table>
   	</td>
   	
      </tr>
 <% } %> 




<!-- End Image Notes (URL) -------->


<!--tr bgcolor="#d9d9d9">
	<td align="left" valign="top" colspan="2"><span class="dataTableTitle">

	</span></td>
</tr-->

 <input name="osTypeId" value=<%=osTypeId%> type="hidden">
 <input name="osType" value=<%=osType%> type="hidden">
 <input name="releaseName" value="<%=csprImageRecordInfo.getReleaseName()%>" type="hidden">
 <input name="imageName" value="<%=csprImageRecordInfo.getImageName()%>" type="hidden">
 <input name="releaseNotesLabel" value="<%=csprImageRecordInfo.getImageName()%>" type="hidden">
		
</tbody></table>
      
  </td></tr>
  </tbody></table>
  </td></tr>
  </tbody></table>
 
 <br>
 
 <%
   if((isSoftwareTypePM ||spritAccessManager.isAdminSprit()) && !SpritUtility.isSoftwareTypeEndOfSupport(osTypeId.toString()) ) {
  %>
     <input type="submit" value="Edit" onClick="setAction('CsprImageEdit.jsp')">
     <input type="submit" value="Clone" onClick="setAction('CsprCreateMetaData.jsp')">
  <% } %>  
  <input name="monActionStr" value="SPRIT-6.6-CSCsc19024-NonIos Clone Feature ImageView" type="hidden">
  <input name="pageAction" value="clone" type="hidden">
<!-- start footer -->
<%= Footer.pageFooter(globals) %>
<!-- end of footer -->
<!-- end -->
</form></body></html>

