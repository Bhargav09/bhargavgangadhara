<!--
.........................................................................
: DESCRIPTION:
: QOT AdminQOTIdentify UI 

: CREATION DATE:
: 03/09/09, sprit 7.5  CSCsx21579

: AUTHORS:
: @author Holly Chen (holchen@cisco.com)
:
: Copyright (c) 2009-2010 by Cisco Systems, Inc.
:.........................................................................
-->

<%@ page import="java.lang.Integer" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.TreeSet" %>
<%@ page import="java.util.Set" %>
<%@ page import = "java.util.Map" %>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "java.util.Date" %> 
<%@ page import = "java.util.HashSet" %>

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
<%@ page import="com.cisco.eit.sprit.dataobject.CsprSoftwareTypePM" %>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.dataobject.OrderabilityVo"%>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<%@ page import="com.cisco.eit.sprit.util.QueryUtil"%>
<%@ page import="com.cisco.eit.sprit.util.exceptions.DataBaseException"%>
<%@ page import="com.cisco.eit.sprit.dataobject.QotImageInfoVo"%>
<%@ page import="com.cisco.eit.sprit.dataobject.SwRetirementSearchCriteriaVo"%>



<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  SpritAccessManager    spritAccessManager;
  boolean               isSoftwareTypePM    = false;
  String lineNumber ="0";
 //String type = (String)request.getParameter("type");
  String type = "";
  //String mode = "SAVE";
  String expandReleaseNumberId = "0";
    
  // Initialize globals  
  globals = SpritInitializeGlobals.init(request,response);
  //TODO: check for Admin access here
  //SpritAccessManager acc = (SpritAccessManager) globals.go( "accessManager" );
  //String userId =  acc.getUserId();
 
  // Set up banner for later
    banner =  new SpritGUIBanner( globals );
    banner.addContextNavElement( "REL:",
        SpritGUI.renderReleaseNumberNav(globals,null)
      );
 
%>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="javascript" src="../js/prototype.js"></script>
<script type="text/javascript" src="../js/datetimepicker.js">
	//Date Time Picker script- by TengYong Ng of http://www.rainforestnet.com
	//Script featured on JavaScript Kit (http://www.javascriptkit.com)
	//For this script, visit http://www.javascriptkit.com 
	</script>
<SCRIPT type=text/javascript>
  //........................................................................
  // DESCRIPTION:
  // Changes the up/over images if the form "hasn't" been submitted.
  //........................................................................

  function actionBtnSaveImages(elemName) {
    setImg( elemName,"../gfx/btn_save_updates.gif" );
  }
  function actionBtnSaveImagesOver(elemName) {
    setImg( elemName,"../gfx/btn_save_updates_over.gif" );
  }
	  	
  	function checkboxSelectAllHere(name) {		
		
	//for (var i=0; i<document.ccoPost.length; i++) {
			//document.ccoPost.elements[i].checked='true';
	//}
	var x=document.getElementsByName(name);
	if(x!=null) {
		for (var count=0; count<x.length; count++) {
			x[count].checked=true;
		}
	}
	}

	function checkboxSelectNoneHere(name) {
		var x=document.getElementsByName(name);
		if(x!=null) {
		for (var count=0; count<x.length; count++) {
			x[count].checked=false;
		}
	}
   }//Method	
  	
  	function view(){
  	        var flag = true;
  			document.getElementById("action").value = "view";
  			if ( document.optOutForm.osTypeId.disabled == true || document.optOutForm.osTypeId.value == "" ) {
  	            msg = "Please select software Type";
  	            flag = false;
  	        }  
  	        if(!flag)
  	       		alert(msg);
  	    	if(flag)
  				document.optOutForm.submit();
  	}
   	
  	//var int i = 0;
  	function submit(index){
  	    var flag = true;
  	    //alert(index);
  	    //document.getElementById("lineNumber").value= index;
  	    //document.qotIdentifyForm.submit();
  	    var name = "imageInfo_" + index;
  	    alert(name);
  	    document.getElementById(name).innerHTML ="<tr><td colspan="+ "21"  +">Test</b><td></tr>";
   	}
   	
  
   	
   	function expandRelease(index, expandReleaseNumberId){
   		document.getElementById("type").value="expandRelease";
   		document.getElementById("expandReleaseNumberId").value = expandReleaseNumberId;
   		document.getElementById("expandReleaseIndex").value = index;
   		document.qotIdentifyForm.submit();
   	}
   	
   	function go(){
   		document.getElementById("type").value="go";
   		document.qotIdentifyForm.submit();
   	
   	}
   	
   	//for reset button to reset search criteria value at top
   	function reset(){
  		var releaseTrainSelect = document.getElementById('releaseTrain');
  		releaseTrainSelect.selectedIndex = -1;
  		var branchNameSelect = document.getElementById('branchName');
  		branchNameSelect.selectedIndex = -1;
  		var trainTypeSelect = document.getElementById('trainType');
  		trainTypeSelect.selectedIndex = -1;
  		var releaseNumberSelect = document.getElementById('releaseNumber');
  		releaseNumberSelect.selectedIndex = -1;
  		var postingTypeSelect = document.getElementById('postingType');
  		postingTypeSelect.selectedIndex = -1;
  		var fromDateSelect = document.getElementById('fromDate');
  		fromDateSelect.value='';
  		///var toDateSelect = document.getElementById('toDate');
  		// toDateSelect.value='';
  		var statusSelect = document.getElementById('status');
  		statusSelect.value='';
  	}
  	
  	function getExcelReport(){
		// document.location = "go?action=qotidentify&type=getExcelReport&mode=report";
		document.getElementById("type").value="getExcelReport";
   		document.qotIdentifyForm.submit();
    }
  
