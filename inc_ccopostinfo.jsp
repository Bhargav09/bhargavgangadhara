<!--.........................................................................
: DESCRIPTION:
: Include Messaging Information
:
: AUTHORS:
: @author Rakesh Kamath (rakkamat@cisco.com)
:
: Copyright (c) 2002-2008, 2010, 2012 by Cisco Systems, Inc. All rights reserved.
:.........................................................................-->
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleaseccopost.CsprReleaseCcoPostLocalHome" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleaseccopost.CsprReleaseCcoPostLocal" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleasenote.CsprReleaseNoteLocal" %>
<%@ page import="com.cisco.eit.sprit.model.csprreleasenote.CsprReleaseNoteLocalHome" %>
<%@ page import="com.cisco.eit.shrrda.ostype.ShrOsType" %>
<%@ page import="com.cisco.eit.shrrda.ostype.ShrOsTypeHome" %>
<%@ page import="com.cisco.eit.shrrda.ostypemdfswtype.ShrOSTypeMDFSWTypeLocal" %>
<%@ page import="com.cisco.eit.shrrda.ostypemdfswtype.ShrOSTypeMDFSWTypeLocalHome" %>
<%@ page import="com.cisco.eit.sprit.utils.ejblookup.EJBHomeFactory" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublish.CcoPostHelper" %>

<%
	ShrOsTypeHome osTypeHome = 
		EJBHomeFactory.getFactory().getShrOsTypeLocalHome();
	ShrOsType osTypeBean = osTypeHome.findByPrimaryKey(Integer.valueOf(request.getParameter("osTypeId")));

	ShrOSTypeMDFSWTypeLocalHome osMdfSwTypeHome = 
		EJBHomeFactory.getFactory().getShrOSTypeMDFSWTypeLocalHome();
	Collection osMdfSwType = 
		osMdfSwTypeHome.findByOsTypeId(osTypeBean.getOsTypeId());
	//Fetch the maximum Release Note allowed for this OS Type
	Iterator iterReleaseNotes = osMdfSwType.iterator();
	int maxReleaseNotes = 0;
	while(iterReleaseNotes.hasNext()){
		ShrOSTypeMDFSWTypeLocal osTypeMdfSwBean = (ShrOSTypeMDFSWTypeLocal) iterReleaseNotes.next();
		if(osTypeMdfSwBean.getReleaseNotesMax() != null
			&& osTypeMdfSwBean.getReleaseNotesMax().intValue() > maxReleaseNotes) {
				maxReleaseNotes = osTypeMdfSwBean.getReleaseNotesMax().intValue();
		}
	}
	if (maxReleaseNotes == 0)
		maxReleaseNotes = 3; //set default to 3 
	// 1 additional rows is required for table header
	int countOfReleaseNotes = maxReleaseNotes + 1;
	
%>

<tr bgcolor="#ffffff">
	<td bgcolor="#d9d9d9" width ="30%" align="left" valign="top">&nbsp;</td>
	<td>
	<table id="tblReleaseNote" class="dataTable" width="100%">
		<tr>
			<th width="45%">Release Note Label</th>
			<th width="45%">Release Note URL</th>
			<th width="10%"><input type="button" id="releaseNoteAdd" onClick="objReleaseNotes.addReleaseNote()" value="Add"></input></th>
		</tr>
		<% 	
				CcoPostHelper oCcoPostHelper = new CcoPostHelper();
				CsprReleaseCcoPostLocal releaseCcoPost = 
						oCcoPostHelper.getReleaseCcoPostInfo(Integer.valueOf(request.getParameter("releaseNumberId")));
				CsprReleaseNoteLocalHome releaseNoteHome = 
					EJBHomeFactory.getFactory().getCsprReleaseNoteLocalHome();
				Collection col = Collections.EMPTY_LIST;
				try {
					col = releaseNoteHome.findByReleaseNumberId(Integer.valueOf(request.getParameter("releaseNumberId")));
				} catch (Exception e){
					System.out.println("Release Notes for Release Number="+request.getParameter("releaseNumberId")+" not found");
				}
				
				if(col.size() > 0){
					Iterator iter = col.iterator();
					while(iter.hasNext()) {
						CsprReleaseNoteLocal releaseNote = (CsprReleaseNoteLocal) iter.next();
			%>
						<tr>
							<td><input type="text" id="releaseNoteLabel" name="releaseNoteLabel" value="<%=releaseNote.getLabel()%>" size="30" maxlength="60"></input></td>
							<td><input type="text" id="releaseNoteURL" name="releaseNoteURL" value="<%=releaseNote.getReleaseURL()%>"size="30" maxlength="1000"></input>
								<input type="hidden" id="releaseNoteId" name="releaseNoteId" value="<%=releaseNote.getReleaseNoteId()%>"></input></td>
							<td><a href="javascript:void()" onclick="objReleaseNotes.removeReleaseNote(this)">delete</a></td>
						</tr>	
			<%		}//while
				}else {//if
			%>
						<tr>
							<td><input type="text" id="releaseNoteLabel" name="releaseNoteLabel" value="" size="30" maxlength="60"></input></td>
							<td><input type="text" id="releaseNoteURL" name="releaseNoteURL" value=""size="30" maxlength="1000"></input>
								<input type="hidden" id="releaseNoteId" name="releaseNoteId" value="0"></input></td>
							<td><a href="javascript:void()" onclick="objReleaseNotes.removeReleaseNote(this)">delete</a></td>
						</tr>					
			<%
				}
			%>
		</tr>
	</table>
	</td>	
