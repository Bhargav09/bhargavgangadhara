<!--.........................................................................
: DESCRIPTION:
: Admin Menu Page: Place to modify the platform, globals, Dram...
: Excel.
:
: AUTHORS:
: @author Vellachi Palaniappan (vpalani@cisco.com)
: @author Elliott Lee (tenchi@cisco.com)
: @author Kerri Patterson (kerrispa@cisco.com)
: CHANGES: (7/21/2003) ~ (kerrispa)
:	Added support for new columns (CCO Directory, Product Platform, EoS and EoL)
:
: @author Raju (rruddara@cisco.com)
: CHANGES: (12/10/2003) ~ (rruddara)
:	Added support for new column PCodeGroup and removed lot of hidden variables and
:   Improved performance.
:
: Copyright (c) 2003-2006, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page import="com.cisco.eit.shrrda.individualplatform.*" %>
<%@ page import="com.cisco.eit.shrrda.platformfamily.*" %>
<%@ page import="com.cisco.eit.sprit.dataobject.PlatformFamilyRowComparator" %>
<%@ page import="com.cisco.eit.sprit.logic.platformfacade.*" %>
<%@ page import="com.cisco.eit.sprit.model.erpPlatform.ERPPlatformModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.erpPlatform.ERPPlatformModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.erpPlatform.ERPPlatformModelLocal" %>
<%@ page import="com.cisco.eit.sprit.ui.PlatformSetupGUI" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.naming.NamingException"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%
  SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  String htmlButtonSubmit1;
  String htmlButtonSubmit2;
  String pathGfx;
  String servletMessages;
  
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  pathGfx = globals.gs( "pathGfx" );
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );

  // HTML macros
  htmlButtonSubmit1 = ""
      + SpritGUI.renderButtonRollover(
	  globals,
	  "btnSaveUpdates1",
	  "Save Updates",
	  "javascript:submitEditPlatform()",
	  pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
	  "actionBtnSaveUpdates('btnSaveUpdates1')",
	  "actionBtnSaveUpdatesOver('btnSaveUpdates1')"
	  );
  htmlButtonSubmit2 = ""
      + SpritGUI.renderButtonRollover(
	  globals,
	  "btnSaveUpdates2",
	  "Save Updates",
	  "javascript:submitEditPlatform()",
	  pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES,
	  "actionBtnSaveUpdates('btnSaveUpdates2')",
	  "actionBtnSaveUpdatesOver('btnSaveUpdates2')"
	  );
%>
<%= SpritGUI.pageHeader( globals,"Admin Menu","" ) %>
<%= banner.render() %>
<%
if( !((spritAccessManager.isAdminSprit()) || 
    (spritAccessManager.isAdminPdt()) || 
    (spritAccessManager.isAdminPlatformPMs()) || 
    (spritAccessManager.isAdminPlatformEditors()) ||
    (spritAccessManager.isAdminSWCenter())) ) {
  response.sendRedirect("ErrorAccessPermissions.jsp");
}  // if( !spritAccessManager.isAdminSprit() )
%>

<span class="headline">
  <align="center">Individual Platforms<align="center">
</span><br /><br />

<%
  // See if there were any messages generated
  servletMessages = (String)
    request.getAttribute( "Sprit.servMsg" );

  if( servletMessages!=null ) {
    PrintWriter printWriter;
    printWriter = response.getWriter();
    printWriter.print( ""
        + "<br />\n"
        + servletMessages 
        + "<br /><br />\n\n"
        );
  }  // if( servletMessages!=null )

  IndividualPlatformSessionHome mIndividualPlatformSessionHome = null;
  IndividualPlatformSession     mIndividualPlatformSession     = null;
  HashMap platformFamilies = new HashMap();
  HashMap ipMap = new HashMap(); 
 
  try {
    Context ctx = JNDIContext.getInitialContext();
    Object homeObject = ctx.lookup("IndividualPlatformSessionBean.IndividualPlatformSessionHome");
    mIndividualPlatformSessionHome = (IndividualPlatformSessionHome)PortableRemoteObject.narrow(homeObject, IndividualPlatformSessionHome.class);
    mIndividualPlatformSession = mIndividualPlatformSessionHome.create();
    platformFamilies = mIndividualPlatformSession.getAllPlatformFamilies();

  } catch(Exception e) {
    e.printStackTrace();
  }
  
 %> 
 