</SCRIPT>  





<FORM name= qotIdentifyForm method=POST action="go?action=qotidentify">

<%= SpritGUI.pageHeader( globals,"Sprit Admin QOT Identify","" ) %>

<%= banner.render() %>



  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
        <td valign="middle" width="70%" align="left">
          <table border="0" cellpadding="2" cellspacing="0" width="100%">
<tr bgcolor="#BBD1ED"><td align="left">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td><img src="../gfx/b1x1.gif" height="1" width="16" /></td>
  <td align="left"><table border="0" cellpadding="3" cellspacing="0">
<tr>
  <td valign="middle" align="left"><span class="tabNavTitle">Choose<br />mode</span></td>
  <td valign="middle"><img src="../gfx/ico_arrow_right_hollow.gif" /></td>
  <td valign="middle"><nobr>
  <span class="tabNavData"><span class="tabNavData"><a href="go?action=qotidentify" id="tabNavLink">Identify</a></span><span class="tabNavMiniDivider"> | </span></span>
  <span class="tabNavData"><span class="tabNavData"><a href="go?action=qotidentify&mode=Submit" id="tabNavLink">Submit</a></span><span class="tabNavMiniDivider"> | </span></span>
  <span class="tabNavData"><span class="tabNavData"><a href="go?action=qotidentify&mode=Execute" id="tabNavLink">Execute</a></span><span class="tabNavMiniDivider"> | </span></span>
  <span class="tabNavLinkActive"><span class="tabNavData">Report</span><span class="tabNavMiniDivider"> | </span></span>
  </nobr></td>
</tr>
</table>
</td>
  <td><img src="../gfx/b1x1.gif" height="1" width="16" /></td>
</tr>
</table>
</td></tr>
</table>


         </td>
      </tr>
   </table>

<!--
  <center><br/>
<font size="+1" face="Arial,Helvetica"><b><center>
    Software Retirement Identify</b>

</center> 
</font>

<br>
-->



<input type="hidden" name="type"  id="type" value="<%=type%>" >
<input type="hidden" name="lineNumber"  id="lineNumber" value="<%=lineNumber%>" >
<input type="hidden" name="expandReleaseNumberId"  id="expandReleaseNumberId" value=<%=expandReleaseNumberId %>>
<input type="hidden" name="expandReleaseIndex"  id="expandReleaseIndex" >
<input type="hidden" name="mode"  id="mode" value="report" >

		