</tr>	
<tr bgcolor="#ffffff">
<th bgcolor="#d9d9d9" width ="30%" align="left" valign="top"><span class="dataTableTitle">Release Message</span></th>
<td>
	<span class="elementInfo">Note: HTML &lt;b&gt;, &lt;i&gt;, &lt;br&gt; & &lt;a&gt; tags are allowed for formatting. This field can contain maximum 350 characters.</span><br />
	<textarea id="releaseMessage" rows="5" cols="45" name="releaseMessage"><%=releaseCcoPost!=null?releaseCcoPost.getReleaseMessage():""%></textarea>
</td>
</tr>

<script type="text/javascript">
	var objReleaseNotes = {
		addReleaseNote: function() {
			var tblReleaseNote = document.getElementById('tblReleaseNote');
			var lastReleaseLabel = document.getElementsByName('releaseNoteLabel')[0];
			var lastReleaseURL = document.getElementsByName('releaseNoteURL')[0];
			// If maximum URL's have not been entered and label and url field are not empty
			if (tblReleaseNote.rows.length < this.max_rows 
				 && (lastReleaseLabel == null || trim(lastReleaseLabel.value)!= '')
				 && (lastReleaseURL == null || trim(lastReleaseURL.value)!= '')) {
					if(this.arrayFieldIsUnique(document.getElementsByName('releaseNoteLabel'), document.getElementsByName('releaseNoteURL'))) {
						var trRow  = document.getElementById('tblReleaseNote').insertRow(1);
						var txtLabel = '<input type="text" id="releaseNoteLabel" name="releaseNoteLabel" value="" size="30" maxlength="60"></input>';
						var txtURL = '<input type="text" id="releaseNoteURL" name="releaseNoteURL" value="" size="30" maxlength="1000"></input>' +
										' <input type="hidden" id="releaseNoteId" name="releaseNoteId" value="0"></input>';
						var aDel = '<a href="javascript:void()" onclick="objReleaseNotes.removeReleaseNote(this)">delete</a>';
						trRow.insertCell(0).innerHTML = txtLabel;
						trRow.insertCell(1).innerHTML = txtURL;
						trRow.insertCell(2).innerHTML = aDel;
		
						var releaseLabel = document.getElementsByName('releaseNoteLabel')[0];
						if (releaseLabel != null)
							releaseLabel.focus();
						if (tblReleaseNote.rows.length == this.max_rows)
							document.getElementById('releaseNoteAdd').disabled = true;
					}else {
						alert('Duplicate Release Labels and URLs found');
					}
			}
		},
		
		removeReleaseNote: function(objA){
			var buttonAdd = document.getElementById('releaseNoteAdd');
			if (buttonAdd.disabled)
				buttonAdd.disabled = false;
			var trRow = objA.parentNode.parentNode;	
			document.getElementById('tblReleaseNote').deleteRow(trRow.rowIndex);
		},
		
		validateReleaseNotes: function(){
			var errorMessage = '';
			var releaseMessage = document.getElementById('releaseMessage').value;
			var unsupportedHTML = '';
			
			//Validate Release Message textarea
			if(trim(releaseMessage) != '') {
				if(releaseMessage.indexOf('¿')>=0)
					errorMessage = errorMessage + 'Release Message contains invalid character ¿ at '+releaseMessage.indexOf('¿')+ 'th place. \n';
				if(releaseMessage.length > 350)
					 errorMessage = errorMessage + 'Release Message exceeds 350 characters\n';
				if (unsupportedHTML == '') {
					unsupportedHTML = this.checkText(releaseMessage,new Array('b','i','br','a')); 	 
					if(unsupportedHTML != '')
						errorMessage = errorMessage + unsupportedHTML;
				}	 
			}
			
			//Validate Release Note Label
			errorMessage = errorMessage
				+ releaseNoteIsRequired(document.getElementsByName('releaseNoteLabel'),document.getElementsByName('releaseNoteURL'));
			
			if(!this.arrayFieldIsUnique(document.getElementsByName('releaseNoteLabel'),document.getElementsByName('releaseNoteURL'))) {
				errorMessage = errorMessage + 'Duplicate Release Labels and URLs found \n';
			}
			
			//Validate Release URL unique
			if(!this.arrayFieldIsUnique(document.getElementsByName('releaseNoteURL'))){
					errorMessage = errorMessage
					+ ' Release Note URL must be unique\n';
			}
			if(errorMessage == '')
				this.removeEmptyReleaseNotes();
			return errorMessage;
		},
		
		checkText: function(text,allowedTags) {
			var returnMsg = '';
			var invalidTag = false;
			// Pattern to strip HTML Tags from text
			var pattern = /<\/?\s*\w+\s*(\s*\w+\s*=?\s*[\"|\']?(\s*[^ >]*\s*)*[\"|\']?)*\s*\/?>/g;
			var arrHtmlTags = text.match(pattern);
			if(arrHtmlTags != null) {
				for(i=0;i<arrHtmlTags.length;i++){
					var wordPattern = /\w+/g;
					var arrTag = arrHtmlTags[i].match(wordPattern);
					// Loop through allowed HTML tags to check if
					// this HTML tag is valid
					if (allowedTags != null && allowedTags.length > 0) {
						for(j=0;j<allowedTags.length;j++){
							if(arrTag[0].toLowerCase() != allowedTags[j]){
								invalidTag = true;
							}else{
								invalidTag = false;
								break;
							}
						}
					}
					//break out of for loop if an invalid tag is found
					if (invalidTag)
						break;
				} //for
			}
			
			if(invalidTag)
				returnMsg = 'Unsupported HTML Tag found\n';
			return returnMsg;	
		},
		
		arrayFieldIsUnique: function(objArr, objURL) {
			var flag = true;
			if (objArr != null) {
				// Only one release label is present
				if (objArr.length == 1) {
					return flag;
				}
				// More than one release labels are present
				for(i=0;i<objArr.length;i++) {
					var label = trim(objArr[i].value) + trim(objURL[i].value);
					for(j=i+1;j<objArr.length;j++){
						//label is not unique
						if(label == (trim(objArr[j].value) + trim(objURL[j].value))){
							return false;
						}
					}
				}
			}
			return flag;
		
		},
		
		arrayFieldIsUnique: function(objArr) {
						var flag = true;
						if (objArr != null) {
							// Only one release label is present
							if (objArr.length == 1) {
								return flag;
							}
							// More than one release labels are present
							for(i=0;i<objArr.length;i++) {
								var label = objArr[i].value;
								for(j=i+1;j<objArr.length;j++){
									//label is not unique
									if(label == objArr[j].value){
										return false;
								}
							}
						}
					}
					return flag;
					
		},
		
		max_rows: <%= countOfReleaseNotes%>,  // 3 allowed rows + 1 header row 
		
		removeEmptyReleaseNotes: function() {
			var releaseLabel = document.getElementsByName('releaseNoteLabel');
			var releaseURL = document.getElementsByName('releaseNoteURL');
			for(i=0;i<releaseLabel.length;i++) {
				if((releaseLabel[i].value == null || trim(releaseLabel[i].value) == '')
					&&(releaseURL[i].value == null || trim(releaseURL[i].value) == '')) {
					this.removeReleaseNote(releaseLabel[i]);
				}
			}
		}
	}
</script>
