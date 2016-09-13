<!--.........................................................................
: DESCRIPTION:
: CCO Readiness Report page.
:
: AUTHORS:
: @author Kelly Hollingshead (kellmill)
: @author Rakesh Kamath (rakkamat)
:
: Copyright (c) 2006-2007, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Iterator" %>

<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="javax.rmi.PortableRemoteObject"%>

<%@ page import="com.cisco.rtim.util.WebUtils" %>

<%@ page import="com.cisco.eit.sprit.logic.imagelist.*" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.*" %>
<%@ page import="com.cisco.eit.sprit.model.imagetype.*" %>
<%@ page import="com.cisco.eit.sprit.ui.*" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>
<%@ page import="com.cisco.eit.sprit.util.*" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelHomeLocal" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelInfo" %>
<%@ page import="com.cisco.eit.sprit.model.releasenumbermodel.ReleaseNumberModelLocal" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@ taglib  uri="http://java.sun.com/jstl/fmt" prefix="fmt" %>

<%
	// Get release number ID.  Try to convert it to an Integer from the web value!
	Integer releaseNumberId = null;
	try {
	  releaseNumberId = new Integer(
	      WebUtils.getParameter(request,"releaseNumberId"));
	} catch( Exception e ) {
	  // Nothing to do.
	}
	if( releaseNumberId==null ) {
	  // No release number!  Bad!  Redirect to error page.
	  %>
	    <jsp:forward page="ReleaseNoId.jsp" />
	  <%
	}

  MonitorUtil monUtil = new MonitorUtil();
  monUtil.jspCallMonitor(SpritInitializeGlobals.init(request,response), request, "CCO Post Readiness Report");

  SpritGlobalInfo globals;
  SpritGUIBanner banner;
  globals = SpritInitializeGlobals.init(request,response);

Integer	postingTypeId = null;
try {
    String jndiName = "ReleaseNumberModel.ReleaseNumberModelHome";
    InitialContext ctx = new InitialContext();
    ReleaseNumberModelHomeLocal rnmHome = (ReleaseNumberModelHomeLocal) ctx.lookup("ejblocal:"+jndiName);
    ReleaseNumberModelLocal rnmObj = rnmHome.create();
    ReleaseNumberModelInfo rnmInfo = rnmObj.getReleaseNumberInfo( globals,releaseNumberId );
    postingTypeId =rnmInfo.getPostingTypeId();
} catch(Exception e) {
	e.printStackTrace();
	}
  // Initialize globals
  SpritAccessManager  spritAccessManager = (SpritAccessManager) globals.go( "accessManager" );
  //String user =  spritAccessManager.getUserId();
  

  // Set up banner for later
  banner =  new SpritGUIBanner( globals );
  banner.addReleaseNumberElement(releaseNumberId);

%>

<%= SpritGUI.pageHeader( globals,"CCO Readiness Report","" ) %>
<%= banner.render() %>
<%= SpritReleaseTabs.getTabs(globals, "cco") %>

  <table border="0" cellpadding="3" cellspacing="0" width="100%">
    <tr bgcolor="#BBD1ED">
        <td valign="middle" width="70%" align="left">
          <%
             out.println( CcoPostHelper.getIOSSecondaryToolBar(globals, spritAccessManager, releaseNumberId, YPublishConstants.CCO_READINESS_REPORT));
           %>
         </td>
      </tr>
   </table>
<%
   Iterator ImageListInfoVector = null;
   Collection imageListCollection = null;
   ImageListSessionHome mImageListSessionHome = null;
   ImageListSession mImageListSession = null;

   try
   {
       Context ctx = JNDIContext.getInitialContext();
       Object homeObject = ctx.lookup("ImageListSessionBean.ImageListSessionHome");
       mImageListSessionHome = (ImageListSessionHome)PortableRemoteObject.narrow(homeObject, ImageListSessionHome.class);
       mImageListSession = mImageListSessionHome.create();
       imageListCollection = mImageListSession.getAllImageListInfoUtil(releaseNumberId);
   }
   catch(Exception e)
   {
       e.printStackTrace();
   }   
