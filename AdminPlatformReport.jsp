<!--
.........................................................................
: DESCRIPTION:
: Search by Platform to generate report

: CREATION DATE:
: 12/31/07, sprit 6.10.1  CSCsj76625

: AUTHORS:
: @author Holly Chen (holchen@cisco.com)
:
: Copyright (c) 2007-2008, 2010 by Cisco Systems, Inc.
:.........................................................................
-->
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.Timestamp"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="java.util.Properties" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner" %>
<%@ page import="com.cisco.eit.sprit.ui.SpritReleaseTabs" %>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants" %>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo" %>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals" %>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager" %>
<%@ page import="com.cisco.rtim.ui.TableMaker" %>
<%@ page import="com.cisco.rtim.util.WebUtils" %>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<%@ page import="com.cisco.eit.sprit.model.dao.adminPlatformReport.AdminPlatformReportDAO"%>
<%@ page import="com.cisco.eit.sprit.dataobject.PlatformInfo"%>

<script language="JavaScript" src="../js/sprit.js"></script>
<script language="JavaScript" src="../js/prototype.js"></script>

<%
  //SpritAccessManager spritAccessManager;
  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  //String pathGfx;
  //String userId;

  // Initialize globals
  globals = SpritInitializeGlobals.init(request,response);
  //pathGfx = globals.gs( "pathGfx" );
  //spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  //userId =  spritAccessManager.getUserId();
  //pathGfx = globals.gs( "pathGfx" );

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addContextNavElement( "REL:",
      SpritGUI.renderReleaseNumberNav(globals,null)
      );
%>
<%= SpritGUI.pageHeader( globals,"Sprit Admin Platform Report","" ) %>
<%= banner.render() %>

<span class="headline">
      Platform Report Search
</span><br /><br />

<!--  
<span class="subHeadline">
    Options
</span><br />
-->


<FORM name= "platformReportForm" method=POST action="AdminPlatformReportResult.jsp">
<SCRIPT type=text/javascript>
  var clear = true;
  function getReleaseValues(){
  	    var platformSelectedArray = new Array();
  	    var platformSelect = document.getElementById("platformSelect");
  	    //alert(platformSelect.length);
  	    if(platformSelect.length>0){
  	    	for (var j = 0; j < platformSelect.length; j++){
  	    		platformSelectedArray[j]=platformSelect.options[j].value;
  	    	}
  	 		var url = 'AdminPlatformReportProcessor';
			var pars = 'action=getRelease' + '&platformSelect='+ platformSelectedArray.toString();
			var ajax_req = new Ajax.Request(
				   							url,
				   							{
		 		   								method: 'post',
				   								parameters: pars,
				   								onComplete: this.showReleaseInfoResult
				   							});
		}//end if
		
		 var releaseAvailable = document.getElementById("releaseAvailable");  //releaseAvailable multiple select
		 //clears the items from the end of the select
         releaseAvailable.length =0;
  	}
  	
  function showReleaseInfoResult(originalRequest){
  	// Get JSON values 
   jsonRaw = originalRequest.responseText;
   // Eval JSON response into variable 
   jsonContent = eval("(" + jsonRaw + ")");
  
   var releaseAvailable = document.getElementById("releaseAvailable");  //releaseAvailable multiple select 

   var hiddenReleaseNumber = document.getElementById("hiddenReleaseNumber");
   hiddenReleaseNumber.innerHTML = "";

	if(clear==true){
	   var releaseSelect = document.getElementById("releaseSelect")
	   for (var j = releaseSelect.length-1; j >= 0; j--) {
		   releaseSelect.options[j] = null;
	   } 
	   opt_new = new Option(SELECT_OPT_NONE_SELECTED, "");
	   releaseSelect.options[0] = opt_new;
	}
	  
    
   //alert(jsonContent.releaseArray.length);
   // Loop over releasArray length.
   for (i = 0; i < jsonContent.releaseArray.length; i++) {
        
        opt_new = new Option(jsonContent.releaseArray[i].releaseName,jsonContent.releaseArray[i].releaseId);
    	releaseAvailable.options[i] = opt_new;
        hiddenReleaseNumber.innerHTML = hiddenReleaseNumber.innerHTML + '<input type="hidden" id="releaseMap" name="releaseMap" value="'+jsonContent.releaseArray[i].releaseId+','+jsonContent.releaseArray[i].releaseName+'">'; 
   }

   // Place formatted finalResponse in div element
   //document.getElementById("addressBookResults").innerHTML = finalResponse;
  	
  	}
  	
  	function submit(){
  	   var platformSelected  = document.getElementById("platformSelect");
  	   var releaseSelected  = document.getElementById("releaseSelected");
  	   var releaseAvailable = document.getElementById("releaseAvailable");
  	   var temp  = document.getElementById("releaseSelect");
  	   
  	   var valueArray = new Array();
  	   //alert(temp.length);
  	   for(i=0;i<temp.length; i++){
  		 temp.options[i].selected=true;
  	   	 valueArray[i]=temp.options[i].value
  	   }

 	   for(i=0;i<releaseAvailable.length; i++){
 		  releaseAvailable.options[i].selected=true;
	   }
  	   
  	   for(i=0;i<platformSelected.length; i++){
  	   	   platformSelected.options[i].selected=true;
  	   }
  	   
  	   releaseSelected.value = valueArray.toString();
  	   //alert(releaseSelected.value);
  	   document.platformReportForm.submit();
  	}