<script language="javascript"><!--
  // ==========================
  // CUSTOM JAVASCRIPT ROUTINES
  // ==========================
 
  //........................................................................  
  // DESCRIPTION:
  // Changes the up/over images if the form hasn't been submitted.
  //........................................................................  
  function actionBtnSaveUpdates(elemName) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES%>" );
  }
  function actionBtnSaveUpdatesOver(elemName) {
      setImg( elemName,"<%=pathGfx + "/" + SpritConstants.GFX_BTN_SAVE_UPDATES_OVER%>" );
  }
  
  function toUpper(objThisCtrl) 
  {
    objThisCtrl.value=objThisCtrl.value.toUpperCase();
  }

  function setPcode(obj, pcodeField) {
     document.getElementById(pcodeField).value = obj.value;
  }

  //........................................................................  
  // DESCRIPTION:
  // Submit the form.
  //........................................................................  

  function submitEditPlatform() {
    var formObj;
    var elements; 
    
    // Make a shortcut to our form's objects.
    formObj = document.forms['editIndividualPlatform'];
    elements = formObj.elements;   
    document.forms['editIndividualPlatform'].submit();
  }  

  function chooseFamily(obj, param) {  
       var value = "";
       for(var i=0; i < obj.options.length; i++) {
         if(obj.options[i].selected) {
           if(value == "") {
           } else {
             value += ",";
           }
	   value += obj.options[i].value;
         }
       }
       var url = param+"?"+obj.name+"="+escape(value);
       window.location = url;
  }  

//--></script>

<form action="IndividualPlatformProcessor" method="post" name="editIndividualPlatform" >
  <input type="hidden" name="callingForm" value="editIndividualPlatform">
  <input type="hidden" name="_submitformflag" value="0" />

<center>
<%       boolean warnRemove = false; 
         boolean warnUpdate = false; 
         boolean warnAdd = false; 
