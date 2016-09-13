<%--
/**
 * Log Viewer.
 *
 * Date: Dec 18, 2006
 * 
 * @author Raju (sraju@cisco.com)
 * ...........................................................................
 * Copyright (c) 2006-2007 by Cisco Systems, Inc.
 */   --%>

<%@ page import="java.util.*" %>
<%@ page import="com.cisco.eit.db.*"%>
<%@ page import="java.util.logging.*"%>
<%@ page import="com.cisco.eit.logging.*"%>
<%@ page import="com.cisco.eit.beans.*"%>
<%@ page import="com.cisco.eit.xml.*"%>

<%@ page import="java.io.BufferedReader" %>
<%
	String strLogName = request.getParameter( "logname" );
	String strLogNumber = request.getParameter( "lognumber" );
	String strXslUrl = request.getParameter( "xsl" );
	
	String strErrorMessage = null;

	int lognumber = 0;
	if(strLogName == null || "".equalsIgnoreCase(strLogName.trim())) {
		strErrorMessage = "logname parameter is missing in request";
	}
	
	try {
		if(strLogNumber != null && !"".equalsIgnoreCase(strLogNumber.trim())) {
			lognumber = Integer.valueOf(strLogNumber).intValue();
		}
	} catch(NumberFormatException e) {
		strErrorMessage = "Invalid lognumber -" + strLogNumber;
	}

	BufferedReader br = null;

	EitLogEnvInfo info = AppEnv.getInstance().getEitLogEnvInfo();
	Collection coll = info.getAllFileHandlers(strLogName);
	if( coll.size() == 0 ) {
		strErrorMessage = "Invalid logname - " + strLogName;
	} else {
		String strFileName = null;
		try {
			strFileName = (String) coll.iterator().next() + "." + lognumber;
			br = new BufferedReader(
					new InputStreamReader(
						new FileInputStream(strFileName)));
		} catch(IOException ex) {
			ex.printStackTrace();
			strErrorMessage = "Unable to access the file - " + strFileName;
		}
	}
	
	if( strErrorMessage != null) {
	    response.setContentType("text/plain");
	    out.println( strErrorMessage );
	} else {
		response.setContentType("text/xml");
		String strPrevLine = br.readLine();
		String strNewLine = null;
		
		boolean bXslReplaceRequired = false;
		if(strXslUrl != null && !"".equalsIgnoreCase(strXslUrl.trim())) {
			bXslReplaceRequired = true;
		}
		
		while( (strNewLine = br.readLine()) != null ) {
			if(bXslReplaceRequired && strNewLine.startsWith("<?xml-stylesheet")) {
				bXslReplaceRequired = false;
				out.println("<?xml-stylesheet type=\"text/xsl\" href=\"" + strXslUrl + "\" ?>");
			} else {
				out.println(strNewLine);
			}
			strPrevLine = strNewLine;
		}
		
		if( !strPrevLine.startsWith("</Log>")) {
			out.println("</Log>");
		}
	}
%>