<table><tr><td>

 <table border="1" width="100%" style="font: 12px Arial; border-collapse: collapse; border: 0.2em solid #BBD1ED ">
     <tbody>
         <tr bgcolor="#d9d9d9" >
           		<td  align="center" ><span class="dataTableTitle">Train Type <br> &nbsp</span></td>
           		<td  align="center" ><span class="dataTableTitle">Release Train <br> &nbsp</span></td>
	     		<td  align="center" ><span class="dataTableTitle">Release Branch <br> &nbsp</span></td>
	     		<td  align="center" ><span class="dataTableTitle">Release Number  <br> &nbsp</span></td>
	     		<td  align="center" ><span class="dataTableTitle">CCO Post Date  <br> &nbsp</span></td>
	     		<td  align="center" ><span class="dataTableTitle">Posting Type  <br> &nbsp</span></td>
	     </tr>
        
	    <tr>
	       	  
	       	  <td class="dataTableData" align="center" >
	       	    <Select name="trainType" id = "trainType" multiple="multiple" size="6" STYLE="width: 150px">
	  				<option value='mailline'>MAINLINE</option>
	  				<option value='cted'>CTED</option>
	  				<option value='sted'>STED</option>
	  				<option value='xed'>XED</option>
	  				<option value='pi'>PI</option>
	  			</Select>
	  			</td>	
	  			
	  			
	  		 <%
	  		 SwRetirementSearchCriteriaVo  searchVo =(SwRetirementSearchCriteriaVo)request.getAttribute("searchCriteria"); 
	  		 Set trainSet = searchVo.getReleaseTrain();
	  		 Iterator trainSetIterator = trainSet.iterator();
	  		 //List releaseTrainList = (List)request.getAttribute("releaseTrain"); 
	  		   List selectedTrainList = (List)request.getAttribute("releaseTrainSelected");%>
	  		 <td class="dataTableData" align="center">
	       			<Select name="releaseTrain" id="releaseTrain"  multiple="multiple" size="6" STYLE="width: 200px" >
	  					
	  					<% 
	  					  while (trainSetIterator.hasNext()){
	  					  String train = trainSetIterator.next().toString();
	  					 %>  				
	  						<option value= '<%= train %>'  
	  						<%if(selectedTrainList!=null && selectedTrainList.contains(train)){ %> selected <%} %>>
	  						<%= train %></option>
	  					<%}%>
	  				</Select>
	  		  </td>		
	       
	       	  <% 
	       	  	 //List branchNameList = (List)request.getAttribute("branchNameList"); 
	       	     Set branchSet = searchVo.getReleaseBranch();
	       	     Iterator branchSetIterator = branchSet.iterator();
	       	     List selectedBranchList = (List)request.getAttribute("branchNameSelected");%>
	       	  <td class="dataTableData" align="center" >
	       	    	<Select name="branchName" id = "branchName" multiple="multiple" size="6" STYLE="width: 200px">
	  				<% while (branchSetIterator.hasNext()){  
	  				   String branchName = branchSetIterator.next().toString() ;%>  
	  					<option value= '<%=branchName %>' 
	  					<%if (selectedBranchList!=null && selectedBranchList.contains(branchName)){%> selected <%} %> >
	  					<%=branchName%></option>
 	  			   <%} %>
 	  			   </Select>
	  		 </td>	
	  			  	
	  	 	<% //List releaseNumberList = (List)request.getAttribute("releaseNumberList"); 
	  	 	   List selectedReleaseNumberList = (List)request.getAttribute("releaseNumberSelected");
	  	 	   Set releaseNumberSet = searchVo.getReleaseNumber();
       	       Iterator releaseNumberSetIterator = releaseNumberSet.iterator(); 
	  	 	   %>
	  	 	<td class="dataTableData" align="center" >
			       	<Select name="releaseNumber" id="releaseNumber"  multiple="multiple" size="6" STYLE="width: 200px">
			  			<% while (releaseNumberSetIterator.hasNext()){  
			  					String releaseNumber = releaseNumberSetIterator.next().toString(); %> 
			  					<option value='<%=releaseNumber %>'
			  					<%if(selectedReleaseNumberList!=null && selectedReleaseNumberList.contains(releaseNumber)){ %> selected <%} %> >
			  					<%= releaseNumber%></option>
			  			<%} %>
			  			</select>
			  			
			</td>
			  
			<td align="center" valign="top" rowspan=1 NOWRAP>
               <span class="dataTableTitle">&nbsp</span><br>
                <span class="dataTableTitle">From : </span>
                <span class="dataTableData">
                   <input id="fromDate" name="fromDate" type="text" size="20" value="<%=request.getAttribute("fromDate") %>" onFocus="this.blur()" />
     		 <a href="javascript:NewCal('fromDate','ddmmmyyyy',true,12)" onmouseover="window.status='Date Picker';return true;"
     		  	onmouseout="window.status='';return true;">
     		 	<img src="../gfx/calendar.gif" width=24 height=22 border=0 align="absmiddle" valign="middle">
     		 </a> 
     		 <span class="dataTableTitle">&nbsp</span><br>
     		 <br>    
     		   <span class="dataTableTitle">To &nbsp&nbsp&nbsp&nbsp: </span>
                <span class="dataTableData">
                   <input id="toDate" name="toDate" type="text" size="20" value="<%=request.getAttribute("toDate") %>" onFocus="this.blur()" />
     		 <a href="javascript:NewCal('toDate','ddmmmyyyy',true,12)" onmouseover="window.status='Date Picker';return true;"
     		  	onmouseout="window.status='';return true;">
     		 	<img src="../gfx/calendar.gif" width=24 height=22 border=0 align="absmiddle" valign="middle">
     		 </a>              
         	</span>
         	</td>
			   <td class="dataTableData" align="center" >
			  	       		<Select name="postingType" id="postingType" multiple="multiple" size="6" STYLE="width: 200px">
			  	  			<%List postingTypeSelected =  (List)request.getAttribute("postingTypeSelected");%>	
			  	  					<option value= 'Split CCO Only' 
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("Split CCO Only")){ %> selected <%} %>>Split CCO Only</option>
			  	  				
			  	  					<option value= 'Split CCO and MFG'
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("Split CCO and MFG")){ %> selected <%} %>>Split CCO and MFG</option>
			  	  				
			  	  					<option value= 'CCO and MFG'
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("CCO and MFG")){ %> selected <%} %>>CCO and MFG</option>
			  	  				
			  	  					<option value= 'CCO Only'
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("CCO Only")){ %> selected <%} %>>CCO Only</option>
			  	  				
			  	  					<option value= 'Hidden Post CCO Only'
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("Hidden Post CCO Only")){ %> selected <%} %>>Hidden Post CCO Only</option>
			  	  				
			  	  					<option value= 'Hidden Post MFG Only'
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("Hidden Post MFG Only")){ %> selected <%} %>>Hidden Post MFG Only</option>
			  	  				
			  	  					<option value= 'IOSXE IOS Non Posting'
			  	  					<%if(postingTypeSelected!=null && postingTypeSelected.contains("IOSXE IOS Non Posting")){ %> selected <%} %>>IOSXE IOS Non Posting</option>
		  	  		</select> 
 			</span></td>
		</tr>	
	  	</tbody>
	  </TABLE> 	