%>
  
  <%

  ArrayList updateList = (ArrayList)request.getAttribute("updateList");	
  ArrayList addList = (ArrayList)request.getAttribute("addList");	
  ArrayList validUpdates = new ArrayList();
  ArrayList validRemoves = new ArrayList();
  ArrayList validAdds = new ArrayList();

  HashMap inUse = new HashMap();
  HashMap icHash = new HashMap();

  Boolean TRUE = new Boolean(true);
  ArrayList removeList = (ArrayList)request.getAttribute("removeList");	
  String pti = request.getParameter("platformTotalIndex");
  int platformTotalIndex = (pti == null) ? 0 : Integer.parseInt(request.getParameter("platformTotalIndex"));


  if (addList!=null && addList.size()>0)  {


          String paramPlatformName = request.getParameter("addIndividualPlatform") ;
          boolean nameInUse = mIndividualPlatformSession.nameInUse(paramPlatformName);
            if(nameInUse) { 
                warnAdd = true ; 
            } else {
                validAdds.add(paramPlatformName);
            }
   }

  if (removeList!=null && removeList.size()>0)  {
       for(int nIndex=1 ; nIndex <= platformTotalIndex; nIndex++ ) {
          String INDIVIDUAL_PLATFORM_OLD_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_OLD_NAME";
          String paramOldPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME);
          String paramSelectDelete = request.getParameter("_"+nIndex+ "DELETE" ) == null ? "notchecked" : "checked" ;	
          if(!paramSelectDelete.equals("notchecked")) {
             Integer imagecount = mIndividualPlatformSession.getImageCount(paramOldPlatformName);          
             if(imagecount.intValue()>0) {
              warnRemove = true ; 
             } else {
              validRemoves.add(paramOldPlatformName);
              String DELETE = "_"+nIndex+ "DELETE";
             }
          }
       }
    }

  if (updateList!=null && updateList.size()>0)  {

       for(int nIndex=1 ; nIndex <= platformTotalIndex; nIndex++ ) {
          String INDIVIDUAL_PLATFORM_OLD_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_OLD_NAME";
          String INDIVIDUAL_PLATFORM_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_NAME";
          String paramOldPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME);
          String paramPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_NAME);
          String paramSelectDelete = request.getParameter("_"+nIndex+ "DELETE" ) == null ? "notchecked" : "checked" ;	
          Integer imagecount = mIndividualPlatformSession.getImageCount(paramOldPlatformName);          
          boolean nameInUse = mIndividualPlatformSession.nameInUse(paramPlatformName);
          if(paramSelectDelete.equals("notchecked") && !paramOldPlatformName.equals(paramPlatformName)) {
            if(nameInUse) { 
               inUse.put(paramOldPlatformName, paramPlatformName) ; 
                warnUpdate = true ; 
            }	
            if(imagecount.intValue()>0) {
                warnUpdate = true ; 
                icHash.put(paramOldPlatformName,imagecount);
            }
        
            if(!nameInUse&&imagecount.intValue()==0) {
               validUpdates.add(paramOldPlatformName);
            }
          }
      }
  }

  if(!warnRemove&&!warnUpdate&&!warnAdd) { %>    
  <%= htmlButtonSubmit1 %><br />
  <% } else { %>
<table>
<% }
  if( TRUE.equals((Boolean)request.getAttribute("confirmationNeeded") ) && (
    ( request.getAttribute("addList")   !=null && ((ArrayList)request.getAttribute("addList")).size()    > 0 ) ||
    ( request.getAttribute("removeList")!=null && ((ArrayList)request.getAttribute("removeList")).size() > 0 ) ||
    ( request.getAttribute("updateList")!=null && ((ArrayList)request.getAttribute("updateList")).size() > 0 ) )) {

     %> <input type="hidden" name="confirmed" value="true"> 

<%
        if(warnAdd) { 
%>
     <table><tr><td>
       <span class="summaryWarning">The platform name selected for addition is already in use.</span><p>

     </td></tr></table>
     <table border="0" cellpadding="1" cellspacing="0">
        <tr><td bgcolor="#3D127B">
          <table border="0" cellpadding="0" cellspacing="0">
           <tr><td bgcolor="#BBD1ED">
             <table  cellpadding="3" cellspacing="1" >
               <tr bgcolor="#d9d9d9"><td class="dataTableTitle">New Individual Platform</td></tr>
               <tr bgcolor="#ffffff"><td align="center"><span class="dataTableData"><%=request.getParameter("addIndividualPlatform")%></span></td></tr>




</table>
</td></tr></table>
</td></tr></table>

<% } %>

<%
        if(warnUpdate) { 

%>
     <table>
<% if(!icHash.isEmpty()) { %>
<tr><td>
       <span class="summaryWarning">Some of the platforms marked for modification (renaming) have images associated
          with them. Modifying these platforms may have downstream implications (eg, in Feature Navigator), and is therefore NOT allowed. 
          If this platform really should be removed, then it needs to be implemented manually. For assistance, please open a case at <a href="<%=SpritConstants.SRM_CASE_OPEN_LINK%>" target=\"_blank\"><%=SpritConstants.SRM_CASE_OPEN_LINK%></a>
          to request this change.</span><p>

</td></tr>
<% } %>

<% if(!inUse.isEmpty()) { %>
<tr><td>
       <span class="summaryWarning">Some of the platforms marked for modification (renaming) can not be modified due to the fact that the selected new name is already in use.</span><p>

</td></tr>
<% } %>

</table>


     <table border="0" cellpadding="1" cellspacing="0">
        <tr><td bgcolor="#3D127B">
          <table border="0" cellpadding="0" cellspacing="0">
           <tr><td bgcolor="#BBD1ED">
             <table  cellpadding="3" cellspacing="1" ><tr bgcolor="#d9d9d9"><td colspan="3" align="center" class="dataTableTitle">Individual Platforms Selected for Modification</td>
            <tr bgcolor="#F5D6A4"><td colspan="1" class="dataTableTitle">Existing Individual Platform Name</td>
                <td colspan="1" class="dataTableTitle">Modified Individual Platform Name</td>
                <td colspan="1" class="dataTableTitle">Reason it can not be modified</td></tr>
<%  
           for(int nIndex=1 ; nIndex <= platformTotalIndex; nIndex++ ) {
              String INDIVIDUAL_PLATFORM_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_NAME";
              String INDIVIDUAL_PLATFORM_OLD_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_OLD_NAME";
              String INDIVIDUAL_PLATFORM_ID = "_"+nIndex+ "INDIVIDUAL_PLATFORM_ID";
              String paramIndividualPlatformName  = request.getParameter( INDIVIDUAL_PLATFORM_NAME ) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_NAME);
              String paramIndividualPlatformId =  request.getParameter(INDIVIDUAL_PLATFORM_ID) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_ID);
              String paramOldIndividualPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME);
              String paramSelectDelete = request.getParameter("_"+nIndex+ "DELETE" ) == null ? "notchecked" : "checked" ;	
              if(!paramIndividualPlatformName.equals(paramOldIndividualPlatformName)&&!"".equals(paramOldIndividualPlatformName)&&paramSelectDelete.equals("notchecked")) {

                  if(inUse.get(paramOldIndividualPlatformName)!=null || (icHash.get(paramOldIndividualPlatformName) != null)) {
%>
              <tr bgcolor="#FFFFFF"><td  align="center"><span class="dataTableData"><%=paramOldIndividualPlatformName%></span></td>
                                    <td  align="center"><span class="dataTableData"><%=paramIndividualPlatformName%></span></td>
<%            
              if(inUse.get(paramOldIndividualPlatformName)!=null && (icHash.get(paramOldIndividualPlatformName) == null)) {
%>                                    <td  align="center"><span class="dataTableData">platform name already in use</span></td> <%
              }
              if(inUse.get(paramOldIndividualPlatformName)!=null && (icHash.get(paramOldIndividualPlatformName) != null)) {
%>                                    <td  align="center"><span class="dataTableData">platform name already in use and platform has images mapped to it</span></td> <%
              }
              if(inUse.get(paramOldIndividualPlatformName)==null && (icHash.get(paramOldIndividualPlatformName) != null)) {
             %>                       <td  align="center"><span class="dataTableData">platform has images mapped to it</span></td> 
             <% } %>
              </tr>
          
<%               }
               } 
            }
         } 
