<%--.........................................................................
: DESCRIPTION:
:     ERP Platform Missing Email
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2006-2007, 2013 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................--%>
<%@ page import="com.cisco.eit.sprit.util.*" %>
<html>
<body>
<%
	String strMissingErpPlatforms = request.getParameter("setPlatformsMissingErp");
	String pCodeGroupAndPlatformHtml = request.getParameter("listOfDuplicateErp");
	if(strMissingErpPlatforms != null &&
			!"".equals(strMissingErpPlatforms.trim()) ) {
		String [] array = SpritUtility.convertToArray(strMissingErpPlatforms, ",");
%>
<b>Following Platforms are missing the Platform Product Family in SPRIT.  
The Platform Product Family must be assigned in SPRIT prior to OPUS submission.
</b>
<ul>
	<% for(int i=0; i<array.length; i++) { 
		  if(array[i] != null && !"".equals(array[i])) {
	%>		
		<li>
			<%=array[i]%>
		</li>
	<%   } 
	   }
	%>
</ul>	
<%
	}
	
	if(pCodeGroupAndPlatformHtml != null &&
			!"".equals(pCodeGroupAndPlatformHtml.trim()) ) {
%>
<b>Revenue of one product code can not be allocated to more than one Product line.  
Group of platforms that generate one product code must have the same Platform Product Family for revenue allocation. 
Otherwise same product code will have different Platform Product Family and will cause OPUS submission error in SPRIT. 
This must be resolved prior to OPUS submission.
</b><br><br>
  <table border="0" cellpadding="1" cellspacing="0">
    <tr><td bgcolor="#3D127B">
       <table border="0" cellpadding="0" cellspacing="0">
          <tr><td bgcolor="#BBD1ED">
             <table border="0" cellpadding="3" cellspacing="1">
                <tr bgcolor="#d9d9d9">
                   <td align="center" valign="top" style="color: #000000;font-family: Arial;font-weight: bold;font-size: 8pt;">
      					PCodeGroup</td>
                   <td align="center" valign="top" style="color: #000000;font-family: Arial;font-weight: bold;font-size: 8pt;">
                        Platforms</td>
                   <td align="center" valign="top" style="color: #000000;font-family: Arial;font-weight: bold;font-size: 8pt;">
                        Platform Product Family</td>
                   <td align="center" valign="top" style="color: #000000;font-family: Arial;font-weight: bold;font-size: 8pt;">
                        No Of days left for OPUS</td>
                 </tr>
                 <%=pCodeGroupAndPlatformHtml%>
              </table>
          </td></tr>
       </table>
    </td></tr>
  </table>
<br>
<%
	}
%>		

</body>
</html>
