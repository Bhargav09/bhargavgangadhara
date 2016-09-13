<%@ page import="java.util.Vector"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Iterator"%>
<%@page import="com.cisco.irt.util.RESTServiceClient"%>
<%@page import="com.cisco.irt.form.action.ActionConstants"%>

<%
	String hostName = "wwwin-vbabumus-irt-dev.cisco.com";
	Integer osTypeId = 306;//(Integer) request.getAttribute("osTypeId");
	Integer releaseNumberId = 1108;//(Integer) request.getAttribute("releaseNumberId");
	String userId = request.getRemoteUser();//"himsriva";//request.getParameter("userId");
	String releaseName = "3.2.0 S";//(String)request.getAttribute("releaseName");
	/* String hiddenMdfName = "";
	String hiddenMdfId = ""; */
	String sourceLocation = "";
	String taskId = (String) request.getAttribute("taskId");
	System.out.println("releaseNumberId::" + releaseNumberId);
	RESTServiceClient restServiceClient = new RESTServiceClient();
	String softwareServiceHostURL = restServiceClient
			.getProperty("software.services.url.base");
%>
<link
	href="http://<%=hostName%>/dojo1_8/1_8_3/dojox/grid/resources/claroGrid.css"
	rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css"
	href="/irt/resources/auessome/auessome.css" media="screen" />
<!--  added extra  -->

<style type="text/css">
#gridDiv {
	height: 400em;
}
</style>

<!-- added extra -->
<!-- <script>dojoConfig = {parseOnLoad: true}</script> -->
<!-- <SCRIPT TYPE="text/javascript" SRC="http://ajax.googleapis.com/ajax/libs/dojo/1.2.0/dojo.xd.js"> </SCRIPT> -->
<script type="text/javascript"
	src="/irt/resources/js/jquery/min/jquery-latest.js"></script>
<!-- end of extra -->
<script type="text/javascript" src="/irt/resources/js/posting/sprit.js"></script>
<!-- <script type="text/javascript"
	src="/irt/resources/js/posting/imageView.js"></script> -->
<script type="text/javascript"
	src="/irt/resources/js/posting/createImage.js"></script>
	<script type="text/javascript"
	src="/irt/resources/js/posting/updatePlanner.js"></script>
<script type="text/javascript"
	src="/irt/resources/js/posting/BrowserSniff.js"></script>
<script>

var updateIndex;
var metaDataArray = [];
var softwareServiceURL = "<%=softwareServiceHostURL%>";
var submitUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SUBMIT_ACTION%>/<%=taskId%>";
var saveUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SAVE_ACTION%>/<%=taskId%>";
</script>	
	<div>
	<a href="#" onclick="javascript:viewAll(document.getElementById('releaseNumberId').value);"><b>Upgrade-Planner</b></a><b><br>
<button onclick="javascript:deleteImage();"><b>Delete Checked>></button>
<button onclick="dashboard.displayUpgradePlannerPopup();"><b>Add Image>></button>
&nbsp;
</div>
<div class="claro mine" id="gridDiv" align="center"
	style="display: block; overflow: auto;"></div>
	
	<form id="csprCreateMetaData">
		<input type="hidden" name="osTypeId" id="osTypeId"
			value="<%=osTypeId%>" /> <input type="hidden" name="releaseNumberId"
			id="releaseNumberId" value="<%=releaseNumberId%>" /> 
		<input type="hidden" id="userId" name="userId" value="<%=userId%>" />
		<%-- <input type="hidden" name="userId" value="<%=userId%>"/> --%>
		<input type="hidden" name="imageId" id="imageId" value='' />
		<input type="hidden" name="primaryRole" id="primaryRole" value='<%= userId %>' />
		<input type="hidden" name="actorId" id="actorId" value='<%= userId %>' />
		<input type="hidden" name="displayId" id="displayId" value='<%= "test display" %>' />
		<input type="hidden" name="hasPlatform" id="hasPlatform" value='' />
		<input type="hidden" name="systemId" id="systemId" value='<%= "test system" %>' />
		<input type="hidden" name="hasFeatureSet" id="hasFeatureSet" value='<%= "test has featureset" %>' />
		<input type="hidden" name="hasProductization" id="hasProductization" value='' />
		<input type="hidden" name="needGuestApproval" id="needGuestApproval" value='' />
		
		
		
					</form>
</div>
	
		
<div id="buttonBarDiv" class="buttonbar">
	<span id="buttonsid" style="white-space: nowrap;">
	
			<button onclick="javascript:deleteImage();"><b>Delete Checked>></button>
	<button onclick="dashboard.displayUpgradePlannerPopup();"><b>Add Image>></button>
	</span>
	
</div>
<div id = "addFeatureSet" data-dojo-type="dojox/widget/DialogSimple" style="display: none" executeScripts="true" align="center" ></div>
<!-- <span dojoType="dojox.data.HtmlStore" jsId="htmlStore" dataId="tableExample">
		</span>
		<span dojoType="dojox.grid.data.Dojodata" jsId="dataModel6" rowsPerPage="5" store="htmlStore" query="{}">
		</span>
		<div id="grid6" dojoType="dojox.Grid" elasticView="2" model="dataMoldel6" structure="layoutHtmlTable">
		</div>
		
		<table id="tableExample" style="display: none;">
		<thead>
		<tr>
		<th> Column 1 </th>
		<th> column 2 </th>
		<th> column 3 </th>
		<th> column 4 </th>
		</tr>
		</thead>
		<tbody>
		<tr>
		<td> this </td>
		<td> is </td>
		<td></td>
		<td>empty in column 3</td>
		</tr>
		</tbody>
		</table>
		</tbody> -->

