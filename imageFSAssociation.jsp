<%@page import="com.cisco.irt.form.action.ActionConstants"%>
<%@page import="com.cisco.irt.util.RESTServiceClient"%>
<%
	RESTServiceClient restServiceClient = new RESTServiceClient(); 
	String taskId = (String)request.getAttribute("taskId");
    String serviceHostURL = restServiceClient.getProperty("software.services.url.base");
    String user = (String)request.getRemoteUser();
    String debugParam = request.getParameter("debug");
%>
<script type="text/javascript"
	src="/irt/resources/js/jquery/min/jquery-latest.js"></script>
<head>
<script type="text/javascript">
var jsonOsType = <%=request.getAttribute("jsonOsType").toString()%>	;
System.out.println("jsonOsType::" + jsonOsType);
var user = "<%=user%>";
var jsonFSType = <%=request.getAttribute("jsonFSType").toString()%>;
System.out.println("jsonFSType::" + jsonFSType);
console.log('jsonFSType::'+ jsonFSType);
//alert(jsonFSType);
</script>
<script type="text/javascript"  src="/irt/resources/js/posting/imageFSAssociation.js"></script>
<script>
<%-- var user = <%=user%>;--%>
var submitUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.CONTINUE_ACTION %>/<%=taskId%>";
var saveUrl = "<%=request.getContextPath()%>/app/perform/<%=ActionConstants.SAVE_ACTION %>/<%=taskId%>";
var dataStr = "";
</script>
<script>
require(["dojo/parser","dojo/domReady!"], function(parser,domReady){
	  // will not be called until DOM is ready
	parser.parse();
	});
</script>
</head>
<body>
	<form id="fsImagesForm">
		<div id="fsImageGridDiv" style="-moz-user-select: none; height: 200px;"></div>
		<div><input type="text" id="testHiddenField" name="testHiddenField" style="display:none;"></input></div>
			<div class="buttonbar">
		    	<button id="saveButton" data-dojo-type="dijit/form/Button" type="button" onclick = "img.saveData();">Save</button>
				<button id="submitButton" data-dojo-type="dijit/form/Button" type="button" >Submit</button>

			</div>
	</form>
	

</body>
