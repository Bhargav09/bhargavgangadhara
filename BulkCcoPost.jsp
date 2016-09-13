<%--.........................................................................
: DESCRIPTION:
:  BULK Cco Post
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2007 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cisco.eit.sprit.util.MonitorUtil" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@taglib uri="spritui" prefix="spritui"%>
<%
MonitorUtil.cesMonitorCall("SPRIT-6.10-CSCsj37581-Bulk Remove for IOS");
%>
<spritui:page title="SPRIT - Bulk Repost/Remove">
  <spritui:header/>
  <div>
  	<center><br/><br/><br/><br/>
  		<spritui:form name="bulkccopost" action="${requestScope.formaction}" validation="true">
  			<h2><center>Bulk Cco Repost/Remove</center></h2>
  			<div id=bulkccopostError></div>
	  		<c:if test="${requestScope.isMainForm or (requestScope.isIndRelForm and not empty requestScope.invalidReleases)}">
	  			<c:if test="${not empty requestScope.invalidReleases}">
	  				<span class="warningTextMed">
	  				The following releases are Invalid. Please check it and resubmit.
	  				<ul>
	  					<c:forEach var="invalidrel"  items="${requestScope['invalidReleases']}">
	  						<li>
	  							<c:out value="${invalidrel}"/>
	  						</li>
	  					</c:forEach>
	  				</ul>
	  				</span>
	  			</c:if>
				<spritui:table>
					<tr>
						<td bgcolor="#d9d9d9" class="dataTableTitleCenter">Os Type</td>
						<td bgcolor="#ffffff" class="dataTableDataCenter">
							<input type="radio" name="osTypeGroup" value="IOS" checked>IOS<br/>
						</td>
					</tr>
					<tr>
						<td bgcolor="#d9d9d9" class="dataTableTitleCenter">Posting Type</td>
						<td bgcolor="#ffffff" class="dataTableDataCenter">
					<input type="radio" name="postingTypeGroup" value="Repost" <c:if test="${requestScope.isRepost}">checked</c:if> >Repost<br/>  
 				    <input type="radio" name="postingTypeGroup" value="Remove" <c:if test="${requestScope.isRemove}">checked</c:if> >Remove<br/> 
<%--							<input type="radio" name="postingTypeGroup" value="Remove" checked>Remove<br/> --%>
						</td>
					</tr>
					<tr>
						<td bgcolor="#d9d9d9" class="dataTableTitleCenter">Release Number(s)</td>
						<td bgcolor="#ffffff" class="dataTableDataCenter">
							<textarea rows="10" cols="60" maxlength="4000" name="releaseNumbers"><c:out value="${param.releaseNumbers}"/></textarea>
						</td>
					</tr>
					<tr>
						<td bgcolor="#ffffff" colspan="2" class="dataTableTitleCenter">
							<spritui:submit name="btnSubmit1" altname="Submit" type="submit"/>
						</td>
					</tr>
				</spritui:table><br/><br/><br/>
			</c:if>
	  		<c:if test="${requestScope.isIndRelForm and empty requestScope.invalidReleases}">
	  		    <input type="hidden" name="osTypeGroup" value="<c:out value="${requestScope.osTypeGroup}"/>"/>
	  		    <input type="hidden" name="postingTypeGroup" value="<c:out value="${requestScope.postingTypeGroup}"/>"/>
	  		    <c:if test="${requestScope.SubmitRequired}">
	   	  			<h2><center>Hit submit to <c:if test="${requestScope.isRepost}">repost</c:if><c:if test="${requestScope.isRemove}">remove</c:if> the release(s)</center></h2>
	   	  		</c:if>
	  		    <c:if test="${not requestScope.SubmitRequired}">
	   	  			<h2><center>Fix the errors and submit again</center></h2>
	   	  		</c:if>
				<spritui:table>
					<tr bgcolor="#d9d9d9">
						<td class="dataTableTitleCenter">Release Number Id</td>
						<td class="dataTableTitleCenter">Release Name</td>
					</tr>
					<c:forEach var="releaseIdAndNumber"  items="${requestScope['ReleaseIdAndNumber']}">
						<tr bgcolor="#ffffff">
							<td class="dataTableData"><c:out value="${releaseIdAndNumber.releaseId}"/></td>
						    <td class="dataTableData"><c:out value="${releaseIdAndNumber.releaseNumber}"/>
							     <input type="hidden" name="relid" value="<c:out value="${releaseIdAndNumber.releaseId}"/>">
						    </td>
						</tr>
					</c:forEach>
					<c:if test="${requestScope.SubmitRequired}">
						<tr>
							<td bgcolor="#ffffff" colspan="2" class="dataTableTitleCenter">
								<spritui:submit name="btnSubmit1" altname="Submit" type="submit"/>
							</td>
						</tr>
					</c:if>
				</spritui:table><br/><br/><br/>
	  		</c:if>
		</spritui:form>
	</center>
  </div>
  <spritui:footer/>
</spritui:page>

<script language="javascript"> <!--
</script>
