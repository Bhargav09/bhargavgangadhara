<!--
.........................................................................
: DESCRIPTION:
: QOT AdminQOTIdentify UI 

: CREATION DATE:
: 02/09/09, sprit 7.5  CSCsx21579

: AUTHORS:
: @author Holly Chen (holchen@cisco.com)
:
: Copyright (c) 2009-2010, 2012 by Cisco Systems, Inc.
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
<%@ page import="java.util.Calendar"%>

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
<%@ page import="com.cisco.eit.sprit.dataobject.QotProductInfo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.QotVo" %>
<%@ page import="com.cisco.eit.sprit.dataobject.SpritPropertyInfo" %>





<%
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  SpritAccessManager    spritAccessManager;
  boolean               isSoftwareTypePM    = false;
  String lineNumber ="0";
 //String type = (String)request.getParameter("type");
  String type = "";
  //String mode = "identify";
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

  	
  	 /*@dmarwaha
  	 Dec 2012
  	 Display tool tip for Retirement status column
  	 */
  		function statusTooltip(elemId) {
  			//get element
  			var elem = document.getElementById(elemId);

  			//get browser type: IE/FF/Netscape
  			browsertype = navigator.appName;
  			
  			
  		if (browsertype.indexOf("Internet Explorer") != -1) {
  				elemChildVal = elem.childNodes[0].innerHTML;

  			}

  			else if ((browsertype.indexOf("Netscape") != -1)
  					|| (browsertype.indexOf("Firefox") != -1)) {
  				elemChildVal = elem.childNodes[1].innerHTML;

  			} else {
  				elemChildVal = elem.childNodes[0].innerHTML;
  			}

  			if (elemChildVal.indexOf("SAVED") != -1) {
  				
  				elem.title = "Shortlisted Candidate Release for Retirement.";
  			}
  			else if (elemChildVal.indexOf("NEW") != -1) {
  				
  				elem.title = "New Candidate Release for Retirement.";
  			}
  			else if (elemChildVal.indexOf("SUBMITTED") != -1) {
  				
  				elem.title = "Candidate Release submitted for Retirement.";
  			}
  			else {
  				
  				elem.title = "Release already Retired.";
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
   
   
  	
   function refreshSearch(){
   		document.getElementById("type").value="autoFilterSearchFields";
   		document.qotIdentifyForm.submit();
   
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
  	
  	function validateMigrationPathForEachRow(migrationPath, releaseNumberAndIndex){
            
    		 var url = 'go?action=qotidentify';
			 var pars = '&type=migrationPathValidation&pathToValidate=' + migrationPath + '&releaseNumber=' + releaseNumberAndIndex;
			 var ajax_req = new Ajax.Request(
				   							url,
				   							{
		 		   								method: 'post',
				   								parameters: pars,
				   								onComplete: this.showAlertForEarchRow
				   							});
    }
    
    function showAlertForEarchRow(xmlReq) {  
		 if(xmlReq.responseText.length>0)
		    alert(xmlReq.responseText);
	}
   	
    function validateMigrationPath(migrationPath){
             //var migrationPath = document.getElementById("migrationPath");
             alert(migrationPath)
    		 var url = 'go?action=qotidentify';
			 var pars = '&type=migrationPathValidation&pathToValidate=' + migrationPath;
			 var ajax_req = new Ajax.Request(
				   							url,
				   							{
		 		   								method: 'post',
				   								parameters: pars,
				   								onComplete: this.showAlert
				   							});
    }
    
    function showAlert(xmlReq) {  
		 if(xmlReq.responseText.length>0)
		    alert(xmlReq.responseText);
	}
   	
   	function expandRelease(index, expandReleaseNumberId){
   		document.getElementById("type").value="expandRelease";
   		document.getElementById("expandReleaseNumberId").value = expandReleaseNumberId;
   		//alert (document.getElementById("expandReleaseNumberId").value);
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
  		// var toDateSelect = document.getElementById('toDate');
  		// toDateSelect.value='';
  	}
  	
  	function deleteRecord(){
  	    submitFlag= true;
  	    // at least one release number must be selected before click on Delete button
  	    var releaseNumberArray = document.getElementsByName("selectedReleaseNumberId");
   	    var releaseNumberCheckedFlag = false;
   	    for (i=0; i<releaseNumberArray.length; i++){
   	    	 		if(releaseNumberArray[i].checked){
   	    	 			releaseNumberCheckedFlag = true;
   	    	 			break;
   	    	 	}
   	    }
   	    if(!releaseNumberCheckedFlag){
   	        alert("At least one release number need to select to delete");
   	        submitFlag= false;
   	     } 
   	     
   	    if(submitFlag){  
  			document.getElementById("type").value="delete";
   			document.qotIdentifyForm.submit();
   		}
   	}
  	
  	
  	function pathValidataion(index){
  		var migrationPathArray = document.getElementsByName("migrationPath");
  		//<!--%QueryUtil.checkSDSDownloadable()%-->migrationPathArray[index]
  	}
  		 	
   	function save(){
   		//alert (' SAVED CLICKED');
   		//var cbox_elem=document.getElementsbyName(selectedReleaseNumberId);
   	    var flag = true;
   	    var imageFlag = false;
   	    <% System.out.println(request.getParameter("type"));
   	    if(request.getParameter("type")!=null && request.getParameter("type").equalsIgnoreCase("expandRelease")){
   	         String index =(String) request.getParameter("expandReleaseIndex");
   	              if(!index.equalsIgnoreCase("")){            %>
   	    	      		var releaseNumberIdArray = document.getElementsByName("selectedReleaseNumberId");
   	    	      		var imageArray= document.getElementsByName("selectedImageId");
   	    	      		
   	    	      	    for (var i=0; i<imageArray.length; i++){
   	    	      	         if(imageArray[i].checked){
   	    	      	             imageFlag =true;
   	    	      	             break;
   	    	      	         }    
   	    	      	    }
   	    	      
   		    	  		if(!releaseNumberIdArray[<%=index%>].checked && imageFlag){
   		    	      		alert("ReleaseNumber must be checked!");
   		    	      		flag=false;
   		    	      	}	
   	     <%		}
   	       }%>   
   	    
   	    
   	    //migrationPath and date can be null at same time and also should be exist at same time
   	    var releaseNumberArray = document.getElementsByName("selectedReleaseNumberId");
   	       	 
   	    var releaseNumberCheckedFlag = false;
   	    for (i=0; i<releaseNumberArray.length; i++){
   	    	 if(releaseNumberArray[i].checked){
   	    	 		releaseNumberCheckedFlag = true;
   	    	 		break;
   	    	 }
   	    	 
   	    }
   	    
   	    
   	    
	if (!releaseNumberCheckedFlag)
			alert("At least one release number need to select to save");
	
	//Verify that the retirement type is selected for the ticked releases before processing SAVE  
	//@dmarwaha - Oct 2012
		else {
			
			for (i=0; i<releaseNumberArray.length; i++){
	   	    	 if(releaseNumberArray[i].checked){
	   	    		var elem = document.getElementById("retirementTypeId_" + i);

	   				if (elem.value =="") {
	   					alert("Please Choose Retirement Type for the selected releases to Save Changes");
	   					return;
	   				}
	   	    	 }
	   	    	 
	   	    }
			
			
		}

		//  check image leve migration path must be selected if image selected
<%if(request.getParameter("type")!=null && request.getParameter("type").equalsIgnoreCase("expandRelease")){%>
   	    	
   	    	var imageArray= document.getElementsByName("selectedImageId");
	      	for (var i=0; i<imageArray.length; i++){
	      		var imageMigrationpathName = "imageMigrationPath_" + i;
	      		var imageMigrationpath = document.getElementById(imageMigrationpathName);
	      	    if(imageArray[i].checked && (!imageMigrationpath.checked)){
	      	        	 alert(" Image level migration path should be selected before save!");
	      	        	 flag = false;
	      	             break;
	      	    }    
	      	}
	      	
	     <%} %>	 	       	    
   	    
   	    //migration path/date can't be null       
   	    var migrationPathArray = document.getElementsByName("migrationPath");
   	    for (i=0; i<releaseNumberArray.length; i++){
   	    	var migrationDate  = "migrationDate_" +i;
   	    	if(releaseNumberArray[i].checked){
	   	    	if(migrationPathArray[i].value.length <1 || document.getElementById(migrationDate).value.length<1){
	   	    	     alert("Migration Date and Path should not be empty to submit to CCO") ;  
	   	    	     flag =false;
	   	    	     break;
	   	        }
	   	    }    
   	    }
   	    
   	    
   	    
   	    if(flag && releaseNumberCheckedFlag){   
   				document.getElementById("type").value="save";
   				document.qotIdentifyForm.submit();
   		}
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
  <span class="tabNavLinkActive">Identify</a></span><span class="tabNavMiniDivider"> | </span></span>
  <span class="tabNavData"><span class="tabNavData"><a href="go?action=qotidentify&mode=Submit" id="tabNavLink">Submit</a></span><span class="tabNavMiniDivider"> | </span></span>
  <span class="tabNavData"><span class="tabNavData"><a href="go?action=qotidentify&mode=Execute" id="tabNavLink">Execute</a></span><span class="tabNavMiniDivider"> | </span></span>
  <span class="tabNavData"><span class="tabNavData"><a href="go?action=qotidentify&mode=Report" id="tabNavLink">Report</a></span><span class="tabNavMiniDivider"> | </span></span>
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
<input type="hidden" name="expandReleaseNumberId"  id="expandReleaseNumberId" value="<%=expandReleaseNumberId %>">
<input type="hidden" name="expandReleaseIndex"  id="expandReleaseIndex" >
<input type="hidden" name="mode"  id="mode" value="identify" >

		

<table><tr><td>

 <table class="dataTable" width="95%">
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
	       	    <Select name="trainType" id = "trainType" multiple="multiple" size="6" STYLE="width: 150px" onblur="refreshSearch()">
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
	       			<Select name="releaseTrain" id="releaseTrain"  multiple="multiple" size="6" STYLE="width: 200px" onblur="refreshSearch()">
	  					
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
	       	    	<Select name="branchName" id = "branchName" multiple="multiple" size="6" STYLE="width: 200px" onblur="refreshSearch()">
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
     		 <a href="javascript:NewCal('fromDate','ddmmmyyyy',false,12)" onmouseover="window.status='Date Picker';return true;"
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
			  	  				
			  	  					<option value= 'Split CCO Only'>Split CCO Only</option>
			  	  				
			  	  					<option value= 'Split CCO and MFG'>Split CCO and MFG</option>
			  	  				
			  	  					<option value= 'CCO and MFG'>CCO and MFG</option>
			  	  				
			  	  					<option value= 'CCO Only'>CCO Only</option>
			  	  				
			  	  					<option value= 'Hidden Post CCO Only'>Hidden Post CCO Only</option>
			  	  				
			  	  					<option value= 'Hidden Post MFG Only'>Hidden Post MFG Only</option>
			  	  				
			  	  					<option value= 'IOSXE IOS Non Posting'>IOSXE IOS Non Posting</option>
		  	  		</select> 
 			</span></td>
		</tr>	
	  	</tbody>
	  </TABLE> 	
</td>

<td>
	<table>
		<tr><td>
		<font face="Arial,Helvetica" ><a href="javascript: go()"> <img src="../gfx/btn_go.gif"  border="0" align="left"></a></font>
		</td></tr>

		<br>
		<tr><td>
		<a class="nostyle" href="javascript:reset();">
	            	<img src="../gfx/btn_resetfield.gif" border="0" name="Reset" alt="Reset"></a>	
		</tr></td>	            	
	</table>	            	

</td></tr></table>

<% List identifyList = (List)request.getAttribute("indentifyList"); 
   if(identifyList!=null && identifyList.size()>0){
%>

<center>
  <BR>
  <table border="1" width="100%" style="font: 12px Arial; border-collapse: collapse; border: 0.2em solid #BBD1ED ">
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
      <td align="center" valign="top"><span class="dataTableTitle">
      Select <br/>
        <a href="javascript:checkboxSelectAllHere('selectedReleaseNumberId')">
           <img src="../gfx/btn_all_mini.gif" border="0"/></a>
        <a href="javascript:checkboxSelectNoneHere('selectedReleaseNumberId')">
           <img src="../gfx/btn_none_mini.gif" border="0" /></a>
      </span></td>   
    <td align="center" valign="top"><span class="dataTableTitle">
      View Images <br/>
        
      </span></td>

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
      <!-- add new column to display release retirement state -->
      <td align="center" valign="top"><span class="dataTableTitle">
      Retirement STATUS</span></td>  
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
      Backlog Count</span></td> 
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
       <td align="center" valign="top" rowspan=1><span class="dataTableData">

         <input type="checkbox" value="<%= vo.getRelease_number_id().toString()%>:<%=i %>" id="selectedReleaseNumberId"
         name="selectedReleaseNumberId" />   

        </span></td>      
   
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
         <a href="javascript: expandRelease('<%=i%>','<%= vo.getRelease_number_id().toString()%>')">
            	    <img src="../gfx/icon_plus.gif" alt="Expand" border="0"
	            	name="btnSubmit"></a>
    <input type="hidden" id="releaseIdExpand" name= "releaseIdExpand" />        
    </span></td>

   
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
           
     <!-- @dmarwaha Oct 2012: Add STATUS column value -->
           <td align="center" valign="top" id="retirementStatusId_<%=i%>" onmouseover="javascript:statusTooltip(this.id)">
           <span class="dataTableData">
           <%=vo.getRetirementStatus() %></span></td>  
             
   <!-- Sprit 7.5.1 add Retirement Type, CSCsy32408 -->
    <td align="center" valign="top"><span class="dataTableData">
       <Select name="retirementTypeId_<%=i%>" id="retirementTypeId_<%=i%>" size="3" STYLE="width: 100px ;font: 10px Arial">
       <%List retirementTypeList = (List)request.getAttribute("retirementType");
       	 for (int t=0; t<retirementTypeList.size(); t++){
                 SpritPropertyInfo info = (SpritPropertyInfo)retirementTypeList.get(t);%>
     		<option value= '<%=info.getPropertyId()%>' <%if(info.getPropertyId()==vo.getRetirementTypeId()){ %>selected <%}%>> 
     			<%=info.getProdValue() %></option>
     	 <%} %>	
      </select>    
      	   
     </span></td>
   <!-- end Sprit 7.5.1  CSCsy32408-->
   
   
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
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
                             <%=vo.getBacklog_count() %>
    </span></td>
    
    <td align="left" valign="top" NOWRAP><span class="dataTableData">
    <% 
    String migrationDate  ="";
    String expandReleaseIndexValue = (String)request.getAttribute("expandReleaseIndex");
    if(expandReleaseIndexValue.length()!=0 &&  i == Integer.valueOf(expandReleaseIndexValue).intValue())
				migrationDate =(String)request.getAttribute("expandReleaseMigrationDate");
	
    else {
    	
        SimpleDateFormat format = new SimpleDateFormat("dd-MMM-yyyy hh:mm:ss a");
  		if (vo.getTarget_migration_date() !=null){
    			migrationDate = format.format(vo.getTarget_migration_date());
  			
  	    }else {
		       	//default to show currentDate + 90 days, not falling on Saturday/Sanday    
  		       	Calendar cal = Calendar.getInstance();
				cal.add(Calendar.DATE, +90);
				int weekday = cal.get(Calendar.DAY_OF_WEEK);
				if(weekday==1 ||weekday ==7) //sunday or saturday
				    cal.add(Calendar.DATE, +2);
				migrationDate = format.format(cal.getTime());
    	}
    }		
  	%> 
    	 <input id="migrationDate_<%=i%>" name="migrationDate_<%=i%>" type="text" size="9" value="<%=migrationDate%>" onFocus="this.blur()" />
		        	 
		 <a href="javascript:NewCalForDisableDate('migrationDate_<%=i%>','ddmmmyyyy',true,12)" onmouseover="window.status='Date Picker';return true;"
		  	onmouseout="window.status='';return true;">
		 	<img src="../gfx/calendar.gif" width=24 height=22 border=0 align="absmiddle">
		 </a>
    </span></td>
    
    <%
    String mPath="";
   	if(expandReleaseIndexValue.length()!=0 &&  i == Integer.valueOf(expandReleaseIndexValue).intValue())	
         mPath = (String)request.getAttribute("expandReleaseMigrationPath");
    else 
         mPath = vo.getMigration_path();
    %> 
    <td align="center" valign="top" rowspan=1><span class="dataTableData">
          <input type="text" name="migrationPath" id ="migrationPath"  size="10"  value='<%=mPath%>'/>
          <a href="javascript:validateMigrationPathForEachRow('<%=mPath%>','<%= vo.getRelease_number_id().toString()%>:<%=i %>')">validate</a>
     </span></td>
    
    <td align="center" valign="top">
    	<span class="dataTableData">
       			<textarea rows="2" cols="20" name="comments" id="comments"><%=vo.getComments() %></textarea>
		</span>
	</td>
    </tr>
           
    
  <!--  expand image start  -->
        
   <% 
   if(request.getParameter("type")!=null && request.getParameter("type").equalsIgnoreCase("expandRelease")){
	         String index =(String) request.getParameter("expandReleaseIndex");
	         if(Integer.parseInt(index)==i){
	        	 List imageList = (List)request.getAttribute("imageList"); 
	        	 if(imageList!=null && imageList.size()>1){
   
    
%>

  <tr bgcolor="#ffffff" align="left">
     <td colspan="22">

      <table border="1" width="80%" style="font: 12px Arial; border-collapse: collapse; border: 0.2em solid #BBD1ED ">
      <tr bgcolor="#d9d9d9"><span class="dataTableData">
   
    <td align="center" valign="top"><span class="dataTableTitle">
      Select 
        <a href="javascript:checkboxSelectAllHere('selectedImageId')">
           <img src="../gfx/btn_all_mini.gif" border="0"/></a>
        <a href="javascript:checkboxSelectNoneHere('selectedImageId')">
           <img src="../gfx/btn_none_mini.gif" border="0" /></a>
      </span></td>

    <td align="center" valign="top" ><span class="dataTableTitle">
      Image Name</span></td>
    <td align="center" valign="top" ><span class="dataTableTitle">
      Image Retriement Type</span></td>  
    <td align="center" valign="top"><span class="dataTableTitle">
      Migration Date</span></td>
    <td align="center" valign="top"  colspan="6">
    	<table> 
    	   <tr>
    		
    		<td align="center" valign="top" width ="30%" ><span class="dataTableTitle">
     		 		Migration Path</span></td>
     		<td align="center" valign="top" width ="40%" ><span class="dataTableTitle">
     		 		Product Code</span></td> 
     		 <td align="center" valign="top" width ="15%" ><span class="dataTableTitle">
     		 		Orderable </span></td> 
     		 <td align="center" valign="top" width ="15%" ><span class="dataTableTitle">
     		 		Backlog Count</span></td> 						
           <tr>
         </table>
     </td>
     
  </tr>
   
   <% 
   QotVo retiredImagevo = (QotVo)request.getAttribute("retiredImageList");
   //imageId list - image retired (saved to cspr_retirement_image table)
   List retiredImageIdList = retiredImagevo.getRetiredImageList();
   //imageId- migration Map. (data in cspr_retirement_image table)
   Map imageIdMigrationPathMap= retiredImagevo.getRetiremdImageMap();
   
   for (int j=0; j<imageList.size(); j++){ 
	   QotImageInfoVo imageVo = (QotImageInfoVo)imageList.get(j);
	   
   %>
     <tr bgcolor="#ffffff">
              <td align="center" valign="top" rowspan=1><span class="dataTableData">
     
              <input type="checkbox" value="<%=imageVo.getImageId().toString() %>:<%=j %>" name="selectedImageId" id="selectedImageId"
              <% if(retiredImageIdList.contains(imageVo.getImageId())){ %> checked <%} %>/>   
     
             </span></td>
                           
         <td align="left" valign="top" NOWRAP><span class="dataTableData">
              <%=imageVo.getImageName() %> </span></td>
              
<!-- Sprit 7.5.1 add Retirement Type, CSCsy32408 -->
    	<td align="center" valign="top"><span class="dataTableData">
       		<Select name="imageRetirementTypeId" id="imageRetirementTypeId" size="3" STYLE="width: 200px ;font: 10px Arial">
       		<%for (int t=0; t<retirementTypeList.size(); t++){
                    SpritPropertyInfo info = (SpritPropertyInfo)retirementTypeList.get(t);%>
     				<option value= '<%=info.getPropertyId()%>' 	<%if(Integer.parseInt(imageVo.getRetirementTypeId())==info.getPropertyId()){%> selected <%}%>> 	
     				<%=info.getProdValue() %></option>
     	    <%} %>	
      		</select>    
      </span></td>
<!-- end Sprit 7.5.1  CSCsy32408-->	              
              
         <td align="left" valign="top" ><span class="dataTableData">
           <% 
      		String imageMigrationDate  ="";
        	SimpleDateFormat imageFormat = new SimpleDateFormat("dd-MMM-yyyy hh:mm:ss a");
  			if (imageVo.getMigrationDate()!=null){
  				imageMigrationDate = imageFormat.format(imageVo.getMigrationDate());
  			
  	   		}else {
		       	//default to show currentDate + 90 days    
  		       	Calendar cal = Calendar.getInstance();
				cal.add(Calendar.DATE, +90);
				int weekday = cal.get(Calendar.DAY_OF_WEEK);
				if(weekday==1 || weekday ==7) //sunday or saturday
				    cal.add(Calendar.DATE, +2);
				imageMigrationDate = imageFormat.format(cal.getTime());
    	  }
  		  %> 
	          <input id="imageMigrationDate_<%=j%>" name="imageMigrationDate_<%=j%>" type="text" size="22" value="<%=imageMigrationDate %>" onFocus="this.blur()" />
	      		 <a href="javascript:NewCalForDisableDate('imageMigrationDate_<%=j%>','ddmmmyyyy',true,12)" onmouseover="window.status='Date Picker';return true;"
	      		  	onmouseout="window.status='';return true;">
	      		 	<img src="../gfx/calendar.gif" width=24 height=22 border=0 align="absmiddle" valign="top">
	      		 </a>                  
         </span></td>
         <td colspan="6" >
         <table border="1">
            <tr>
           		<td align="left" valign="top" width="%30" ><span class="dataTableData">
         		    
         		    <%
         		        List migrationPathList = imageVo.getMigrationPathList(); //1. from cisrom, 2. from UI release level. 3. from DB saved
         		        for(int t=0; t<migrationPathList.size(); t++){
         		    	   String m_path =(String) migrationPathList.get(t);
         		    	  
         		    	   //check the migartion path is in db or not. 
         		    	   //boolean isInDb = false;
         		           //String migrationPathInDb =  imageIdMigrationPathMap.get(imageVo.getImageId())!=null? imageIdMigrationPathMap.get(imageVo.getImageId()).toString():"";
         		    	   
         		           //mPath is releaseLevel migration path user input from UI, when expand(click on the plus icon, the release level migartion path need to apply to image level)
         		           boolean sameAsReleaseFlag = false;
         		           if(mPath.trim().equalsIgnoreCase(m_path)) 
         		        	  sameAsReleaseFlag = true;
         		        %>
               			    <INPUT TYPE="RADIO" NAME="imageMigrationPath_<%=j%>" id="imageMigrationPath_<%=j%>" VALUE="<%=m_path %>" 
               			    <%if(sameAsReleaseFlag){%> checked<%} %> /> <%=m_path %><BR> 
               		<% }%>
         		      
               	</span></td>
               	<td>
               	<table border="1">
               
               	<%List productList = imageVo.getProductList();
               	  for (int z=0; z<productList.size(); z++){
               		QotProductInfo productVo = (QotProductInfo)productList.get(z);
               	  
               	%>
               	<tr>
               	<td align="left" valign="top" width="%40" > <span class="dataTableData">
               	   <%= productVo.getProduct() %>
         		     
               	</span></td>
               	<td align="center" valign="top" width="%15" > <span class="dataTableData">
           		  			<%=productVo.getOrderableFlag() %>
               		<center></center> </span></td>
               	<td align="center" valign="top" width="%15" > <span class="dataTableData">
           		   			<%=productVo.getBacklogCount() %>
               	 </span></td>
               	 </tr>
               	 <%} %>	
               	 
               	 </table>
               	 </td>	
             </tr>
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
 </table>
 
   
     <center>
		<img border="0" name="btnSaveUpdates1" src="../gfx/btn_save_updates.gif" alt="Save Updates" 
			onmouseout="actionBtnSaveImages('btnSaveUpdates1')" onclick="javascript:save()" 
			onmouseover="actionBtnSaveImagesOver('btnSaveUpdates1')"/>
		
		<a href="javascript:deleteRecord()">
		<img border="0" name="btnDelete" src="../gfx/btn_delete_checked.gif" alt="Delete"></a> 
			
			 
	</center>
	
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