</td>
</tr></table>

<table class="dataTable" valign="top" align="left">
<tr>
    <td><table>
      <TBODY>
       <tr bgcolor="#d9d9d9" >
           		<td  align="center" ><span class="dataTableTitle">Retirement Status <br> &nbsp</span></td>
       </tr>    		
       <tr bgcolor="#d9d9d9" >
       		 <td class="dataTableData" align="center" >
	       		<%List statusSelected =  (List)request.getAttribute("statusSelected");%>
	       		<Select name="status" id = "status" multiple="multiple" size="3" STYLE="width: 200px">
	  					  				
	  				<option value='SAVED' <%if(statusSelected!=null && statusSelected.contains("SAVED")){ %> selected <%}%>>SAVED</option>
	  				
	  				<option value='SUBMITTED'<%if(statusSelected!=null && statusSelected.contains("SUBMITTED")){ %> selected <%}%>>SUBMITTED</option>
	  				
	  				<option value='EXECUTED'<%if(statusSelected!=null && statusSelected.contains("EXECUTED")){ %> selected <%}%>>EXECUTED</option>
	  			</Select>
	  		</td>
	  	</tr>
	  	</TBODY>
	  	</table>
	  	</td>
	  		
	  	<td>
	  		<table border="0">
					<tr><td>
					<font face="Arial,Helvetica" ><a href="javascript: go()"> <img src="../gfx/btn_go.gif"  border="0" align="left"></a></font>
					</td></tr>
					<br>
					<tr><td>
					<a class="nostyle" href="javascript:reset();">
	            			<img src="../gfx/btn_resetfield.gif" border="0" name="Reset" alt="Reset"></a>	
				</tr></td>	            	
			</table>	            	
	  	  </td>	
	  	</tr>
 </table>  
	
<br><br><br>
<center><span class="headline">
      Software Retirement  Report 
  </span> &nbsp
  <a href="javascript: getExcelReport()">
            	    <img src="../gfx/btn_excel.gif" alt="Excel" border="0" name="excelReport" ></a>
  <br>
