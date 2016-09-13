<%-- 
.........................................................................
: DESCRIPTION:
:     cron job checks if the release note urls are valid or not
:	  use this jsp file to run the cron in dev env
:
: AUTHORS:
: @author Sudha Pathalapati (spathala@cisco.com)
:
: Copyright (c) 2010 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................
--%>



<%@ page import = "java.lang.Exception" %>
<%@ page import = "java.util.Date" %>
<%@ page import = "com.cisco.eit.sprit.logic.invalidReleaseNoteURLNotify.InvalidReleaseNoteURLNotifyCronJob" %>
welcome to jsp to run cron job........
<%Date s1 = new Date();
	%>
<%=s1 %>
Executing Sprit Utility --->
Starting cron job.......
	<% 
		InvalidReleaseNoteURLNotifyCronJob jb = new InvalidReleaseNoteURLNotifyCronJob();
                jb.execute();
		Date s = new Date();
	%>
	Ending cron job.........
	<br/>
	<%=s %>
	