%>


     </table></td></tr></table></td></tr></table>

<br>



<%

        if(warnRemove) { 
%>
     <table><tr><td>
       <span class="summaryWarning">Some of the platforms marked for deletion still have images associated
          with them. If you really mean to delete these platforms, please open a case at <a href="<%=SpritConstants.SRM_CASE_OPEN_LINK%>" target=\"_blank\"><%=SpritConstants.SRM_CASE_OPEN_LINK%></a>
          and request that the images be deleted.</span><p>

</td></tr></table>


     <table border="0" cellpadding="1" cellspacing="0">
        <tr><td bgcolor="#3D127B">
          <table border="0" cellpadding="0" cellspacing="0">
           <tr><td bgcolor="#BBD1ED">
             <table  cellpadding="3" cellspacing="1" >

               <tr><td bgcolor="#d9d9d9" class="dataTableTitle">Individual Platform Selected for Deletion</td></tr>
     
     <% 
          
           for(int nIndex=1 ; nIndex <= platformTotalIndex; nIndex++ ) {
              String INDIVIDUAL_PLATFORM_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_NAME";
              String INDIVIDUAL_PLATFORM_OLD_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_OLD_NAME";
              String INDIVIDUAL_PLATFORM_ID = "_"+nIndex+ "INDIVIDUAL_PLATFORM_ID";
              String paramIndividualPlatformName  = request.getParameter( INDIVIDUAL_PLATFORM_NAME ) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_NAME);
              String paramIndividualPlatformId =  request.getParameter(INDIVIDUAL_PLATFORM_ID) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_ID);
              String paramOldIndividualPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME);
              String paramSelectDelete = request.getParameter("_"+nIndex+ "DELETE" ) == null ? "notchecked" : "checked" ;	
              if(!paramSelectDelete.equals("notchecked") && !validRemoves.contains(paramOldIndividualPlatformName)) {
%>
              <tr bgcolor="#FFFFFF"><td align="center"><span class="dataTableData"><%=paramOldIndividualPlatformName%></span></td>
              </tr>

<%            }
          }