</center>
<% List identifyList = (List)request.getAttribute("indentifyList"); 
   if(identifyList!=null && identifyList.size()>0){
%>

<center>

 <BR>
  
 <table border="1" width="100%" style="font: 12px Arial; border-collapse: collapse; border: 0.2em solid #BBD1ED ">
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
       
    
    <!--  td align="center" valign="top"><span class="dataTableTitle">
      Image Name</span></td-->
    <td align="center" valign="top"><span class="dataTableTitle">
      Release Number</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Release Train</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Rlease PM</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Business Unit</span></td>  
    <td align="center" valign="top"><span class="dataTableTitle">
      Branch Name</span></td>
     <td align="center" valign="top"><span class="dataTableTitle">
      Branch Status</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Posting Type</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Retirement Type</span></td>    
    <td align="center" valign="top"><span class="dataTableTitle">
       Schedule Date</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
       Actual date</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Advise Type</span></td>
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Deferral ID</span></td>	
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Affected Release</span></td> 
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Solution Release</span></td> 
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Def State</span></td>    
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Orderable Flag</span></td> 
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Backlog Flag</span></td> 
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Retirement Status</span></td>   
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Target Retirement Date</span></td> 
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Migration path</span></td>  
    <td align="center" width ="20%" valign="top"><span class="dataTableTitle">
      Comments</span></td>  
    </tr>
    
 
   
<!-- row multiple -->


<% System.out.println(" the size is "  + identifyList.size());%>
<% 
int size =   identifyList.size();
for (int i=0; i<size; i++){ 
   OrderabilityVo vo = (OrderabilityVo)identifyList.get(i);%>
   <tr bgcolor="#ffffff">
     
    <td align="left" valign="top" rowspan=1><span class="dataTableData">
          <%= vo.getRelease_number()%></span></td>
    <td align="left" valign="top" rowspan=1><span class="dataTableData">
          <center><%=vo.getRelease_train() %></center> </span></td>
    <td align="right" valign="top" rowspan=1><span class="dataTableData">
          		<%=vo.getRelease_pm() %> </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
          		 <%=vo.getBusiness_unit_name() %></span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
          		<%=vo.getBranch_name()%></span></td>

    <td align="center" valign="top"><span class="dataTableData">
          <%=vo.getBranch_status() %></span></td>
   
 	 <td align="center" valign="top"><span class="dataTableData">
           <%=vo.getPosting_type() %></span></td>
    <td align="center" valign="top"><span class="dataTableData">
           <%=vo.getRetirementType() %></span></td>       
 
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
          <%=vo.getSchedule_date()%> </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
           <%=vo.getActual_date() %> </span></td>



    <td align="center" valign="top" rowspan=1><span class="dataTableData">
            <%= vo.getAdvise_type() %>
    </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
            <%=vo.getDeferral_id() %>
    </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
                <%=vo.getAffected_release() %>
    </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
                    <%=vo.getSolution_release() %>
    </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
                        <%=vo.getDef_state() %>
    </span></td>
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
                            <%=vo.getOrderable_flag() %>
    </span></td>
     <td align="center" valign="top" rowspan=1><span class="dataTableData">
                             <%=vo.getBacklog_flag() %>
    </span></td>
    
    <td align="center" valign="top">
    	<%=vo.getRetirementStatus() %>
	</td>
    
    <td align="left" valign="top" rowspan=1 NOWRAP><span class="dataTableData">
    <% 
      	String migrationDate  ="";
  		if (vo.getTarget_migration_date() !=null){
    		
  			SimpleDateFormat format = new SimpleDateFormat("dd-MMM-yyyy hh:mm:ss a");
  			migrationDate = format.format(vo.getTarget_migration_date());
  	}
  	%> 
    	 <%=migrationDate%>
    </span></td>
    
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
         <%=vo.getMigration_path() %>
    </span></td>
    
    <td align="center" valign="top">
    	<%=vo.getComments() %>
	</td>
    </tr>
           
     <!--  expand image start  -->
           
     <div id="imageInfo_<%=i %>">     
   <% 
   if(request.getParameter("type")!=null && request.getParameter("type").equalsIgnoreCase("expandRelease")){
	         String index =(String) request.getParameter("expandReleaseIndex");
	         if(Integer.parseInt(index)==i){
	        	 List imageList = (List)request.getAttribute("imageList"); 
	        	 if(imageList!=null && imageList.size()>1){
   
    
%>

  <tr bgcolor="#ffffff" align="left">
     <td colspan="21">

      <table class="dataTable" style="table-layout:fixed;" >
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
   
    <td align="center" valign="top"><span class="dataTableTitle">
      Select 
        <a href="javascript:checkboxSelectAllHere('selectedImageId')">
           <img src="../gfx/btn_all_mini.gif" border="0"/></a>
        <a href="javascript:checkboxSelectNoneHere('selectedImageId')">
           <img src="../gfx/btn_none_mini.gif" border="0" /></a>
      </span></td>

    <td align="center" valign="top" NOWRAP><span class="dataTableTitle">
      Image Name</span></td>
    <td align="center" valign="top"><span class="dataTableTitle">
      Migration Date</span></td>
    <td align="center" valign="top" NOWRAP colspan="5">
    	<table> 
    	   <tr>
    		<td align="center" width ="20%" valign="top" NOWRAP><span class="dataTableTitle">
      				Platform</span></td>   
    		<td align="center" valign="top" width ="20%" NOWRAP><span class="dataTableTitle">
     		 		Migration Path</span></td>
     		<td align="center" valign="top" width ="20%" NOWRAP><span class="dataTableTitle">
     		 		Product Code</span></td> 
     		 <td align="center" valign="top" width ="20%" NOWRAP><span class="dataTableTitle">
     		 		Orderable </span></td> 
     		 <td align="center" valign="top" width ="20%" NOWRAP><span class="dataTableTitle">
     		 		Backlog Count</span></td> 						
           <tr>
         </table>
     </td>
     
  </tr>
   
   <% 
  
   for (int j=0; j<imageList.size(); j++){ 
	   QotImageInfoVo imageVo = (QotImageInfoVo)imageList.get(j);
	   
   %>
     <tr bgcolor="#ffffff">
              <td align="center" valign="top" rowspan=1><span class="dataTableData">
     
              <input type="checkbox" value="<%=imageVo.getImageId().toString() %>" name="selectedImageId" id="selectedImageId"/>   
     
             </span></td>
                           
         <td align="left" valign="top" ><span class="dataTableData">
              <%=imageVo.getImageName() %> </span></td>
         <td align="left" valign="top" ><span class="dataTableData">
	          <input id="imageMigrationDate_<%=j%>" name="imageMigrationDate_<%=j%>" type="text" size="10" value="" onFocus="this.blur()" />
	      		 <a href="javascript:NewCal('imageMigrationDate_<%=j%>','ddmmmyyyy',true,12)" onmouseover="window.status='Date Picker';return true;"
	      		  	onmouseout="window.status='';return true;">
	      		 	<img src="../gfx/calendar.gif" width=24 height=22 border=0 align="absmiddle" valign="top">
	      		 </a>                  
         </span></td>
         <td colspan="2" NOWRAP>
         <table border="1">
             <% 
                
                Set pSet = imageVo.getPlatformNameSet();
                Iterator it = pSet.iterator();
                Map map  = imageVo.getPlatformMigrationMap(); 
                
              while (it.hasNext()){ %>
              <tr>
           		<td align="left" valign="top" width="%20" NOWRAP> <span class="dataTableData">
           		    <%String platform = it.next().toString(); %>
               		<center><%= platform%></center> </span></td>
               		
         		<td align="right" valign="top" width="%20" NOWRAP><span class="dataTableData">
         		    
         		   <% Set migrationPathSet = (HashSet)map.get(platform);
         		      Iterator migrationPathIterator = migrationPathSet.iterator();
         		      while (migrationPathIterator.hasNext()){
         		    	 String m_path = migrationPathIterator.next().toString();
         		      %>
               			    <INPUT TYPE="RADIO" NAME="imageMigrationPath_<%=j%>" VALUE="<%=m_path %>" > <%=m_path %><BR> 
               		<%} %>
               	</span></td>
               	<td align="left" valign="top" width="%20" NOWRAP> <span class="dataTableData">
           		       
               		 </span></td>
               	<td align="left" valign="top" width="%20" NOWRAP> <span class="dataTableData">
           		  
               		<center></center> </span></td>
               	<td align="left" valign="top" width="%20" NOWRAP> <span class="dataTableData">
           		   
               		<center></center> </span></td>		
             </tr>
             <% } %>
             
          </table>
          </td>
          
        
         
     </tr>
     <%}%>
     
     </table>
     </td></tr>
     <%      }
	     }
   }
   %>
     <!-- expand image end  -->
           
           
 <%} %>    
 </table></center>
     
     
	
 <%} %>
<!--  end of the List -->
<br>
<!--  
<a href="javascript: submit()">
<img border="0" name="btnSubmit" alt="Submit" src="../gfx/btn_submit.gif"/>
</a> -->


</FORM>

<%= Footer.pageFooter(globals) %>
<!-- end -->
