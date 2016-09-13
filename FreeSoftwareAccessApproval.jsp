<!--
.........................................................................
: DESCRIPTION:
: CSCsv02690   Develop financial control View User Interface 
: CREATION DATE:
: 11/13/2008, sprit 7.4

: AUTHORS:
: @author Akshay Buradkar (aburadk@cisco.com)
:
: Copyright (c) 2008, 2010 by Cisco Systems, Inc.
:.........................................................................
-->

<%@ page import="java.lang.Integer" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.sql.Timestamp"%>

<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.rtim.util.StringUtils" %>
<%@ page import="com.cisco.eit.sprit.util.SpritUtility" %>
<%@ page import="com.cisco.eit.sprit.model.spritproperties.*" %>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<%@ page import="com.cisco.eit.sprit.utils.FreeSwApprovalQueryUtil"%>
<%@ page import="javax.ejb.CreateException" %>
<%@ page import="javax.ejb.EJBException" %>
<%@ page import="javax.ejb.FinderException" %>
<%@ page import="javax.ejb.SessionBean" %>
<%@ page import="javax.ejb.SessionContext" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="com.cisco.eit.sprit.model.cspraccesslevelapproval.CsprAccessLevelApprovalLocal" %>
<%@ page import="com.cisco.eit.sprit.model.cspraccesslevelapproval.CsprAccessLevelApprovalLocalHome" %> 
<%@ page import="com.cisco.eit.sprit.util.JNDIContext" %>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>
<%@ page import="com.cisco.eit.sprit.util.SpritPropertiesUtil" %>
<%@ page import = "com.cisco.eit.sprit.controller.NonIosCcoPostHelper" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="java.util.Vector" %>

<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  SpritAccessManager spritAccessManager;
  boolean               isAdminControllerForOs = false;
  boolean               isAdminSprit = false;
  boolean               isCurrentUserInApproverList = false;
  String                userId = null;
  Map					freeSwMap = new HashMap();
  List 					freeSwApproverTypes = null;
  NonIosCcoPostHelper   nonIosCcoPostHelper = null;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);   
 
  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",SpritGUI.renderReleaseNumberNav(globals,null));
  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  
  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);

  SpritAccessManager acc = (SpritAccessManager) globals.go( "accessManager" );
  userId =  acc.getUserId();
  if(acc.isAdminSprit()){
	  isAdminSprit = true;
	  isCurrentUserInApproverList = true;
  }
  
  freeSwApproverTypes =  SpritPropertiesUtil.getFreeSwApproverTypes();
  nonIosCcoPostHelper = new NonIosCcoPostHelper();

  MonitorUtil monUtil = new MonitorUtil();
  monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "Free Software Financial control View User Interface");
  MonitorUtil.cesMonitorCall("SPRIT-7.4-CSCsv02690-Develop financial control View User Interface");
 
  String action ="default";
  if(request.getParameter("action")!=null)
		  action =(String)request.getParameter("action");
%>

<style>
.small{
	font-size:85%;
}
.dataTablein {
	border:none;
	border-collapse: collapse;
}

.dataTablein td {
  border-style: solid;
  border-color: #BBD1ED;
  border-width: 1px;  
  color: #000000;
  font-family: Arial;
  font-weight: normal;
  font-size: 85%;
  letter-spacing: 0.0em;	
}

.dataTableNoBrd{
  border-style: solid;
  border-color: #FFFFFF;
  border-width: 1px;
}


</style>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript" src="../js/prototype.js"></script>