</SCRIPT>
<center>
 
 <TABLE class="dataTable" border="1" cellpadding="0" cellspacing="0" >
       <TBODY>

<tr>

    <td bgcolor="#d9d9d9"><span class="infoboxTitle">
        * Platform  : 
    </span></td>

    <td class="td-input" >
        <table border="0">
        <tbody><tr>
            <td width>
                <span class="dataTableTitle">&nbsp;&nbsp; Available</span> 
                <br>
                <table border="0" width="100%">
                <select name="platformAvailable" multiple="multiple" size="10" STYLE="width: 300px">
                <% AdminPlatformReportDAO dao = (AdminPlatformReportDAO)SpringUtil.getApplicationContext().getBean("adminPlatformReportDAO");  //Spring JDBC 	 
                   List platformList = dao.getPlatformNameAndId();
                   Map platformMap = new HashMap();
                   for (int i=0; i<platformList.size(); i++){
                	   PlatformInfo vo = (PlatformInfo)platformList.get(i);
                	   platformMap.put(vo.getPlatformId().toString().trim(),vo.getPlatformName());
                	   %>
	                      <option value='<%=vo.getPlatformId() %>' > <%=vo.getPlatformName() %></option>
	                                
                  <% } %> 
                </select>
                </table>
            </td>
            <td>
                <input name="platformAdd" value=" &nbsp;&nbsp; add &gt; &nbsp;&nbsp;&nbsp; " onclick="javascript:addSelection(this.form.platformAvailable, this.form.platformSelect)" type="button">
                <br>
                <input name="platformRemove" value="&nbsp; &lt; Delete &nbsp;&nbsp;" onclick="javascript:removeSelection(this.form.platformSelect)" type="button">
                <br>
                <input name="platformRemoveAll" value="&lt;&lt; Clear All" onclick="javascript:removeAllSelection(this.form.platformSelect)" type="button">
            </td>
            <td>
                <span class="dataTableTitle">&nbsp;&nbsp;  Selected</span>
                <br>
                    <table border="0" width="100%">
                    	<select name="platformSelect" id="platformSelect"   multiple="multiple" size="10" STYLE="width: 300px">
                    	<%
                    	String[]  selectedPlatforms = request.getParameterValues("selectedPlatforms"); 
                    	if(selectedPlatforms!=null && selectedPlatforms.length > 0){
                    		for(int i=0;i< selectedPlatforms.length; i++){%>
         	                      <option value='<%=selectedPlatforms[i]%>' > <%=platformMap.get(selectedPlatforms[i].trim()) %></option>
                           <% }
                    	}else{%>
                    		<option value="">-- None Selected --</option>
                    	<%}%>
                		</select>
                	</table>
             </td>
        </tr>
        </tbody></table>
    </td>
