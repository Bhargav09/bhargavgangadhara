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
	String hiddenMdfName = "";
	String hiddenMdfId = "";
	String sourceLocation = "";
	String taskId = (String) request.getAttribute("taskId");
	System.out.println("releaseNumberId::" + releaseNumberId);
	RESTServiceClient restServiceClient = new RESTServiceClient();
	String softwareServiceHostURL = restServiceClient
			.getProperty("software.services.url.base");
/* 	int updateIndex = (Integer)(Integer.parseInt(request.getParameter("index")).intValue(); */
%>
<link
	href="http://<%=hostName%>/dojo1_8/1_8_3/dojox/grid/resources/claroGrid.css"
	rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css"
	href="/irt/resources/auessome/auessome.css" media="screen" />
<!--  added extra  -->

<style type="text/css">
#gridDiv {
	height: 40em;
}
</style>

<!-- added extra -->
<!-- <script>dojoConfig = {parseOnLoad: true}</script> -->
<script type="text/javascript"
	src="/irt/resources/js/jquery/min/jquery-latest.js"></script>
<!-- end of extra -->
<script type="text/javascript" src="/irt/resources/js/posting/sprit.js"></script>
<!-- <script type="text/javascript"
	src="/irt/resources/js/posting/imageView.js"></script> -->
<script type="text/javascript"
	src="/irt/resources/js/posting/createImage.js"></script>
	<!-- <script type="text/javascript"
	src="/irt/resources/js/posting/updatePlanner.js"></script> -->
	<script type="text/javascript"
	src="/irt/resources/js/posting/upgradePlannerSave.js"></script>
<script type="text/javascript"
	src="/irt/resources/js/posting/BrowserSniff.js"></script>
<script>


var metaDataArray = [];
var softwareServiceURL = "<%=softwareServiceHostURL%>";
var submitUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SUBMIT_ACTION%>/<%=taskId%>";
var saveUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SAVE_ACTION%>/<%=taskId%>";
</script>	
	
<div>
	
<button onclick="javascript:editImage();"><b>Save updates>></button>

</div>
<div class="claro mine" id="upgradePlannerViewgridDiv" align="center"
	style="display: block; overflow: auto;"></div>
	
<div data-dojo-type="dijit/Dialog" id="createImageDialog"
	title="ADD IMAGE" style="display: none" align="center">
	
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
		
		<!-- primaryRole
		actorId
		displayId
		hasPlatform
		systemId
		hasFeatureSet
		hasProductization
		needGuestApproval -->
		
	<%-- 	<div class="dijitDialogPaneContentArea">
			<!-- <table width="100%"> -->
			<tr align="center">
					<td colspan="4">
						<div id="buttonDiv" class="buttonbar" align="center">
							<span id="imageListId" style="white-space: nowrap;"
								align="center">
								<button id="upgradePlannerSave" data-dojo-type="dijit/form/Button"  onclick="openNewPopup();"><b>Add Image>></button>
								<button id="upgradePlannerSave" data-dojo-type="dijit/form/Button"
									type="button" style="background-color:yellow;margin-left:auto;margin-right:auto;display:table;margin-top:0%;margin-bottom:0%">Save Updates</button>
								
							</span>
						</div>
					</td>
				</tr>
				
				<tr id="trMDFProduct" style="display: none">
					<td width="20%">
					<label for="name">Choose the feature description
					<span id="productCodeToolTipId" class="auessome_helpicon">
					</span>
					</label>
					</td>
					
				<td width="80%">
						<input type="hidden" name="hiddenMdfId"	id="hiddenMdfId" value="<%=hiddenMdfId%>">
						<input type="hidden" name="hiddenMdfName" id="hiddenMdfName" value="<%=hiddenMdfName%>">
						<div id="mdfDiv"></div>
						<input type="hidden" name="hiddenMdfId"	value="<%=hiddenMdfId%>">
						<input type="hidden" name="hiddenMdfName" value="<%=hiddenMdfName%>"><a href="javascript:mdfPopupPost('csprCreateMetaData',
	    	                             'mdfDiv',
	    	                             'div',
	    	                             'csprCreateMetaData',
	    	                             '',
	    	                             '', '',
                                             '<%=osTypeId%>')">Choose the feature description which apply to image <input type="hidden" name="hiddenMdfName" value="<%=hiddenMdfName%>"></a>
					</td>
				</tr>
				
	 
				<tr align="center">
					<td colspan="4">
						<div id="buttonDiv" class="buttonbar" align="center">
							<span id="imageListId" style="white-space: nowrap;"
								align="center">
								<button id="upgradePlannerSave" data-dojo-type="dijit/form/Button"
									type="button" onClick="self.close();" style="background-color:transparent;margin-left:auto;margin-right:auto;display:table;margin-top:0%;margin-bottom:0%">Save Updates</button>
								</span>
						</div>
					</td>
				</tr>
				</div> --%>
					</form>
</div>
	
		
 

<div id="buttonBarDiv" class="buttonbar">
	<span id="buttonsid" style="white-space: nowrap;">
	
			<button onclick="javascript:editImage();"><b>Save updates>></button>
	
	</span>
</div>