<SCRIPT language="javascript">
    //to get unique div name everytime
	var index = 1;
	
	function actionBtnSaveImages(elemName){
	    setImg( elemName,"../gfx/btn_save_updates.gif" );
    }
    
	function actionBtnSaveImagesOver(elemName) {
	  	setImg( elemName,"../gfx/btn_save_updates_over.gif" );
	}
   
    function validateAndSubmitForm(){
		var submitFlag = true;

		if(checkApproverIdType()){
		  submitFlag = false;
		}

		if(submitFlag){
			if(checkDupApproverName()){
				submitFlag = false;
			}
		}

		if(submitFlag){
			document.editform.submit();
		}
  	}

	function checkApproverIdType(){
		  var eform = document.forms[0];
		  var freeSwAppId1 = eform['freeSwAppId'];
  		  var freeSwAppType1 = eform['freeSwAppType'];
  		  var freeSwOsTypeName1 = eform['freeSwOsTypeName'];
  		  var freeSwAppComments1 = eform['freeSwAppComments'];
  		
  		  var newAppId1 = eform['newAppId'];

		  for(var i=2;i < freeSwAppId1.length; i++){
			  var appId = trimBlankSpace(freeSwAppId1[i].value);
  			  var appType = trimBlankSpace(freeSwAppType1[i].value);
  			  var appComments = trimBlankSpace(freeSwAppComments1[i].value);
  			
  			  var newAppId = trimBlankSpace(newAppId1[i].value);
  			  
			  if(appId.length == 0){
				   alert("Free Software Approver Id is blank for Software type '"+freeSwOsTypeName1[i].value+"'. Please specify.");
				   return true;
			  }
			  else{
				  if(newAppId=='Y' && !isUserIdValid(appId)){
					  alert("Free Software Approver Id '"+appId+"' for Software type '"+freeSwOsTypeName1[i].value+"' is not a valid CISCO user id. Please verify.");
					  return true;
				  }
			  }
			  if(appType.length == 0){
				   alert("Please select Free Software Approver Type for Software type '"+freeSwOsTypeName1[i].value+"' and Approver '"+appId+"'.");
				   return true;
			  }
			  if(appComments.length>=250){
				   alert("Approver Comment for Software type '"+freeSwOsTypeName1[i].value+"' and Approver '"+appId+"' should be less than 250 characters.");
				   return true;
			  }
		  }
		  return false;
	}

	function checkDupApproverName(){
		var eform = document.forms[0];
		var freeSwAppIds1 = eform['freeSwAppId'];
		var freeSwOsTypeName1 = eform['freeSwOsTypeName'];
		var sameOs = false;
		
		for(var i=2;i < freeSwAppIds1.length; i++){
			var appId1 = trimBlankSpace(freeSwAppIds1[i].value);
			var osType1 = trimBlankSpace(freeSwOsTypeName1[i].value);

			for(var j=i+1;j < freeSwAppIds1.length; j++){
				var osType2 = trimBlankSpace(freeSwOsTypeName1[j].value);

				if(osType1==osType2){
					sameOs = true;
					var appId2 = trimBlankSpace(freeSwAppIds1[j].value);

					if((appId1.length > 0 && appId2.length > 0) && (appId1 == appId2)){
						alert("Duplicate Free Software Approver Id '"+appId2+"' in Software Type '"+osType1+"'. Please verify.");
						return true;
					}
				}else{
					if(sameOs){
						break;
					}
				}
			}
		}
		return false;
	 }

	
	function delFreeSwRow(vrow){
		var vdelrow = vrow.parentNode.parentNode;
		var vtbody = vdelrow.parentNode.parentNode;
		vtbody.deleteRow(vdelrow.rowIndex);
	}
	
	function addFreeSwRow(vtable,blkOsTypeId,osTypeName){

		var newRow = vtable.insertRow(-1);
		
		//div to identify it uniquely and update it
		var div_id = blkOsTypeId + "sel" + index;		
		index++;
		
		var newCell = newRow.insertCell(-1);
		newCell.width = "22%";
		newCell.innerHTML = "<span class=\"dataTableData\">"
		    + "<input type=\"hidden\" name=\"freeSwOsTypeName\" value=\""+osTypeName+"\"/>"
		    + "<input type=\"hidden\" name=\"freeSwOsTypeId\" value=\""+blkOsTypeId+"\"/>"
			+ "<Select name=\"freeSwAppType\" class=\"small\"  onchange=\"onChangeApproverTypeDropDown('"+div_id+"', this.options[this.selectedIndex].value,'"+blkOsTypeId+"');\">"+
			+ "<option selected></option>"
			<%
				Iterator itFreeSwApprTypeMetaDataJs = freeSwApproverTypes.iterator();
				while(itFreeSwApprTypeMetaDataJs.hasNext()){
					List apprTypeMetaDataJs = (List)itFreeSwApprTypeMetaDataJs.next();
					String apprTypeJs = (String)apprTypeMetaDataJs.get(0);
					%>
						+ "<option value=\"<%=apprTypeJs%>\"><%=apprTypeJs%></option>"
					<%
				}
			%>
			 + "</Select></span>";
	
		var newCell = newRow.insertCell(-1);
		newCell.width = "15%";
		//newCell.valign = "top";
		newCell.innerHTML =  "<div id = '"+ div_id +"'>"+
		                     "<input type=\"hidden\" name=\"newAppId\" value=\"Y\">"+
							 "<input class=\"small\"  name=\"freeSwAppId\" size=\"10\" type=\"text\" onchange=\"onChangeTrackOsId('"+blkOsTypeId+"');\">"+ 
							 "</div>";		
			 
		var newCell = newRow.insertCell(-1);
		newCell.width = "12%";
		newCell.innerHTML = "<input type=\"hidden\" name=\"freeSwAppStatus\" value=\"pending\"/>"  
			+ "<span class=\"dataTableData\">&nbsp;&nbsp;&nbsp;<font style=\"color:#ff0000;\"><i>pending</i></span>";

		var newCell = newRow.insertCell(-1);
		newCell.width = "12%";
		newCell.innerHTML =  "<span class=\"noData\">&nbsp;</span>";

		var newCell = newRow.insertCell(-1);
		newCell.width = "29%";
		newCell.innerHTML = "<input type=\"hidden\" name=\"freeSwAppComments\" value=\"\"/>"  
			+ "<span class=\"noData\">&nbsp;</span>";
		
		var newCell = newRow.insertCell(-1);
		newCell.width = "10%";
		newCell.align = "center";
		newCell.innerHTML =  "<input class=\"small\"  type=\"button\" value=\"Delete\" onclick=\"javascript:delFreeSwRow(this);\">";
	}

	function trimBlankSpace(str){
		return str.replace(/^\s*/, "").replace(/\s*$/, "");
	}
	
	function onChangeTrackOsId(osId){
		var eform = document.forms[0];
		var lastOsModified = eform['lastOsModified'];
		lastOsModified.value=osId;
		return false;	
	}

   function onChangeApproverTypeDropDown(div_id, selectedApproverType, blkOsTypeId){
        
        //if corporate revenue is selected, display drop down
        if(selectedApproverType == "Corporate Revenue"){
        
        	document.getElementById(div_id).innerHTML = "<span class=\"dataTableData\">"
		    + "<input type=\"hidden\" name=\"newAppId\" value=\"Y\"/>"
		    + "<Select name=\"freeSwAppId\" class=\"small\" onchange=\"onChangeTrackOsId('"+blkOsTypeId+"');\">"
			+ "<option selected></option>"
			<%
				Vector corporateRevenueRole = (Vector) spritAccessManager.getRoleUserIds("corporateRevenue");
		        Iterator corporateRevenueRoleIterator = corporateRevenueRole.iterator();
		        while(corporateRevenueRoleIterator.hasNext()){
		   
		        String corporateRevenue = (String)corporateRevenueRoleIterator.next();
			%>
				+ "<option value=\"<%=corporateRevenue%>\"><%=corporateRevenue%></option>"
			<%
				}
		    %>
			 + "</Select></span>";
        }else{
           //display edit box
           document.getElementById(div_id).innerHTML =   "<input type=\"hidden\" name=\"newAppId\" value=\"Y\">"+
							 "<input class='small'  name='freeSwAppId' size='10' type='text' onchange='onChangeTrackOsId('"+blkOsTypeId+"');'>";
		}
        
        //Change track os id
        return onChangeTrackOsId(blkOsTypeId);
	}
   
