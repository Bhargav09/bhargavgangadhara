<!--.........................................................................
: DESCRIPTION:
: Feature Set pop up for Management Metadata Feature (createMetadta and editMetadata for Non-Ios
: 
:
: AUTHORS:
: CSCud06651	
: @author Divya Garg (digargt@cisco.com)
:
: Copyright (c) 2012 by Cisco Systems, Inc. 
: All rights reserved.
:.........................................................................-->
<%@page
	import="com.cisco.eit.sprit.model.adminfeaturesetjdbc.AdminFeatureSetJdbc"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>


<%@ page import="com.cisco.eit.sprit.util.MonitorUtil"%>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUI"%>
<%@ page import="com.cisco.eit.sprit.gui.Footer"%>
<%@ page import="com.cisco.eit.sprit.ui.SpritGUIBanner"%>
<%@ page import="com.cisco.eit.sprit.util.SpritConstants"%>
<%@ page import="com.cisco.eit.sprit.util.SpritGlobalInfo"%>
<%@ page import="com.cisco.eit.sprit.util.SpritInitializeGlobals"%>
<%@ page import="com.cisco.rtim.ui.TableMaker"%>
<%@ page import="com.cisco.eit.sprit.util.JNDIContext"%>
<%@ page import="com.cisco.eit.sprit.util.ParseString"%>
<%@ page import="com.cisco.eit.sprit.dataobject.FeatureSetNonIosInfo"%>
<%@ page import="com.cisco.eit.sprit.model.dao.csprfeatureset.CsprFeatureSetDAO"%>
<%@ page import="com.cisco.eit.sprit.spring.SpringUtil"%>
<%@ page import="com.cisco.eit.sprit.util.SpritAccessManager"%>

<%
	SpritGlobalInfo globals;
	SpritGUIBanner banner;
	String pathGfx;
	TableMaker tableReleasesYouOwn;
	CsprFeatureSetDAO dao = null;

	// Initialize globals  
	globals = SpritInitializeGlobals.init(request, response);
	pathGfx = globals.gs("pathGfx");
 
	// Set up banner for later
	banner = new SpritGUIBanner(globals);
	SpritAccessManager acc;
	acc = (SpritAccessManager) globals.go("accessManager");
	String userId = acc.getUserId();
%>
<%=SpritGUI.pageHeader(globals, "", "")%>

<span class="headline"> Select Feature Set Name And Description </span>
<br />
<br />


<%
	Integer osTypeId = Integer.valueOf((String) request
			.getParameter("osTypeId"));
	Integer imageId = Integer.valueOf((String) request
			.getParameter("imageId") != null ? (String) request
			.getParameter("imageId") : "0");
	new MonitorUtil().jspCallMonitor(globals, request,
			"Sprit 7.0 MCP productization for management metadata");
%>

<html>
<body>
<center>
<table style = border="1" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td background="pathGfx/hdr_center_left.gif"><img src="pathGfx/b1x1.gif"/></td>
<td class="contextNavTitle" bgcolor="#ffff00\" align="middle" width="1974"><font color = "red" size = "2"><b>To Associate the feature-set to the image IsGoingToCCO flag should be set to 'Y'.Please contact SPRIT-Team to change flag for Feature Set.</b></font></td>
</tr>
</table>
<br>
<br>
		<form name="featureSetPopup">
			<table border="0" cellpadding="1" cellspacing="0">
				<tr>
					<td colspan="3" align="center"><a
						href="javascript:CheckonAssign()"><img
							src="../gfx/btn_save_updates.gif" border="0" /></a></td>
				</tr>
				<tr>
					<td bgcolor="#3D127B">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td bgcolor="#BBD1ED">
									<table border="0" cellpadding="3" cellspacing="1">
										<tr bgcolor="#d9d9d9">
											<td align="center" valign="top"><span
												class="dataTableTitle"> FeatureSet Name </span></td>
											<td align="center" valign="top"><span
												class="dataTableTitle"> FeatureSet Description</span></td>
											<td align="center" valign="top"><span
												class="dataTableTitle"> Is Going to CCO </span></td>
											<td align="center" valign="top"><span
												class="dataTableTitle"> Select </span></td>
										</tr>

										<%
											dao = (CsprFeatureSetDAO)SpringUtil.getApplicationContext().getBean("csprFeatureSetDAO");
											List featureSetVector = dao.getNonIosRecords(osTypeId);
											List featureSetNameList = dao.getImageNonIosRecords(osTypeId, imageId);
											List featureSetId = new ArrayList();
											for (int i = 0; i < featureSetNameList.size(); i++) {
												FeatureSetNonIosInfo fsinfo1 = (FeatureSetNonIosInfo) featureSetNameList.get(i);				
												featureSetId.add(fsinfo1.csprfeatureSetId);
											}
											for (int index = 0; index < featureSetVector.size(); index++) {
												FeatureSetNonIosInfo fsinfo = (FeatureSetNonIosInfo) featureSetVector.get(index);
												String featureSetName = fsinfo.getFeatureSetName();
												String featureSetDescription = fsinfo.getFeatureSetDesc();
												Integer csprFeatureSetId = fsinfo.getCsprfeatureSetId();
												String isGoingToCco = fsinfo.getIsFSetGoingToCCO();
										%>

										<tr bgcolor="#ffffff">

											<td><span class="dataTableData"> <%=featureSetName%>
											</span></td>
											<td><span class="dataTableData"> <%=featureSetDescription%>
											</span></td>
											<td><span class="dataTableData"> <%=isGoingToCco%>
											</span></td>
											<td><span class="dataTableData"> <input
													type="checkbox"
													value="<%=featureSetName%>:<%=featureSetDescription%>:<%=isGoingToCco%>+<%=csprFeatureSetId%>"
													<%if (featureSetId.contains(fsinfo.getCsprfeatureSetId())) {%>
													checked <%}%> name="featureSetCcoInfo"
													id="featureSetCcoInfo">
											</span></td>

										</tr>
										<%
											}
										%>
									</table>
								</td>
							</tr>
						</table>

					</td>
				</tr>
				<tr>
					<td colspan="3" align="center"><a
						href="javascript:CheckonAssign()"><img
							src="../gfx/btn_save_updates.gif" border="0" /></a></td>
				</tr>
			</table>


		</form>
	</center>
	<script language="javascript">
		function CheckonAssign() {

			var assignToFeature = document
					.getElementsByName("featureSetCcoInfo");
			var multipleFeature = "";
			var FeatureSet = "";

			for ( var i = 0; i < assignToFeature.length; i++) {
				if (assignToFeature[i].checked) {

					if (FeatureSet != "") {
						FeatureSet += ",";
					}

					var Feature = assignToFeature[i].value;
					FeatureSet += Feature;
					var splitString = Feature.split("+");
					multipleFeature += "<li>";
					multipleFeature += splitString[0];

				}
			}

			window.opener.document.getElementById("featuresetdisplay").innerHTML = multipleFeature;
			window.opener.document.getElementById("featuresetInfo").value = FeatureSet;

			self.close();
		}
	</script>

</body>
</html>

<%=Footer.pageFooter(globals) %>

<!-- end -->
