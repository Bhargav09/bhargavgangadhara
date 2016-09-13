<!--.........................................................................
: DESCRIPTION:
:     Hidden Post Summary format
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
: @author sakthi (sannakam@cisco.com)
:
: Copyright (c) 2006-2007 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->
<%@ page import="java.io.*, com.cisco.eit.sprit.util.*" %>
<html>
<body>

<br> This mail contains the list of Active Hidden Releases information and expired Hidden Release information
<br>


<br>
<%
	String str = request.getParameter("ReleaseInfo");
	//System.out.println(str);
	if(str!=null&&!str.equals("")) {
		String [][] array = SpritUtility.convertToDoubleArray(str);
%>
<br><b><u>Summary of active IOS Hidden Releases which were posted to CCO: </b></u><br>
<table>
	<tr>
		<td><b><u><nobr>Release Number</nobr></u></b></td>
		<td><b><u><nobr>Expiration Date</nobr></u></b></td>
		<td><b><u><nobr>Primary Release Owner</nobr></u></b></td>
		<td><b><u><nobr>Alternative Release Owner(s)</nobr></u></b></td>
	</tr>
<%
	for(int nIndex = 0; nIndex < array.length; nIndex++ ) {
%>		
	<tr>
		<td><%=array[nIndex][0]%></td>
		<td><%=array[nIndex][1]%></td>
		<td><%=array[nIndex][2]%></td>
		<td><%=array[nIndex][3]%></td>
	</tr>
<%
	}
%>
</table>
<br><br>
<%
	}
%>

<br>
<br>
<%
	String str1 = request.getParameter("ExpiredReleasesInfo");
	//System.out.println(str1);
	if(str1!=null&&!str1.equals(""))
	{
		String [][] array1 = SpritUtility.convertToDoubleArray(str1);
%>
<br><b><u>Summary of Expired IOS Hidden Releases which were posted to CCO:</b></u> <br>
<table>
	<tr>
		<td><b><u><nobr>Release Number</nobr></u></b></td>
		<td><b><u><nobr>Expiration Date</nobr></u></b></td>
		<td><b><u><nobr>Primary Release Owner</nobr></u></b></td>
		<td><b><u><nobr>Alternative Release Owner(s)</nobr></u></b></td>
	</tr>
<%
	for(int nIndex = 0; nIndex < array1.length; nIndex++ ) {
%>		
	<tr>
		<td><%=array1[nIndex][0]%></td>
		<td><%=array1[nIndex][1]%></td>
		<td><%=array1[nIndex][2]%></td>
		<td><%=array1[nIndex][3]%></td>
	</tr>
<%
	}
%>
</table>
<br><br>
<%
	}
%>
	<br><br>
Thanks
<br>


</body>
</html>