</tr>
</TBODY></TABLE>
 
<br>
<table><tr>
	<td><img src="images/blank.gif" border="0" width="30" height="0"></td>
	<td><input type="button" name="getRelease" value="Get Release" onclick="getReleaseValues()"/></td>
	</tr></table>
<br>


<TABLE class="dataTable" border="1" cellpadding="0" cellspacing="0"  >
       <TBODY>

<tr>

    <td bgcolor="#d9d9d9" ><span class="infoboxTitle" >
        * Release  : &nbsp;&nbsp;
    </span></td>

    <td class="td-input" >
        <table border="0" width="100%">
        <tbody><tr>

            <td>
                <span class="dataTableTitle">&nbsp;&nbsp; Available</span>
                <br>
                <table border="0" width="100%">
                	<select name="releaseAvailable" id ="releaseAvailable" multiple="multiple" size="10" STYLE="width: 300px">
                	<!--  option value=""><img src="images/blank.gif" border="0" width="500" height="0"></option-->
                		<%
                			Map releaseMap = new HashMap();
                		    String[] releases = request.getParameterValues("releaseMap");
                		    if(releases!=null && releases.length > 0){
                		    	for(int i=0;i< releases.length; i++){
                		    		String[] release = releases[i].split(",");
                		    		releaseMap.put(release[0],release[1]);
                		    		%><option value='<%=release[0]%>' > <%=release[1]%></option><%
                		    	}
                		    }%>
                    </select>
                 </table> 
            </td>
            <td>
                <input name="releaseAdd" value=" &nbsp;&nbsp; add &gt; &nbsp;&nbsp;&nbsp; " onclick="javascript:addSelection(this.form.releaseAvailable, this.form.releaseSelect)" type="button">
                <br>
                <input name="releaseRemove" value="&nbsp; &lt; Delete &nbsp;&nbsp;" onclick="javascript:removeSelection(this.form.releaseSelect)" type="button">
                <br>
                <input name="releaseRemoveAll" value="&lt;&lt; Clear All" onclick="javascript:removeAllSelection(this.form.releaseSelect)" type="button">

            </td>
            <td >
                 <span class="dataTableTitle">&nbsp;&nbsp;  Selected</span>
                 <br>
                 <table border="0" width="100%">
                    <select name="releaseSelect" id ="releaseSelect" multiple="multiple" size="10" STYLE="width: 300px">
                    
                    <%
                    	String[]  releaseSelect = request.getParameterValues("releaseSelect"); 
                    	if(releaseSelect!=null && releaseSelect.length > 0){
                    		for(int i=0;i< releaseSelect.length; i++){%>
         	                      <option value='<%=releaseSelect[i]%>' > <%=releaseMap.get(releaseSelect[i].trim()) %></option>
                           <% }
                    	}else{%>
                    		<option value="">-- None Selected --</option>
                    	<%}%>
                		</select> 
                 </select>
                 </table>
            </td>
        </tr>
        </tbody></table>
    </td>
</tr>
</TBODY>
</TABLE>
<input type="hidden" id="releaseSelected" name="releaseSelected">
<div id="hiddenReleaseNumber">
	<%
		Set releaseMapSet = releaseMap.keySet();
		if(releaseMapSet!=null && releaseMapSet.size() > 0){
		Iterator releaseMapSetIt = releaseMapSet.iterator();
		while(releaseMapSetIt.hasNext()){
			String val = (String)releaseMapSetIt.next();%>
      		<input type="hidden" id="releaseMap" name="releaseMap" value="<%=val%>,<%=releaseMap.get(val)%>">           		    		
      	<%}}%>
</div>

<br>
<table><tr>
       <td><img src="images/blank.gif" border="0" width="30" height="0"></td>
       <td><a href="javascript: submit()">
            	    <img src="../gfx/btn_submit.gif" alt="Submit" border="0"
	            	name="btnSubmit"></a></td>
	  </tr>          	
</table>

<br>
</center>
<%= Footer.pageFooter(globals) %>
</Form>