%>  
	<jsp:useBean id="statusGroup" scope="request" type="com.cisco.eit.sprit.rule.RulesStatusGroup" />
	<c:if test="${requestScope.statusGroup == null}">
		<div id="ccoReadinessError" class="warningDiv">
			<span>Error</span>
			<ul>
				<li>CcoReadiness report could not be executed due to technical difficulty. Please contact 
					SPRIT support for assistance.</li>
			</ul>
		</div>
	</c:if>
	
	<c:if test="${statusGroup != null && not empty statusGroup.exceptionMessages}">
		<div id="ccoReadinessException" class="warningDiv">
			<span>Exceptions</span>
			The following rules could not verified due to technical difficulty. Please contact SPRIT support for assistance.
			<ul>
				<c:forEach items="${statusGroup.exceptionMessages}" var="exception">
					<li><c:out value="${exception.rules.description}" /></li>
				</c:forEach>
			</ul>
		</div>
	</c:if>
	<table width="100%">
		<tr style="vertical-align: top">
			<td width="70%" align="center"><br />
				<%=ImageListGUI.htmlSummarize(imageListCollection)%>
			</td>
			<td width="30%">
				<!-- Outage Table -->
				<c:if test='${not empty outages}'>
				<div>
		    	  <table border="1" class="dataTable smallText" align="right">
		    	  <caption style="font-size: 90%" align="center"><b>Scheduled Outages</b></caption>					
		    	  	<tr>
						<th>Outage Type</th>
						<th>Start Date & Time</th>
						<th>End Date & Time</th>
						<th>Message</th>
					</tr>
					<c:forEach items='${outages}' var='outageVO'>
					<tr>
						<td><c:out value='${outageVO.outageTypeName}' /></td>
						<td><fmt:formatDate value='${outageVO.startDateTime}' type='both' dateStyle='short' timeStyle='short' /></td>
						<td><fmt:formatDate value='${outageVO.endDateTime}' type='both' dateStyle='short' timeStyle='short' /></td>
						<td><c:out value='${outageVO.message}' /></td>
					</tr>
					</c:forEach>
				</table>
				</div>
				</c:if>
				<c:if test='${empty outages}'>
					&nbsp;
				</c:if>
			</td>
		</tr>
	</table>
	<br />
	<c:if test="${statusGroup != null}">
		<table class="dataTable">
		<caption align="center"><b>CCO Readiness Report</b></caption>
			<tr>
				<th width="2%"></th>
				<th width="8%">Status</th>
				<th width="30%">Description</th>
				<th width="60%">Detail</th>
			</tr>
			<c:if test="${not empty statusGroup.errorMessages}">
				
				<c:forEach items="${statusGroup.errorMessages}" var="errorStatus">
				<tr style="vertical-align: top">
					<td><img src="../gfx/ico_cross_red.gif" alt="error icon" align="middle" /></td>
					<td><span class="errorText"><c:out value="Error" /></span></td>
					<td><c:out value="${errorStatus.rules.description}" /></td>
					<td style="padding: 0">
						<c:out value="${errorStatus.messageTitle}"  escapeXml="false" />
						<span class="smallText">
						<c:if test="${not empty errorStatus.message}">
							<ul>
							<c:forEach items="${errorStatus.message}" var="message">
								<li>
									<c:out value="${message}" />
								</li>	
							</c:forEach>
							</ul>
						</c:if>
						</span>
					</td>
				</tr>
				</c:forEach>
			</c:if>
			<c:if test="${not empty statusGroup.warningMessages}">
				<c:forEach items="${statusGroup.warningMessages}" var="warning">
				<tr style="vertical-align: top">
					<td><img src="../gfx/ico_warning.gif" alt="warning icon" align="middle" /></td>
					<td><span  class="warningText"><c:out value="Warning" /></span></td>
					<td><c:out value="${warning.rules.description}" /></td>
					<td style="padding: 0">
						<c:out value="${warning.messageTitle}" escapeXml="false" />
						<span class="smallText">
						<c:if test="${not empty warning.message}">
							<ul>
							<c:forEach items="${warning.message}" var="message">
								<li>
									<c:out value="${message}"/>
								</li>	
							</c:forEach>
							</ul>
						</c:if>
						</span>
					</td>
				</tr>
				</c:forEach>
			</c:if>
		</table>
	</c:if>

<%=Footer.pageFooter(globals)%>

<!-- end -->
