<!--.........................................................................
: DESCRIPTION:
: Cco Post Messages page. 
: This will display messages that are passed to this page through a vector object.
:
: AUTHORS:
: @author Ramya Kalepu (rkalepu@cisco.com)
:
:.........................................................................-->
<%@ page import="java.util.Enumeration,
                 java.util.Vector,
                 java.util.StringTokenizer" %>
<center>
<table>
 <BR>
  <table border="0" cellpadding="1" cellspacing="0">
  <tr><td bgcolor="#3D127B">
    <table border="0" cellpadding="0" cellspacing="0">
    <tr><td bgcolor="#BBD1ED">

      <table border="0" cellpadding="3" cellspacing="1">
      
     <tr bgcolor="#d9d9d9"><span class="dataTableData">
    <td align="center" valign="top"><span class="dataTableTitle">
      Message</span></td>
      <td align="center" valign="top"><span class="dataTableTitle">
      Time Posted</span></td>
     </tr>
     
     <%
	//Vector mes = (Vector)request.getParameter("messages");
//	Enumeration e = mes.elements();
String mes = request.getParameter("messages"); 
StringTokenizer st = new StringTokenizer(mes, "$");
while(st.hasMoreElements()){
%>
<tr bgcolor="#ffffff">
<%
StringTokenizer st1 = new StringTokenizer(st.nextToken(), ",");
while(st1.hasMoreElements()){
%>

<td align="center" valign="top"><span class="dataTableData">
          <%= st1.nextToken()%> </span></td>
   
    <% } %>
     </tr>
     <% } %>
     </table>
     </td></tr></table></td></tr></table></table></center>
