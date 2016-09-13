<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jstl/fmt" %>
<%@taglib uri="spritui" prefix="spritui"%>

<spritui:page title="SPRIT - Document Publish">
  <link rel="stylesheet" type="text/css" href="../js/extjs/resources/css/ext-all.css">
  <!-- @digarg - CSCua51922
 Fixing Ext Calender problem.-->
<link rel="stylesheet" type="text/css" href="../css/ext-date-sprit.css">
  <script type="text/javascript" src="../js/extjs/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="../js/extjs/ext-all-debug.js"></script>
	<script type="text/javascript">
	
		function submitFilterForm() {
			var fd = new Ext.form.DateField({value : document.getElementById('fromDate').value});
			if (!fd.isValid()) {
				alert('Please enter valid From date');
				return false;
			}
			var td = new Ext.form.DateField({value : document.getElementById('toDate').value});
			if (!td.isValid()) {
				alert('Please enter valid To date');
				return false;
			}
			if (td.getValue() < fd.getValue()) {
				alert('Select valid date range. From date should be smaller than To date');
				return false;
			}
			document.docPublishFilterForm.submit();
		}
		
		function renderHLNK(url) {
			return '<a href="' + url + '">' + url + '</a>';
		}
		
		function chkBox(val) {
			return '<spritui:checkbox name="relQ_' + val + '" value="' + val + '" checked="false"/>';
		}
		
		function getExtDateFieldInstance(elementName, divLocation, dtVal) {
			var dateField = new Ext.form.DateField({format : "m/d/Y",
													value  : dtVal,
													name : elementName,
													id : elementName});
			dateField.render(Ext.get(divLocation));
		};
		
		function createDataGridInstance(dataStore, divLocation, cssCls) {
			var sm = new Ext.grid.CheckboxSelectionModel();
			var grid = new Ext.grid.GridPanel({
							store: dataStore,
							stripeRows: true, 
							ctCls: cssCls, 
							autoExpandColumn: 'failureMessage', 
							sm: sm, 
							cm: new Ext.grid.ColumnModel([
								sm, 
								{id:'documentID',header: 'DocID', sortable: true, dataIndex: 'documentID'},
	            				{header: 'SourceLocation', sortable: true, dataIndex: 'sourceLocation'},
	            				{header: 'Doc Last Modified', sortable: true, renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'documentLastModified'},
	            				{header: 'OS Type', sortable: true, dataIndex: 'osType'},
	            				{header: 'Status', sortable: true, dataIndex: 'status'},
	            				{header: 'URL', sortable: true, renderer: renderHLNK, dataIndex: 'url'},
	            				{header: '#FTP Attempts', sortable: true, dataIndex: 'noOfFTPAttempts'},
	            				{header: '#Poll Attempts', sortable: true, dataIndex: 'noofPollAttempts'},
	            				{id: 'failureMessage', header: 'Failure Message', sortable: true, dataIndex: 'failureMessage'},
	            				{header: 'User Id', sortable: true, dataIndex: 'userId'}
							])
					   });
			
			grid.render(Ext.get(divLocation));
			
		};
		
		Ext.onReady(function(){
			Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
			
			getExtDateFieldInstance('fromDate', 'fromDT', '<fmt:formatDate value="${requestScope['dtFrom']}" type="DATE" pattern="MM/dd/yyyy"/>');
			getExtDateFieldInstance('toDate', 'toDT', '<fmt:formatDate value="${requestScope['dtTo']}" type="DATE" pattern="MM/dd/yyyy"/>');
			
			// Load data from response to JavaScript object here
			var responseData = [];
			var i = 0;
				<c:forEach var="docPublishReleaseQ"  items="${requestScope['releaseQList']}">
					responseData[i++] = ['<c:out value="${docPublishReleaseQ.id}"/>', '<c:out value="${docPublishReleaseQ.sourceLocation}"/>', '<fmt:formatDate value="${docPublishReleaseQ.docLastModifiedDateTime}" type="DATE" pattern="MM/dd/yyyy"/>', '<c:out value="${docPublishReleaseQ.osType}"/>', '<c:out value="${docPublishReleaseQ.status}"/>', '<c:out value="${docPublishReleaseQ.url}"/>', '<c:out value="${docPublishReleaseQ.ftpRetryCount}"/>', '<c:out value="${docPublishReleaseQ.availableRetryCount}"/>', '<c:out value="${docPublishReleaseQ.failureMessage}"/>', '<c:out value="${docPublishReleaseQ.createdBy}"/>'];
				</c:forEach>
			
			// create data structure for grid
			var dataStore = new Ext.data.SimpleStore({
				fields: [
					{name: 'documentID'},
					{name: 'sourceLocation'},
					{name: 'documentLastModified', type: 'date', dateFormat: 'n/j h:ia'},
					{name: 'osType'},
					{name: 'status'},
					{name: 'url'},
					{name: 'noOfFTPAttempts'},
					{name: 'noofPollAttempts'},
					{name: 'failureMessage'},
					{name: 'userId'}
				]
			});
			
			dataStore.loadData(responseData);
			
			// render grid here
			//createDataGridInstance(dataStore, 'dataGrid', 'dataTableTitleCenter');
			
		});
	</script>
  <spritui:header/>
  <div>
  	<center>
  		<spritui:error errors="${requestScope.ErrorMessage}"/>
    	<h3>Document Publish Status</h3>
    	<spritui:form name="docPublishFilterForm" action="${requestScope.formaction}" validation="true">
    		<input type="hidden" = name="refresh" id="refresh" value="refresh" />
  			<table>
  				<tr bgcolor="#d9d9d9">
  					<td width="10%" class="dataTableTitle">From:</td>
					<td width="25%" class="dataTableData">
						<div id='fromDT'/>
					</td>
  					<td width="10%" class="dataTableTitle">To:</td>
					<td width="25%" class="dataTableData">
						<div id='toDT'/>
					</td>
					<td width="30%"><input type="button" name="Go" value="Go" onClick="return submitFilterForm();" /> <input type="reset" name="btnReset" altname="Reset"  /></td>
  				</tr>
  			</table>
  			<br>
    	</spritui:form>
  		<spritui:form name="docPublishDataForm" action="${requestScope.formaction}" validation="true">
  			<div id=docPublishDataFormError></div>
  			<div id='dataGrid'></div>
  			<br />
  			<spritui:table>
				<tr bgcolor="#d9d9d9">
					<td align="center" valign="top" class="dataTableTitleCenter">
						Select<br/>
							<a href="javascript:checkboxSetAllByPrefix('docPublishDataForm','relQ_', true)"><img src="../gfx/btn_all_mini.gif" border="0"/></a>
							<a href="javascript:checkboxSetAllByPrefix('docPublishDataForm','relQ_', false)"><img src="../gfx/btn_none_mini.gif" border="0" /></a>
					</td>
					<td class="dataTableTitleCenter">Document ID</td>
					<td class="dataTableTitleCenter">Source Location</td>
					<td class="dataTableTitleCenter">Document Last Modified</td>
					<td class="dataTableTitleCenter">OS TYPE</td>
					<td class="dataTableTitleCenter">STATUS</td>
					<td class="dataTableTitleCenter">URL</td>
					<td class="dataTableTitleCenter">No Of FTP Attempts</td>
					<td class="dataTableTitleCenter">No of Poll Attempts</td>
					<td class="dataTableTitleCenter">Failure Message</td>
					<td class="dataTableTitleCenter">User Id</td>
				</tr>
				<c:forEach var="docPublishReleaseQ"  items="${requestScope['releaseQList']}">
				<tr bgcolor="#ffffff">
					<td class="dataTableData"><spritui:checkbox name="relQ_${docPublishReleaseQ.id}" value="${docPublishReleaseQ.id}" checked="false"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.id}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.sourceLocation}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.docLastModifiedDateTime}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.osType}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.status}"/></td>
					<td class="dataTableData"><a href='<c:out value="${docPublishReleaseQ.url}"/>'><c:out value="${docPublishReleaseQ.url}"/></a></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.ftpRetryCount}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.availableRetryCount}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.failureMessage}"/></td>
					<td class="dataTableData"><c:out value="${docPublishReleaseQ.createdBy}"/></td>
				</tr>
				</c:forEach>
			</spritui:table>
			<center><br>			<spritui:submit name="btnSubmit" altname="Submit" type="submit"/> </center>
  			</spritui:form>
		</center>
	 </div>
	<spritui:footer/>
</spritui:page>