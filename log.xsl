<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/">
	    <html>
			 <body>
				<xsl:apply-templates/> 
			 </body>
	    </html>
	</xsl:template>

	<xsl:template match="LogRecord">
    	<xsl:if test="LogLevel = 'FINE' or LogLevel = 'FINER' or LogLevel = 'FINEST' or LogLevel = 'CONFIG'">
    	    <font face="Times New Roman, Times, serif" color="#9999ff">
				 <xsl:apply-templates/>
    	    </font>
    	</xsl:if>    
    	<xsl:if test="LogLevel = 'INFO'">
    	    <font face="Times New Roman, Times, serif" color="#009900">
				 <xsl:apply-templates/>
    	    </font>
    	</xsl:if>    
    	<xsl:if test="LogLevel = 'WARNING'">
    	    <font face="Times New Roman, Times, serif" color="#cc33cc">
				 <xsl:apply-templates/>
    	    </font>
    	</xsl:if>    
    	<xsl:if test="LogLevel = 'SEVERE'">
    	    <font face="Times New Roman, Times, serif" color="#ff0000">
				 <xsl:apply-templates/>
    	    </font>
    	</xsl:if>    
    	<br></br>
	</xsl:template>

	<xsl:template match="Timestamp">
		<xsl:value-of select="."/> 
	</xsl:template>

	<xsl:template match="Thread">
		[<xsl:value-of select="."/>] 
	</xsl:template>

	<xsl:template match="CallerClass">
		<xsl:value-of select="."/>.java( 
	</xsl:template>

	<xsl:template match="CallerMethod">
		<xsl:value-of select="."/>:
	</xsl:template>

	<xsl:template match="LineNumber">
		<xsl:value-of select="."/>) 
	</xsl:template>

	<xsl:template match="LogLevel">
		<xsl:value-of select="."/> - 
	</xsl:template>

	<xsl:template match="Message">
		<xsl:value-of select="."/> 
	</xsl:template>

</xsl:stylesheet>
