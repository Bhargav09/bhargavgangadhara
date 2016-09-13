<!--.........................................................................
: DESCRIPTION:
:
: AUTHORS:
: @author Selvaraj Aran (aselvara@cisco.com)
: @author Kelly Hollingshead (kellmill) CSCsc19024, modified for clone function.
:
: Copyright (c) 2005-2007 by Cisco Systems, Inc.
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
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>

<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.Collection" %>
<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.HashMap" %>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.Iterator" %>

<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprImageDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.model.csprjdbc.CsprSoftwareTypeMetaDataJdbc" %>
<%@ page import="com.cisco.eit.sprit.dataobject.CsprImageRecordInfo" %>
<%@ page import="com.cisco.eit.sprit.model.csprimagemdf.*"%>
<%@ page import="com.cisco.eit.sprit.model.csprmachineostype.*"%>
<%@ page import = "com.cisco.eit.sprit.logic.managmentMetadata.ManagementMetadataHelper" %>


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
  String   imageName                        = "";
  
  
  String 			htmlButtonDeleteImages1 = "";
  
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  spritAccessManager = (SpritAccessManager) globals.go( SpritConstants.ACCESS_MANAGER );

  nonIosCcoPostHelper = new NonIosCcoPostHelper();
  String strMode = nonIosCcoPostHelper.getMode(request);
  

  //System.out.println(" STEP1   ");
  
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
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }

  if(osType == null || osType.equals("")) {
   // No os type!  Bad! Redirect to error page.
    response.sendRedirect(NonIosCcoPostHelper.NO_OS_TYPE_ID_URL);
  }
  
  filterReleaseNumber = StringUtils.elimSpaces(WebUtils.getParameter(request,"filterReleaseNumber"));
  filterImageName     = StringUtils.elimSpaces(WebUtils.getParameter(request,"filterImageName"));
  releaseNumber       = SpritUtility.replaceString(filterReleaseNumber,"*","");
  imageName           = SpritUtility.replaceString(filterImageName,"*","");
  if ( filterReleaseNumber == null || "".equals( filterReleaseNumber ) )
    	filterReleaseNumber = "*";
    if ( filterImageName == null || "".equals( filterImageName ) )
  	filterImageName = "*";
  
   System.out.println("Release Number in CsprDeleteImage.jsp page is "+releaseNumber);
  System.out.println("filterReleaseNumber in CsprDeleteImage.jsp page is "+filterReleaseNumber);

  
  isSoftwareTypePM = spritAccessManager.isSoftwareTypePM(osTypeId); 

  if (!isSoftwareTypePM && !NonIosCcoPostHelper.MODE_VIEW.equalsIgnoreCase(strMode)) {
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

  // html macros
  String pathGfx = globals.gs( SpritConstants.PATH_GFX );
  htmlButtonDeleteImages1 = SpritGUI.renderButtonRollover(
      	globals,
      	"btnDeleteImages1",
      	"Delete Images",
      	"javascript:validateAndsubmitForm('CsprDeleteImage')",
      	pathGfx + "/" + "btn_delete_checked.gif",
      	"setImg('btnDeleteImages1','" + pathGfx + "/" + "btn_delete_checked.gif" + "')",
      	"setImg('btnDeleteImages1','" + pathGfx + "/" + "btn_delete_checked_over.gif" + "')"
      	);
	

%>

<form name="softwareSelection" action="<%= globals.gs("currentPage")  %>" method="get">
<%= SpritGUI.pageHeader( globals,"mmd","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getOSTypeTabs(globals,"mmd") %>
<%
  SpritSecondaryNavBar secNavBar =  new SpritSecondaryNavBar( globals );
 %>
 </form>
<form action="CsprImageProcessor" name="CsprDeleteImage" method="post">
<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript">
<!--
// ==========================
// CUSTOM JAVASCRIPT ROUTINES
// ==========================

//---
  //........................................................................
  // DESCRIPTION:
  //     Submits this form and checks for errors.
  //
  // INPUT:
  //     formName (string): Name of the form to submit.
  //........................................................................
  function validateAndsubmitForm(formName) {
    var formObj;
    var elements;  
    
    formObj = document.forms[formName];
    var errormsg = "Choose at least one Image to be deleted and Click Delete Checked";
    var error = true;
    
    elements = formObj.elements;
       
       for (i=0; i<formObj.totalImages.value; i++) {
         var imageDelete = "_"+i+"imageDelete";
           if(!(formObj.elements[imageDelete]==undefined)){
           //alert("deletebvalue is "+imageDelete);
             if(formObj.elements[imageDelete].checked == true) {
               error = false;
             if( formObj.elements['_submitFormFlag'].value=="1" ) {
               return;
             } 
             formObj.elements['_submitFormFlag'].value="1";
             formObj.submit();
           }
          }
          
       }  
       if(error) {
         alert(errormsg);
       }
       else {    
         formObj.submit();
       }
    
  } 

function changeSoftwareType() {
   document.softwareSelection.submit();
   return true;
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
    //popupWindow.focus();

} // function popup

-->
</script>

<table border="0" cellpadding="3" cellspacing="0" width="100%">
  <tr bgcolor="#BBD1ED">
    <td valign="middle" width="70%" align="left">
      <%
    secNavBar.addFilters(
            "filterReleaseNumber", filterReleaseNumber, 12,
            pathGfx+"/"+"release_number.gif",
            "Sorry, no Help available.",
            "Release Number filter"	//CSCsi59809
            );
    secNavBar.addFilters(
                "filterImageName", filterImageName, 22,
                pathGfx+"/"+"filter_label_imgname.gif",
                "Sorry, no Help available.",
                "Image Name filter"	//CSCsi59809
         );
    
    if(isSoftwareTypePM ||spritAccessManager.isAdminSprit() ) {
        if (SpritUtility.isProductizationSupportedBySoftwareType(osType)) {
            out.println(SpritGUI.renderTabContextNav(
                    globals,secNavBar.render( new boolean [] {true,false,true,true},
                           new String [] { "Create","Delete", "View All", "Productization" },
                           new String [] { "CsprCreateMetaData.jsp?osTypeId=" + osTypeId,
                                           "CsprDeleteImage.jsp?osTypeId=" + osTypeId,
                                           "CsprImageViewAll.jsp?osTypeId=" + osTypeId,
                                           "ProductizationEdit.jsp?osTypeId=" + osTypeId}
                           ))); 
        } else {
            out.println(SpritGUI.renderTabContextNav(
                    globals,secNavBar.render( new boolean [] {true,false,true},
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

  

<font size="+1" face="Arial,Helvetica"><b>
<center>
  
  Delete Image
</center>
</b></font>


<input name="callingForm" value="CsprDeleteImage" type="hidden">
<input name="fromWhere" value="View" type="hidden">
<input name="_submitFormFlag" value="0" type="hidden">
 
<!-- start here -->
<center>
 <table>
   <tr> 
     <td> 
        <%= htmlButtonDeleteImages1 %>
     </td>
   </tr>	   
  </table>



<table border="0" cellpadding="1" cellspacing="0">
  <tbody><tr><td bgcolor="#3d127b">
    <table border="0" cellpadding="0" cellspacing="0">
    <tbody><tr><td bgcolor="#bbd1ed">
      <span class="dataTableData">
      </span><table border="0" cellpadding="3" cellspacing="1">
      <tbody><tr bgcolor="#d9d9d9">
        <td align="center" valign="top"><span class="dataTableTitle">
	 Delete</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  		Release Number</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  		Image Name</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	 		MDF Based Cisco Product</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
	  		Image Description</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  		Software Advisory</span></td>
   	<td align="center" valign="top"><span class="dataTableTitle">
   	  		Deferred</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  		CCO Post</span></td>
 	<td align="center" valign="top"><span class="dataTableTitle">
   	  Post date</span></td>
	<td align="center" valign="top"><span class="dataTableTitle">
   	  </span></td>
     </tr>
     
     <% 

        Iterator csprImageRecordsVector = null;
      	Collection csprImageRecordsColl = null;
      	CsprImageRecordInfo csprImageRecordInfo = null;
     
      	
      	Collection csprImageMdfRecordsColl =null;      
      	
      	HashMap  machineOsTypeNameHmap;
      	int imageIndex=0;
      	
      	try
               {
                csprImageRecordsColl = CsprImageDataJdbc.getAllCsprImageRecord(osTypeId,releaseNumber,imageName, null, null);
                ArrayList csprImageRecordsArray = new ArrayList(csprImageRecordsColl);
                
                if (csprImageRecordsColl.size() < 1) {
                 System.out.println("No Records found  for this search ");
                }
                if (csprImageRecordsArray != null) {
                	csprImageRecordsVector = csprImageRecordsArray.iterator();
     	    while (csprImageRecordsVector.hasNext()) {
                    csprImageRecordInfo = (CsprImageRecordInfo) csprImageRecordsVector.next();
                    
                    //System.out.println("ImageName is  "+csprImageRecordInfo.getImageName());
%>

    <tr bgcolor="#ffffff">
    <td align="left" valign="top" width="4%"><span class="dataTableData">
    
    <% if("Y".equalsIgnoreCase(csprImageRecordInfo.getIsPostedToCco() )) { %>
    <img src="<%= pathGfx+"/"+"txt_posted_mini.gif" %>">
    <%}else if(ManagementMetadataHelper.getImageIdsWithValidPcode(osTypeId).contains(csprImageRecordInfo.getImageId())){%>
    Product code record exists
    <% } 
     else {%>
      <input type="checkbox" name="<%="_"+imageIndex+"imageDelete"%>" value="D">
     <% } %>
    <input type="hidden" name="<%="_"+imageIndex+"imageId"%>" value="<%= csprImageRecordInfo.getImageId()  %>">
    
    <td align="left" valign="top" width="10%"><span class="dataTableData">
		  <%=csprImageRecordInfo.getReleaseName()%> </span></td>
	
	 
    <td align="left" valign="top" width="10%"><span class="dataTableData">
		  <%=csprImageRecordInfo.getImageName()%> </span></td>
				  
    <td align="left" valign="top"><span class="dataTableData">
		 
		
		
		<%
		
		try{
		  machineOsTypeNameHmap = csprImageRecordInfo.getMdfConceptName();
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
    <td align="left" valign="top" width=25%><span class="dataTableData">
	<%
		String imgDesc = (csprImageRecordInfo.getImageDescription() != null && !"null".equalsIgnoreCase(csprImageRecordInfo.getImageDescription())) 
						? csprImageRecordInfo.getImageDescription() : "";
	%>
    <%= imgDesc  %></span></td>

    <td align="center" valign="top" width="5%"><span class="dataTableData">
		 <% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsSoftwareAdvisory()) ){ %>
		            <img src="../gfx/ico_check.gif" /> 
		         <% } else { %>
		            <img src="../gfx/ico_cross.gif" />
        <% } %>
		  
    </span></td>
    <td align="center" valign="top" width="5%"><span class="dataTableData">
		  <% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsDeferred()) ){ %>
		  	 <img src="../gfx/ico_check.gif" /> 
		  	<% } else { %>
		  	 <img src="../gfx/ico_cross.gif" />
        <% } %>
		  
		  
    </span></td>
    <td align="center" valign="top" width="5%"><span class="dataTableData">
		 <% if ("Y".equalsIgnoreCase(csprImageRecordInfo.getIsPostedToCco()) ){ %>
		 		  	 <img src="../gfx/ico_check.gif" /> 
		 		  	<% } else { %>
		 		  	 <img src="../gfx/ico_cross.gif" />
		         <% } %>
		  
		  
		  </span></td>
 <%
      String ccoPostedTime= "";      
      if(csprImageRecordInfo.getCcoPostedTime()!=null && !"null".equals(csprImageRecordInfo.getCcoPostedTime().toString()))  ccoPostedTime= csprImageRecordInfo.getCcoPostedTime().toString();
%>
    <td align="center" valign="top" width="10%"><span class="dataTableData">
		  <%=ccoPostedTime%></span></td>

    <td align="center" valign="top" width="10%"><span class="dataTableData">
        <a href="CsprImageView.jsp?osTypeId=<%=csprImageRecordInfo.getOsTypeId()%>&releaseName=<%= csprImageRecordInfo.getReleaseName() %>&imageName=<%= csprImageRecordInfo.getImageName()  %>">
        View</a>
      <%      
       if(isSoftwareTypePM ||spritAccessManager.isAdminSprit() ) {
           String monActionStr = "SPRIT-6.6-CSCsc19024-NonIos Clone Feature DeleteImage";
      %>  
       <a href="CsprImageEdit.jsp?osTypeId=<%=csprImageRecordInfo.getOsTypeId()%>&releaseName=<%= csprImageRecordInfo.getReleaseName() %>&imageName=<%= csprImageRecordInfo.getImageName()  %>">
         Edit</a>
         
       <a href=
         "CsprCreateMetaData.jsp?osTypeId=<%=csprImageRecordInfo.getOsTypeId()%>
         &releaseName=<%= csprImageRecordInfo.getReleaseName() %>
         &imageName=<%= csprImageRecordInfo.getImageName()  %>
         &monActionStr=<%=monActionStr%>">
         Clone</a>
      <% } %>  

      </span>
     </td>

     </tr>
   
   <% 
      imageIndex++;
      }//end of while loop
                     }//end of if statement
                    } catch (Exception e) {
                     System.out.println(" Exception in CsprImageViewAll.jsp" );
                     e.printStackTrace();
      }
               
   %>   
   
      
    <input name="osTypeId" value=<%=osTypeId%> type="hidden">
    <input name="totalImages" value=<%=csprImageRecordsColl.size()%> type="hidden">
         
    </tbody></table>
    </td></tr></tbody></table></td></tr></tbody></table>
    <br>
        <!-- <input type="submit" value="Delete"> -->
        
        <table>
	   <tr> 
	     <td> 
	        <%= htmlButtonDeleteImages1 %>
	     </td>
	   </tr>	   
	  </table>
	</center>
	

    <!-- start footer -->
    <%= Footer.pageFooter(globals) %>
    <!-- end of footer -->

<!-- end -->
</form></body></html>

