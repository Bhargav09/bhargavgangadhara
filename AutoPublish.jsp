<!--.........................................................................
: DESCRIPTION:
:  Auto Publish Release Queue
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2006-2007 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@taglib uri="spritui" prefix="spritui"%>

<spritui:page title="SPRIT - Auto Publish">
  <spritui:header/>
  <div>
  	<center><br/><br/><br/><br/>
  		<spritui:error errors="${requestScope.ErrorMessage}"/>
    	<h3>Auto Publish Release Queue</h3>
  		<spritui:form name="autoPublishForm" action="${requestScope.formaction}">
  		    <div id=autoPublishFormError></div>
  			<spritui:table>
  				<tr bgcolor="#d9d9d9">
  					<td class="dataTableTitle">From:</td>
					<td class="dataTableData"><spritui:textbox name="fromDate" value="" size="15" validation="true"/></td>
  					<td class="dataTableTitle">To:</td>
					<td class="dataTableData"><spritui:textbox name="toDate" value="" size="15" validation="true"/></td>
  				</tr>
  			</spritui:table>
  			<br><br>
			<spritui:table>
				<tr bgcolor="#d9d9d9">
					<td align="center" valign="top" class="dataTableTitleCenter">
						Select<br/>
							<a href="javascript:checkboxSetAllByPrefix('autoPublishForm','relQ_', true)"><img src="../gfx/btn_all_mini.gif" border="0"/></a>
							<a href="javascript:checkboxSetAllByPrefix('autoPublishForm','relQ_', false)"><img src="../gfx/btn_none_mini.gif" border="0" /></a>
					</td>
					<td class="dataTableTitleCenter">Release Number</td>
<%--					<td class="dataTableTitleCenter">Os Type</td>    --%>
					<td class="dataTableTitleCenter">Transaction Id</td>
					<td class="dataTableTitleCenter">Predeccesor<br>Transaction Id</td>
					<td class="dataTableTitleCenter">Transaction Type</td>
					<td class="dataTableTitleCenter">Transaction Status</td>
					<td class="dataTableTitleCenter">No Of Attempts</td>
					<td class="dataTableTitleCenter">Error Message</td>
					<td class="dataTableTitleCenter">Is Metadata Check Done</td>
					<td class="dataTableTitleCenter">User Id</td>
				</tr>
				<c:forEach var="autoPublishReleaseQ"  items="${requestScope['releaseQList']}">
				<tr bgcolor="#ffffff">
					<td class="dataTableData"><spritui:checkbox name="relQ_${autoPublishReleaseQ.id}" value="${autoPublishReleaseQ.id}" checked="false"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.releaseNumber}"/></td>
<%--					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.osType}"/></td> --%>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.transactionId}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.predTransactionId}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.ccoTransactionType}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.ccoTransactionStatus}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.noOfAttempts}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.errorMessage}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.isMetadataCheckDone}"/></td>
					<td class="dataTableData"><c:out value="${autoPublishReleaseQ.createdBy}"/></td>
				</tr>
				</c:forEach>
			</spritui:table>
			<center><br>			<spritui:submit name="btnSubmit" altname="Submit" type="submit"/> </center>
  			</spritui:form>
		</center>
	 </div>
	<spritui:footer/>
</spritui:page>