%>
         </table></td></tr></table></td></tr></table></td></tr></table><br>

      <% } %>

     <% if(!validUpdates.isEmpty() ||!validRemoves.isEmpty()||!validAdds.isEmpty()) { 
        if(!warnRemove&&!warnUpdate&&!warnAdd) {%>
     <p><b>Please Confirm the following changes</b></p>
     <% } else { %>
<hr>
     <p><b>The following changes <i>are</i> allowed. Please confirm just these changes by clicking below.</b></p>

     <% } %>
     <%      if (!validAdds.isEmpty())  { %>

     <table border="0" cellpadding="1" cellspacing="0">
        <tr><td bgcolor="#3D127B">
          <table border="0" cellpadding="0" cellspacing="0">
           <tr><td bgcolor="#BBD1ED">
             <table  cellpadding="3" cellspacing="1" >
               <tr bgcolor="#d9d9d9"><td class="dataTableTitle">New Individual Platform</td></tr>
               <tr bgcolor="#ffffff"><td align="center"><span class="dataTableData"><%=request.getParameter("addIndividualPlatform")%></span></td></tr>

<input type="hidden" name="addIndividualPlatform" value="<%=validAdds.get(0)%>">

         </table></td></tr></table></td></tr></table><br>
     <% } %>

     <%      if (!validRemoves.isEmpty())  { %>
     <table border="0" cellpadding="1" cellspacing="0">
        <tr><td bgcolor="#3D127B">
          <table border="0" cellpadding="0" cellspacing="0">
           <tr><td bgcolor="#BBD1ED">
             <table  cellpadding="3" cellspacing="1" >

               <tr><td bgcolor="#d9d9d9" class="dataTableTitle">Individual Platform Selected for Deletion</td></tr>
     
     <% 
          
           for(int nIndex=1 ; nIndex <= platformTotalIndex; nIndex++ ) {
              String INDIVIDUAL_PLATFORM_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_NAME";
              String INDIVIDUAL_PLATFORM_OLD_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_OLD_NAME";
              String INDIVIDUAL_PLATFORM_ID = "_"+nIndex+ "INDIVIDUAL_PLATFORM_ID";
              String DELETE = "_"+nIndex+ "DELETE";

              String paramIndividualPlatformName  = request.getParameter( INDIVIDUAL_PLATFORM_NAME ) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_NAME);
              String paramIndividualPlatformId =  request.getParameter(INDIVIDUAL_PLATFORM_ID) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_ID);
              String paramOldIndividualPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME);
              String paramSelectDelete = request.getParameter( DELETE ) == null ? "notchecked" : "checked" ;	
              if(!paramSelectDelete.equals("notchecked") && validRemoves.contains(paramOldIndividualPlatformName)) {
%>
               <input type="hidden" name="<%=DELETE%>" value="<%=request.getParameter(DELETE)%>">
              <tr bgcolor="#FFFFFF"><td align="center"><span class="dataTableData"><%=paramOldIndividualPlatformName%></span></td>
<input type="hidden" name="<%=INDIVIDUAL_PLATFORM_NAME%>" value="<%=paramIndividualPlatformName%>">
<input type="hidden" name="<%=INDIVIDUAL_PLATFORM_OLD_NAME%>" value="<%=paramOldIndividualPlatformName%>">
<input type="hidden" name="<%=INDIVIDUAL_PLATFORM_ID%>" value="<%=paramIndividualPlatformId%>">
<input type="hidden" name="<%=DELETE%>" value="<%=request.getParameter(DELETE)%>">

              </tr>

<%            }
          }
      }

