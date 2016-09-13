<%-- 
.........................................................................
: DESCRIPTION:
:     Hidden Post Expiration Notification format
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2007, 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................
--%>
<%@ page import="java.io.*, com.cisco.eit.sprit.util.*" %>
<%@ page import="com.cisco.eit.sprit.gui.Footer" %>

<html>
<body>
<br><%=request.getParameter("ReleaseNumber")%> posted to CCO  with default MDF concept Id.<br>

<br><br>
-------------------------------------------------------------------------<br>

	<!-- start footer -->
    <%= Footer.pageFooter(true) %>
    <!-- end of footer -->
<br>

</body>
</html>
