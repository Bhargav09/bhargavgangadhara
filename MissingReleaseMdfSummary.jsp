
<%@ page import="java.io.*, com.cisco.eit.sprit.util.*" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>

<html>
<body>

<br>Incomplete MDF information was found for releases that are scheduled to be posted to CCO: <br>
<br>
<%
	String str = request.getParameter("ReleaseInfo");
	System.out.println(str);
	String [][] array = SpritUtility.convertToDoubleArray(str);
%>
<table>
	<tr>
		<td><b><u><nobr>Release Number</nobr></u></b></td>
		<td><b><u><nobr>CCO FCS Date</nobr></u></b></td>
		<td><b><u><nobr>Number of days left</nobr></u></b></td>
	</tr>
<%
	for(int nIndex = 0; nIndex < array.length; nIndex++ ) {
%>		
	<tr>
		<td><%=array[nIndex][0]%></td>
		<td><%=array[nIndex][1]%></td>
		<td><%=array[nIndex][2]%></td>
	</tr>
<%
	}
%>
</table>
<br><br>
This information is required to post to CCO.
<br><br>
-------------------------------------------------------------------------<br>
	<!-- start footer -->
    <%= Footer.pageFooter(true) %>
    <!-- end of footer -->
<br>

</body>
</html>