%>
         </table></td></tr></table></td></tr></table></td></tr></table><br>
<% } %>
<% if(!validUpdates.isEmpty()) { %>
     <table border="0" cellpadding="1" cellspacing="0">
        <tr><td bgcolor="#3D127B">
          <table border="0" cellpadding="0" cellspacing="0">
           <tr><td bgcolor="#BBD1ED">
             <table  cellpadding="3" cellspacing="1" ><tr bgcolor="#d9d9d9"><td colspan="2" align="center" class="dataTableTitle">Individual Platforms Selected for Modification</td>
            <tr bgcolor="#F5D6A4"><td colspan="1" class="dataTableTitle">Existing Individual Platform Name</td>
                <td colspan="1" class="dataTableTitle">Modified Individual Platform Name</td>


<%
           for(int nIndex=1 ; nIndex <= platformTotalIndex; nIndex++ ) {
            String INDIVIDUAL_PLATFORM_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_NAME";  
            String INDIVIDUAL_PLATFORM_OLD_NAME = "_"+nIndex+ "INDIVIDUAL_PLATFORM_OLD_NAME";
            String DELETE = "_"+nIndex+ "DELETE";
            String paramOldIndividualPlatformName = request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_OLD_NAME);
              if(!validUpdates.contains(paramOldIndividualPlatformName)) { continue; }
              String INDIVIDUAL_PLATFORM_ID = "_"+nIndex+ "INDIVIDUAL_PLATFORM_ID";
              String paramIndividualPlatformName  = request.getParameter( INDIVIDUAL_PLATFORM_NAME ) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_NAME);
              String paramIndividualPlatformId =  request.getParameter(INDIVIDUAL_PLATFORM_ID) == null ? "" : request.getParameter(INDIVIDUAL_PLATFORM_ID);

              String paramSelectDelete = request.getParameter(DELETE) == null ? "notchecked" : "checked" ;	
              if(!paramIndividualPlatformName.equals(paramOldIndividualPlatformName)&&!"".equals(paramOldIndividualPlatformName)&&paramSelectDelete.equals("notchecked")) {
%>
              <tr bgcolor="#FFFFFF"><td  align="center"><span class="dataTableData"><%=paramOldIndividualPlatformName%></span></td>
                                    <td  align="center"><span class="dataTableData"><%=paramIndividualPlatformName%></span></td>

              </tr>
<input type="hidden" name="<%=INDIVIDUAL_PLATFORM_NAME%>" value="<%=paramIndividualPlatformName%>">
<input type="hidden" name="<%=INDIVIDUAL_PLATFORM_OLD_NAME%>" value="<%=paramOldIndividualPlatformName%>">
<input type="hidden" name="<%=INDIVIDUAL_PLATFORM_ID%>" value="<%=paramIndividualPlatformId%>">



<%          
               }
               } 
