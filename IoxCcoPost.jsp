<!--.........................................................................
: DESCRIPTION:
:  IOX Cco Post
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2006-2007, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cisco.eit.sprit.beans.IoxCcoInfoBean" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublishiox.IoxPostHelper" %>
<%@ page import="java.util.*" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@taglib uri="spritui" prefix="spritui"%>

<spritui:page title="SPRIT - IOX Posting">
  <spritui:header tabType="iox" activeTab="cco"/>
  <c:out value="${requestScope['subheader']}" escapeXml="false"/>
  <div>
  	<center><br/><br/><br/><br/>
  	    <c:if test="${requestScope.isConfirmRequest}">
			<b><font face="Arial,Helvetica" color="#FF0000">
	  			(Hit Submit to Confirm and initiate <c:out value="${requestScope.postingString}"/>)</font></b>
  	    </c:if>
  	    <c:if test="${not requestScope.isConfirmRequest}">
	  		<h2><c:out value="${requestScope.postingString}"/></h2>
  	    </c:if>
		<c:if test="${not empty requestScope.CcoPostErrorMessage}">
                <table border="0" cellpadding="1" cellspacing="0">
                	   <tr><td class="warningTextMed">
                         <ul>
                    		<li><span><c:out value="${requestScope.CcoPostErrorMessage}"/></span></li>
                          </ul>
                    </td></tr>
                </table>
		
			<spritui:error errors="${requestScope.CcoPostErrorMessage}"/>
		</c:if>
  		<spritui:error errors="${requestScope.ErrorMessage}"/>
  		<div id="outageMessage" class="warningDiv" style="display: none;"></div>
  		<spritui:form name="ioxpost" action="${requestScope.formaction}" validation="true" jsValidationMethod="submitIoxPost">
  				<div id="ioxpostError"></div><br/>
  				<c:if test="${not (param.submode eq 'confirm')}">
					<spritui:table>
						<tr bgcolor="#d9d9d9">
							<td class="dataTableTitleCenter">Total Images</td>
							<td class="dataTableTitleCenter">Images Missing</td>
							<td class="dataTableTitleCenter">Images Already Posted</td>
							<td class="dataTableTitleCenter">Images Ready to be <c:if test="${param.mode eq 4}">Removed</c:if><c:if test="${param.mode ne 4}">Posted</c:if></td>
							<td class="dataTableTitleCenter">Images being <c:if test="${param.mode eq 4}">Removed</c:if><c:if test="${param.mode ne 4}">Posted</c:if></td>
						</tr>
						<tr bgcolor="#ffffff">
								  <td class="dataTableDataCenter"><c:out value="${requestScope['NoOfTotalImages']}"/></td>
								  <td class="dataTableDataCenter"><c:out value="${requestScope['NoOfImagesWithoutImageFile']}"/></td>
								  <td class="dataTableDataCenter"><c:out value="${requestScope['NoOfImagesAlreadyPosted']}"/></td>
								  <td class="dataTableDataCenter"><c:out value="${requestScope['NoOfImagesReadyToBePosted']}"/></td>
								  <td class="dataTableDataCenter"><c:out value="${requestScope['NoOfImagesBeingPosted']}"/></td>
						</tr>
					</spritui:table><br/><br/><br/>
            </c:if>
            <% Integer releaseNumberId = (Integer) request.getAttribute("releaseNumberId");%>
            <c:if test="${param.mode eq 2}">
				<c:if test="${not requestScope.isConfirmRequest}">
					<spritui:table>
		                <jsp:include page="inc_ccopostinfo.jsp">
						    <jsp:param name="releaseNumberId" value="<%=releaseNumberId%>" />
						    <jsp:param name="osTypeId" value="2" />
						</jsp:include>
					</spritui:table>
				</c:if>
				<c:if test="${requestScope.isConfirmRequest}">
					<table border="0" cellpadding="0" cellspacing="0">   <tr>      <td bgcolor="#3D127B">         <table border="0" cellpadding="0" cellspacing="0" width="100%">            <tr>               <td bgcolor="#BBD1ED">                  <table border="0" cellpadding="0" cellspacing="1" width="100%">
						<tr>
							<td valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
							  Release Notes Location</span></td>
							<td valign="top" bgcolor="#ffffff"><span class="dataTableData">
								<c:if test="${not empty requestScope.ReleaseUrlAsString}">
									<table border="0" cellpadding="0" cellspacing="0" width="100%">   <tr>      <td bgcolor="#3D127B">         <table border="0" cellpadding="0" cellspacing="0" width="100%">            <tr>               <td bgcolor="#BBD1ED">                  <table border="0" cellpadding="3" cellspacing="1" width="100%">
										<tr valign="top" bgcolor="#ffffff">
											<td align="left" valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
												Release Note Label
											</span></td>
											<td align="left" valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
												Release Note Label URL
											</span></td>
										</tr>
										<c:out value="${requestScope['ReleaseUrlAsString']}" escapeXml="false"/>
									</table></td></tr></table></td></tr></table>
								</c:if>
							</span></td>
					    </tr>
						<tr>
							<td valign="top" bgcolor="#d9d9d9"><span class="dataTableTitle">
							  Release Message</span></td>
							<td valign="top" bgcolor="#ffffff"><span class="dataTableData">
							  <c:out value="${requestScope['ReleaseMessage']}"/></span></td>
					    </tr>
					</table></td></tr></table></td></tr></table>
				</c:if>
            </c:if>
            <c:if test="${param.mode eq 2 or param.mode eq 4}">
            	<h3>Email Notifications</h3>
	  				<spritui:table>
									<tr bgcolor="#d9d9d9">
										<td class="dataTableTitleCenter">IOX CCO POST Complete Alias List</td>
										<td class="dataTableData" bgcolor="#ffffff">
											<c:out value="${requestScope.postCompleteEmailAliasList}"/><br/>
											<c:if test="${not requestScope.isConfirmRequest}">
												<spritui:textbox name="CompleteEmailAliasList" value="" size="25" validation="true"/>
											</c:if>
											<c:if test="${requestScope.isConfirmRequest}">
												<spritui:hidden name="CompleteEmailAliasList" value="${param.CompleteEmailAliasList}"/>
											</c:if>
										</td>
									</tr>
	  				</spritui:table><br/><br/><br/>
				</c:if>
  				<spritui:table>
					<tr bgcolor="#d9d9d9">
						<c:if test="${requestScope.noerrors and (param.mode eq 2 or param.mode eq 4) and not requestScope.isConfirmRequest}">
							<td align="center" valign="top" class="dataTableTitleCenter">
								Select<br/>
									<a href="javascript:checkboxSetAllByPrefix('ioxpost','img_', true)"><img src="../gfx/btn_all_mini.gif" border="0"/></a>
									<a href="javascript:checkboxSetAllByPrefix('ioxpost','img_', false)"><img src="../gfx/btn_none_mini.gif" border="0" /></a>
							</td>
						</c:if>	
						<td class="dataTableTitleCenter">Image Name</td>
						<td class="dataTableTitleCenter">Cco Directory</td>
						<td class="dataTableTitleCenter">Description</td>
						<td class="dataTableTitleCenter">Image Size</td>
						<td class="dataTableTitleCenter">Type</td>
						<td class="dataTableTitleCenter">Status</td>
						<td class="dataTableTitleCenter">Original CCO Post date</td>
						<c:if test="${requestScope.isAdminHFR}">
							<td><span class="dataTableTitleCenter">Encrypt Value</span></td>
						</c:if>
					</tr>
					<c:forEach var="ccoinfobean"  items="${requestScope['images']}">
						<c:if test="${not (param.submode eq 'confirm' and not ccoinfobean.isSelected)}">
							<tr bgcolor="#ffffff">
								<c:if test="${requestScope.noerrors and (param.mode eq 2 or param.mode eq 4)}">
									<c:if test="${ccoinfobean.allowedToPost}">
										<c:if test="${param.submode eq 'confirm' and ccoinfobean.isSelected}">
											<spritui:hidden name="img_${ccoinfobean.imageId}" value="${ccoinfobean.imageId}"/>
										</c:if>
										<c:if test="${ not (param.submode eq 'confirm' and ccoinfobean.isSelected)}">
											<td class="dataTableDataCenter">
												<spritui:checkbox name="img_${ccoinfobean.imageId}" value="${ccoinfobean.imageId}" checked="false"/>												
											</td>
										</c:if>
									</c:if>
									<c:if test="${not ccoinfobean.allowedToPost}">
										<td></td>
									</c:if>
								</c:if>	

							  <td class="dataTableData"><c:out value="${ccoinfobean.imageName}"/></td>
							  <td class="dataTableData"><c:out value="${ccoinfobean.ccoDir}"/></td>
							  <td class="dataTableData"><c:out value="${ccoinfobean.description}"/></td>
							  <td class="dataTableData"><c:out value="${ccoinfobean.imageSize}"/></td>
							  <td class="dataTableData"><c:out value="${ccoinfobean.imageType}"/></td>
							  <td class="dataTableData"><c:out value="${ccoinfobean.imageStatus}"/></td>
							  <td class="dataTableData"><c:out value="${ccoinfobean.ccoPostTime}"/></td>
							  <c:if test="${requestScope.isAdminHFR}">
								  <td class="dataTableData"><c:out value="${ccoinfobean.cryptoValue}"/></td>
							 </c:if>
							</tr>
						</c:if>
 					 </c:forEach>
  				</spritui:table><br/><br/><br/>
				<c:if test="${requestScope.noerrors and (param.mode eq 2 or param.mode eq 4)}">
					<c:if test="${requestScope.isConfirmRequest}">
						<spritui:submit name="btnSubmit1" altname="Confirm" clickmethod="submitCco('ioxpost')" type="confirm"/>
					</c:if>
					<c:if test="${not requestScope.isConfirmRequest}">
					<spritui:outage name="ypublish">
						<spritui:submit name="btnSubmit1" altname="Submit" clickmethod="submitCco('ioxpost')" type="submit"/>
					</spritui:outage>
					</c:if>
				</c:if>
  			</spritui:form>
		</center>
	 </div>
	<spritui:footer/>
</spritui:page>

<script language="javascript"> <!--

function submitIoxPost(formObj) {
	<c:if test="${param.mode eq 2 and not requestScope.isConfirmRequest}">
	    var errorMessage = objReleaseNotes.validateReleaseNotes();
        if(errorMessage != '') {
		   alert('Error:\n'+errorMessage);
           return false;
	    }
	</c:if>
    return true;
}
function releaseNoteIsRequired(objLabel, objNote) {
	var isEitherOneEmpty = false;
	var message = '';
	if (objLabel != null) {
		for(i=0;i<objLabel.length;i++) {
			//If both Label and URL are empty its not an error
			if((trim(objLabel[i].value).length == 0) && (trim(objNote[i].value).length == 0))
				continue;
			
			if (trim(objLabel[i].value).length == 0) {
				message = 'Release Note Label is Required\n';
				isEitherOneEmpty = true;
			}
			
			if(trim(objNote[i].value).length == 0) {
				message = message + 'Release Note URL is Required\n';
				isEitherOneEmpty = true;
			}
			
			if(isEitherOneEmpty)
				return message;
		}
	}
	
	return message;			
}
</script>