</SCRIPT>

<FORM name=editform method=POST action="FreeSoftwareApprovalProcessor">
<%= SpritGUI.pageHeader( globals,"Sprit Access Level Approval","" ) %>

<%= banner.render() %>
<br>
<span class="headline">
      <%if(action.equalsIgnoreCase("edit")){  %>
      		&nbsp;Edit - Access Level 'Free Software' approval section on Cisco.com
      <%}else {%>
      		View - Access Level 'Free Software' approval section on Cisco.com
      <%} %>
</span>
<center>
<%if(action.equalsIgnoreCase("edit")){%>
	<%try{
		Context ctx = JNDIContext.getInitialContext();
		CsprAccessLevelApprovalLocal apprBean = null;
		CsprAccessLevelApprovalLocalHome home = (CsprAccessLevelApprovalLocalHome)ctx.lookup("ejblocal:CsprAccessLevelApprovalBean.CsprAccessLevelApprovalHome");
		Collection freeSwApprCollection = (Collection)home.findAllFreeSwAppr();
		if(freeSwApprCollection!=null && freeSwApprCollection.size() > 0){
			Iterator itAppr = freeSwApprCollection.iterator();
	 		while(itAppr.hasNext()){
	 			apprBean = (CsprAccessLevelApprovalLocal)itAppr.next();
	 			Integer osTypeIdMap = apprBean.getOsTypeId();
	 			String osTypeNameMap = nonIosCcoPostHelper.getOSType(osTypeIdMap);
	 			List freeSwList;
	 			if(freeSwMap.containsKey(osTypeNameMap)){
	 				freeSwList = (List)freeSwMap.get(osTypeNameMap);
	 				freeSwList.add(apprBean);
	 			}else{
	 				freeSwList = new ArrayList();
	 				freeSwList.add(apprBean);
	 			}
	 			freeSwMap.put(osTypeNameMap,freeSwList);
	 		}
		}
      }catch (Exception e){
        e.printStackTrace();
        throw new EJBException();
      }	   
 	%>
	
	<div id="groupRegApprDiv">
	  <br><br>
	  	<input type="hidden" value="" name="lastOsModified"/>
	    <table class="dataTable" style="table-layout:fixed;" width="90%">
   		<tbody>
   		<tr align="center" bgcolor="#d9d9d9">
   			<td valign="top" width="15%">
   				<span class="dataTableTitle">Software<br/>Type</span>
   			</td>
			<td valign="top" width="73%">
				<table style="table-layout:fixed;" width="100%" cellpadding=0 cellspacing=0 >
					<tr align="center" bgcolor="#d9d9d9">
						<td valign="top" width="22%">
							<input type="hidden" value="" name="freeSwOsTypeId"/>
							<input type="hidden" value="" name="freeSwOsTypeId"/>
							<input type="hidden" value="" name="freeSwOsTypeName"/>
							<input type="hidden" value="" name="freeSwOsTypeName"/>
							<input type="hidden" value="" name="freeSwAppId"/>
							<input type="hidden" value="" name="freeSwAppId"/>
							<input type="hidden" value="Y" name="newAppId"/>
							<input type="hidden" value="Y" name="newAppId"/>
							<input type="hidden" value="" name="freeSwAppType"/>
							<input type="hidden" value="" name="freeSwAppType"/>
							<input type="hidden" value="" name="freeSwAppStatus"/>
							<input type="hidden" value="" name="freeSwAppStatus"/>
							<input type="hidden" value="" name="freeSwAppComments"/>
							<input type="hidden" value="" name="freeSwAppComments"/>
							<span class="dataTableTitle">Approver<br/>Type</span>
						</td>
						<td valign="top" width="13%">
							<span class="dataTableTitle">Approver<br/>Id</span>
						</td>
						<td valign="top" width="12%">
							<span class="dataTableTitle">Approval<br/>Status</span>
						</td>
						<td valign="top" width="12%">
							<span class="dataTableTitle">Approve/<br/>Reject Date</span>
						</td>
						<td valign="top" width="31%">
							<span class="dataTableTitle">Approver<br/>Comments</span>
						</td>
						<td valign="top" width="10%">
							<span class="dataTableTitle">Delete<br/>Approver</span>
						</td>
					</tr>
				</table>
			</td>
   			<td valign="top" width="8%">
   				<span class="dataTableTitle">Add<br/>Approver</span>
   			</td>
   		</tr>
		</tbody>
		 	<%try {
		 		CsprAccessLevelApprovalLocal apprBean = null;
		 		String osTypeName = null;
		 		Integer osTypeId = null;
		 		String approverId = null;
		 		String approverType = null;
		 		String approvalStatus = null;
		 		Timestamp approvalDateTs = null;
		 		String approvalDate = null;
		 		String approverComments = null;
				int freeSwMapCnt = 0;

		 		
		 		Iterator itFreeSwMap = freeSwMap.keySet().iterator();
		 		
		 		while(itFreeSwMap.hasNext()){
					freeSwMapCnt++;
		 			osTypeName = (String)itFreeSwMap.next();
		 			List freeSwList = (List)freeSwMap.get(osTypeName);
		 			
		 			//Set BU Finance/Controller accesses
		 			isAdminControllerForOs = false;
		 			if(isAdminSprit){
		 				isAdminControllerForOs = true;
		 			} 
		 			else{
			 			Iterator freeSwListIt = freeSwList.iterator();
			 			while(freeSwListIt.hasNext()){
			 				apprBean = (CsprAccessLevelApprovalLocal)freeSwListIt.next();
			 				
			 				Iterator itFreeSwApprTypeMetaData = freeSwApproverTypes.iterator();
							while(itFreeSwApprTypeMetaData.hasNext()){
								List apprTypeMetaData = (List)itFreeSwApprTypeMetaData.next();
								String apprType = (String)apprTypeMetaData.get(0);
								String apprAdminContoller = (String)apprTypeMetaData.get(1);

								if(userId.equals(apprBean.getApproverId())
				 						&& apprType.equals(apprBean.getApproverType())
				 						&& "Y".equals(apprAdminContoller)){
				 					isAdminControllerForOs = true;
				 					isCurrentUserInApproverList = true;
				 					break;
				 				}
							}
			 			}
		 			}

		 			int freeSwListSize = 0;
		 			if(freeSwList!=null){
		 				freeSwListSize = freeSwList.size();
		 			}
					
		 			boolean isRowStatusUpdatable = false;
		 			
		 			for(int i=0;i < freeSwListSize; i++ ){
		     			apprBean = (CsprAccessLevelApprovalLocal)freeSwList.get(i);
		     			osTypeId = apprBean.getOsTypeId();
		     			approverId = apprBean.getApproverId();
		     			approverType = apprBean.getApproverType();
		     			approvalStatus = apprBean.getStatus();
		     			approvalDateTs = apprBean.getApprovalDate();
		     			if(approvalDateTs!=null){
		     				approvalDate = approvalDateTs.toString().substring(0,10);
		 				}else{
		 					approvalDate = "";
		 				}
		     			approverComments = apprBean.getApprovalComment();
						boolean isRowDeletable = false;
						boolean isRowUpdatableByUser = false;
						if("pending".equals(approvalStatus)){
							isRowDeletable = true;
						}
						if(userId.equals(approverId)){
							isRowUpdatableByUser = true;
							isCurrentUserInApproverList = true;
						}
						if(i==0){
							if(!FreeSwApprovalQueryUtil.checkFreeSwImageExistsForOS(osTypeId)){
								isRowStatusUpdatable = true;
							}
		     			%>
							<tbody id="tbody<%=i%>">
		     				<tr 
							<%if(freeSwMapCnt%2==0){%>
							style="background-color: #FFFFFF;"
							<%}else{%>
							style="background-color: #f0f0f0;"
							<%}%>
							>
								<td>
									<span class="dataTableData">
									<a name="os<%=osTypeId%>"><%=osTypeName%></a>
									</span>
								</td>
								<td>
									<table class="dataTablein" style="table-layout:fixed;" id="tb<%=osTypeId%>" width="100%">
						<%}%>
							<tr>
	     					<td width="22%">
								<input type="hidden" name="freeSwOsTypeId" value="<%=osTypeId%>"/>
								<input type="hidden" name="freeSwOsTypeName" value="<%=osTypeName%>"/>
								<input type="hidden" name="freeSwAppId" value="<%=approverId%>"/>
								<input type="hidden" name="newAppId" value="N"/>
									     					
								<span class="dataTableData">
								<%if(isAdminControllerForOs && (isRowDeletable || isRowStatusUpdatable)){%>
									<Select name="freeSwAppType"  class="small" onchange="onChangeTrackOsId('<%=osTypeId%>');">
										<%
										Iterator itFreeSwApprTypeMetaData = freeSwApproverTypes.iterator();
										while(itFreeSwApprTypeMetaData.hasNext()){
											List apprTypeMetaData = (List)itFreeSwApprTypeMetaData.next();
											String apprType = (String)apprTypeMetaData.get(0);%>
											<option value="<%=apprType%>"
											<%if(apprType.equals(approverType)){%>
												selected
											<%}%>
											><%=apprType%></option>
										<%}%>
									</Select>
								<%}else{%>
									<input type="hidden" name="freeSwAppType" value="<%=approverType%>"/>
									<%=approverType%>
								<%}%>
								</span>
	     					</td>
	     					<td width="13%">
								<span class="dataTableData">
	     						&nbsp;<%=approverId%>
								</span>
	     					</td>
	     					<td width="12%">
								&nbsp;<span class="dataTableData"><i>
								<%if((isRowUpdatableByUser || isAdminSprit) && (isRowDeletable || isRowStatusUpdatable)){
									String approveStat = "";
									String rejectStat = "";
									String pendingStat = "";
									if("approved".equals(approvalStatus)){
										approveStat = "selected";
									}else if("rejected".equals(approvalStatus)){
										rejectStat = "selected";
									}else{
										pendingStat = "selected";
									}
								%>
									<Select name="freeSwAppStatus" class="small" onchange="onChangeTrackOsId('<%=osTypeId%>');">
										<%if(isRowDeletable){%>
											<option value="pending" <%=pendingStat%>></option>
										<%}%>
										<option value="approved" <%=approveStat%>>Approve</option>
										<option value="rejected" <%=rejectStat%>>Reject</option>
									</Select>
	     						<%}else{%>
	     							<input type="hidden" name="freeSwAppStatus" value="<%=approvalStatus%>"/>
									<%if(isRowDeletable){%>
	     								<font style="color:#ff0000;"><%=approvalStatus%></font>
		     						<%}else{%>
		     							<%=approvalStatus%>
			 						<%}
									}%></i>
								</span>
	     					</td>
	     					<td width="12%">
								<span class="dataTableData">
	     						&nbsp;<%=approvalDate%>
								</span>
	     					</td>
	     					<td width="31%">
									<%if(approverComments==null || "null".equals(approverComments)){
		     								approverComments = "";
		     							}%>
								<span class="dataTableData">
								<%if((isRowUpdatableByUser || isAdminSprit) && (isRowDeletable || isRowStatusUpdatable)){%>
									<textarea rows="3" cols="20" name="freeSwAppComments" onchange="onChangeTrackOsId('<%=osTypeId%>');"><%=approverComments%></textarea>
								<%}else{%>
									
									<input type="hidden" name="freeSwAppComments" value="<%=approverComments%>"/>
		     						&nbsp;<%=approverComments%>
								<%}%>
								</span>
	     					</td>
	     					<td width="10%" align="center">
	     						<input class="small" type="button" value="Delete" onclick="javascript:delFreeSwRow(this);" 
								<%if(!isAdminControllerForOs || !isRowDeletable){%>
									 disabled
								<%}%>/>
	     					</td>
							</tr>
						<%if(i==(freeSwListSize-1)){%>
						</table>
						</td>
						<td valign="top" align="center">
     						<input class="small" type="button" value="  Add  " onclick="javascript:addFreeSwRow(tb<%=osTypeId%>,'<%=osTypeId%>','<%=osTypeName%>');"
							<%if(!isAdminControllerForOs){%>
								 disabled
							<%}%>/>
						</td>
						</tr>
						</tbody>
		     		<%}
		 			}
		 		}
		 	}catch (Exception e)   {
	            e.printStackTrace();
	            throw new EJBException();
	        }	     	
	     %>
		</table>
		<br><br>
	   </div>	
		
		<%if(isCurrentUserInApproverList){%>
			<table>
			<tr>
			   <td align="right">
			      <IMG onmouseover="actionBtnSaveImagesOver('btnSaveUpdates2')"
					onclick="javascript:validateAndSubmitForm()"
				    onmouseout="actionBtnSaveImages('btnSaveUpdates2')" alt="Save Updates"
				    src="../gfx/btn_save_updates.gif" border=0 name=btnSaveUpdates2>
			    </td>
			  </tr>
			</table>
		<%}%>
	<%}%>
</center>

<%= Footer.pageFooter(globals) %>
<!-- end -->