%>         </table></td></tr></table></td></tr></table></td></tr></table><br> <%
            }
      String pfid = request.getParameter("pfid");
           %>

            <input type="hidden" name="platformTotalIndex" value="<%=pti%>">
            <input type="hidden" name="pfid" value="<%=pfid%>">

   <%

   } else {
      ArrayList pfNames = new ArrayList(platformFamilies.keySet());	
      Collections.sort(pfNames);
      Iterator pfIt = pfNames.iterator();
      String strReqPfId = request.getParameter("pfid");
      %> 

      <table border="0"><tr>
      <td><span class="dataTableTitle">Platform Family Name</span></td><td><select name="pfid" onChange="chooseFamily(this,'IndividualPlatformSetupEdit.jsp')"><%

        if(strReqPfId==null||  strReqPfId.equals("-1")) {
        %> <option value="-1" selected>-- select one --</option><%
        }
      while(pfIt.hasNext()) {
        String name = (String)pfIt.next();
        Integer pfId = (Integer)platformFamilies.get(name);
        
        if(strReqPfId!=null && strReqPfId.equals(""+pfId)) {
        %> <option value="<%=pfId%>" selected><%=name%></option><%
        } else {
        %> <option value="<%=pfId%>" ><%=name%></option> <%
        }
      } %>
      </select></td></tr><tr><td>&nbsp</td><td>&nbsp</td></tr>

    <tr><td colspan="2" width="100%">
       <table border="0" width="100%" cellpadding="1" cellspacing="0">
       <tr><td bgcolor="#3D127B">
         <table border="0" cellpadding="0" width="100%" cellspacing="0">
         <tr><td bgcolor="#BBD1ED">
            <table border="0" width="100%" cellpadding="3" cellspacing="1">
            <tr bgcolor="#d9d9d9">
	    <td align="center" valign="top"><span class="dataTableTitle">
         	  Delete
	    </span></td>
	     <td align="center" valign="top"><span class="dataTableTitle">
	     Existing Individual Platform Name
           </span></td>
     	<td align="center" valign="top"><span class="dataTableTitle">
	  New Individual Platform Name
	</span></td></tr>
      <tr bgcolor="#F5D6A4">

	<td align="center" valign="top"><img src="../gfx/b1x1.gif" /></td>
	<td align="center" valign="top"><img src="../gfx/b1x1.gif" /></td>
	<td align="left" valign="top" nowrap><span class="dataTableData">
           Add
	  <img src="../gfx/ico_arrow_right_orange.gif" />

          <input type="text" name="addIndividualPlatform" size="32" value="" />
	</span></td>


	</tr>

    <%  int indx = 0;
       if(request.getParameter("pfid")!=null) {
       Integer pfId = new Integer(request.getParameter("pfid"));
       ipMap = mIndividualPlatformSession.getAllIndividualPlatforms(pfId);    
       ArrayList ipNames = new ArrayList(ipMap.keySet());	
       Collections.sort(ipNames);
       Iterator ipIt = ipNames.iterator();

       while(ipIt.hasNext()) {
         indx++;
         String name = (String)ipIt.next();
         Integer ipId = (Integer)ipMap.get(name);

         %> <tr bgcolor="#ffffff">
                <td align="center" valign="top" bgcolor="#F6E8DO"><span class="dataTableData">
                   <input type="checkbox" name="_<%=indx%>DELETE" value=""/></span></td>
                <td align="center" valign="top"><span class="dataTableData"><%=name%></span></td>
                <td align="center" valign="top"><span class="dataTableData">
                   <input type="hidden" name = "_<%=indx%>INDIVIDUAL_PLATFORM_ID" value="<%=ipId%>"/>
                   <input type="hidden" name = "_<%=indx%>INDIVIDUAL_PLATFORM_OLD_NAME" value="<%=name%>"/>
                   <input type="test" name = "_<%=indx%>INDIVIDUAL_PLATFORM_NAME" value="<%=name%>"/></span></td></tr>

                
       <% } } %> </table></td></tr></table></td></tr></table></td></tr></table> 
       <input type="hidden" name="platformTotalIndex" value="<%=indx%>">
  <br />
<% } %>

<% if(!validUpdates.isEmpty()||!validRemoves.isEmpty()||!validAdds.isEmpty()) { %>
  <%= htmlButtonSubmit2 %>
<% } %>
  
  </center>
</form>


<%= Footer.pageFooter(globals) %>
<!-- end -->
