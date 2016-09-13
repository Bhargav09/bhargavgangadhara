<!--.........................................................................
: DESCRIPTION:
:  Product Release Notes
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2008-2010, 2012 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cisco.eit.sprit.beans.IoxCcoInfoBean" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublishiox.IoxPostHelper" %>
<%@ page import="java.util.*" %>
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
<%@ page import="com.cisco.eit.sprit.utils.StringUtil" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@ taglib uri="spritui" prefix="spritui"%>

  <link rel="stylesheet" type="text/css" href="../js/extjs/resources/css/ext-all.css" />
  <link rel="stylesheet" type="text/css" href="../js/rowactions/icons.css">
  <link rel="stylesheet" type="text/css" href="../js/rowactions/Ext.ux.grid.RowActions.css">
  <link rel="stylesheet" type="text/css" href="../js/rowactions/rowactions.css">

  <script type="text/javascript" src="../js/extjs/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="../js/extjs/ext-all-debug.js"></script>
  <script type="text/javascript" src="../js/rowactions/Ext.ux.grid.RowActions.js"></script>
  <script type="text/javascript" src="../js/sync.js"></script>
  <link rel="stylesheet" type="text/css" href="../js/extjs/examples/examples.css" />
  <script type="text/javascript" src="../js/extjs/pPageSize.js"></script>
  <script type="text/javascript" src="../js/griddragdrop.js"></script>
  <script type="text/javascript" src="../js/extjs/source/util/Format.js"></script>

<%
    CcoPostHelper oCcoPostHelper = new CcoPostHelper();
    CsprReleaseCcoPostLocal releaseCcoPost = oCcoPostHelper.getReleaseCcoPostInfo(Integer.valueOf("null".equals(request.getParameter("releaseNumberId"))?null:request.getParameter("releaseNumberId")));
    String message = "";
    if(releaseCcoPost != null && releaseCcoPost.getReleaseMessage() != null)
		message = releaseCcoPost.getReleaseMessage();
    message = message.replaceAll("'", "\\\\'");
	message = message.replaceAll("\r\n", "\\\\n" );
    
//    request.setAttribute("relccopost", releaseCcoPost);
    
    ShrOsTypeHome osTypeHome = 
        EJBHomeFactory.getFactory().getShrOsTypeLocalHome();
    ShrOsType osTypeBean = osTypeHome.findByPrimaryKey(Integer.valueOf(request.getParameter("osTypeId")));
    
    
%>
  <style type="text/css">
    #button-grid .x-panel-body {
        border:1px solid #99bbe8;
        border-top:0 none;
    }
    .imageTick {
        background-image:url(../gfx/ico_check.gif) !important;
        background-repeat: no-repeat;
        background-position: center;
    }
    .imageCross {
        background-image:url(../gfx/ico_cross.gif) !important;
        background-repeat: no-repeat;
        background-position: center;
    }
    .add {
        background-image:url(../js/extjs/examples/shared/icons/fam/add.gif) !important;
    }.remove {
        background-image:url(../js/extjs/examples/shared/icons/fam/delete.gif) !important;
    }.refresh {
        background-image:url(../js/extjs/examples/shared/icons/fam/table_refresh.png) !important;
    }.icon-cross {
		background-image:url(../js/extjs/examples/shared/icons/fam/delete.gif) ! important;
    }.icon-plus {
		background-image:url(../js/extjs/examples/shared/icons/fam/add.gif) ! important;
    }


  </style>

<script type="text/javascript">
    var objReleaseNotes = {
        validateReleaseNotes: function(){
            var errorMessage = '';
            var releaseMessage = document.getElementById('releaseMessage').value;
            var unsupportedHTML = '';
            
            //Validate Release Message textarea
            if(trim(releaseMessage) != '') {
			//code to identify  junc char
	       	if(releaseMessage.indexOf('¿')>=0)
			errorMessage = errorMessage + 'Release Message contains invalid character ¿. \n'; 
                if(releaseMessage.length > 350)
                     errorMessage = errorMessage + 'Release Message exceeds 350 characters<br/>';
                if (unsupportedHTML == '') {
                    unsupportedHTML = this.checkText(releaseMessage,new Array('b','i','br','a'));    
                    if(unsupportedHTML != '')
                        errorMessage = errorMessage + unsupportedHTML;
                }
                if( errorMessage == '')
                {    
		   			Ext.Ajax.request({
		                url: 'NonIosAjaxHelper?action=validateReleaseMessage',
		                method: 'POST',
		                params :{releaseMessage: releaseMessage},
		                success: function(response, options) {
		                			if(trim(response.responseText) != '')
		                				errorMessage = trim(response.responseText);
		                         },
		                failure: function(response, options) {
		                            errorMessage = 'Unable to validate release message';
		                         },
		                async: false,                         
		                scope: this
		            	});
            	}
            }

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
                returnMsg = 'Unsupported HTML Tag found.<br>';
            return returnMsg;   
        },
        
        max_rows: 3 //countOfReleaseNotes  // 3 allowed rows + 1 header row 
    }
</script>

<script type="text/javascript">
var relMessageTextAre;
var store;
var storeProducts;
var storeDefault;
var sourceString = '<%=(!"1".equals(request.getParameter( "osTypeId" ))) ? "and Source Location " : ""%>';
var deletedString = '';

    function getErrorObject( err ) {
        return new Object({
            errored: true,
            error: err
        });
    }
    
    function validateLabelAndUrlPresent(record) {
        if( record.get('label').trim() == '' ) {
            if( record.get('product') != '' )
                return 'Release Label for product \'' + record.get('product') + '\' can\'t be empty.<br/>';
            else 
                return 'Release Label can\'t be empty.<br/>';
        }
        
        if( record.get('label').length > 60 ) {
            if( record.get('product') != '' )
                return 'Release Label for product \'' + record.get('product') + '\' has more than 60 characters.<br/>';
            else 
                return 'Release Label has more than 60 characters.<br/>';
        }

        if( record.get('url').trim() == '' && record.get('src').trim() == '' ) {
            if( record.get('product') != '' ) 
                return 'Release URL ' + sourceString + 'for product \'' + record.get('product') + '\' can\'t be empty.<br/>';
            else
                return 'Release URL ' + sourceString + 'can\'t be empty.<br/>';
        }
        
        if( record.get('url').trim() != '' && record.get('src').trim() != '' ) {
            if( record.get('product') != '' ) 
                return 'You can enter either Release URL or Source Location for product \'' + record.get('product') + '\'.<br/>';
            else
                return 'You can enter either Release URL or Source Location';
        }
        
        if( record.get('src').trim() != '') {
        	if(record.get('src').match("htm$") == 'htm')
	            return 'Release Note Source Location can not have .htm file type, please rename to html';
	        var message = '';
            Ext.Ajax.request({
                url: 'go?action=productrelnotes&output=imagecheck&osTypeId=<%=request.getParameter("osTypeId")%>&releaseName=<%=request.getParameter("releaseName")%>&imagename=' + record.get('src'),
                method: 'GET',
                success: function(response, options) {
                    var strResponse = trim(response.responseText);
                    if( strResponse != '' && strResponse != 'exist' ) {
                            message = "Release Notes Source location " + record.get('src') + " doesn't exist.";
                     }
                },
                failure: function(response, options) {
                    message = "Unable to verify whether the source location " + record.get('src') + " exist or not";
                },
                scope: this,
                async: false
            });
            
            if( message != '' )
            	return message;
	        
        }

        return ''
    }
    
    function validateRecord(record) {
        var buffer = '';
        
        if( record.get( 'id' ) == 'zzzNew' ) {
//            if( record.get('label') != '' || record.get('url') != '' || record.get('src') != '' ) {
                var tmp = validateLabelAndUrlPresent(record);
                if( tmp == '' )
                    buffer += 'N|' + getRecord(record);
                else 
                    return getErrorObject(tmp);
 //           }
        } else {
//            if( record.get('label') == '' && record.get('url') == '' && record.get('src') == '' ) {
//                buffer += 'D|' + getRecord(record);
//            } else {
                var tmp = validateLabelAndUrlPresent(record);
                if( tmp == '' ) {
                    if( record.dirty )
                        buffer += 'M|' + getRecord(record);
                    else 
                        buffer += 'U|' + getRecord(record);
                } else 
                    return getErrorObject(tmp);
 //           }
        }
        
        return Object({
                errored: false,
                result: buffer
            });
    }
    
    function startsWith(src, cmp) {
	if( src != null && src.charAt(0) == cmp )
		return true;
	else
		return false;
    }

    function getResultString() {
        var buffer = '';
        var errorBuffer = ''
        var needReleaseNotes = <%= ("Y".equals(request.getParameter( "releaseNotesRequired" ))) ? "true" : "false" %>
        var releaseNotesFound = false; 

        errorBuffer = objReleaseNotes.validateReleaseNotes();
        
        for(var i = 0; i < store.getCount(); i++) {
            var errorObject = validateRecord(store.getAt(i));

            if( errorObject.errored ) 
                errorBuffer += errorObject.error; 
            else {
                buffer += errorObject.result;
                if( !releaseNotesFound && !startsWith(errorObject.result, 'D') )
                    releaseNotesFound = true;
            }         
        }
        
        for(var i = 0; i < storeDefault.getCount(); i++) {
            var errorObject = validateRecord(storeDefault.getAt(i));

            if( errorObject.errored ) 
                errorBuffer += errorObject.error; 
            else {
                buffer += errorObject.result;
                if( !releaseNotesFound && !startsWith(errorObject.result, 'D'))
                    releaseNotesFound = true;
            }         
        }
                
        if( errorBuffer != '' ) 
            return 'Error!' + errorBuffer;

        if (needReleaseNotes && !releaseNotesFound)
            return 'Error!' + 'Atleast one release notes should be entered.';
        
        errorBuffer = findDuplicates();
        if( errorBuffer != '' ) 
            return 'Error!' + errorBuffer;
             
        return buffer + deletedString;
    }

    function findDuplicates() {
        for(var i = 0; i < store.getCount(); i++) {
            var srcRecord = store.getAt(i);
                for(var j = i + 1; j < store.getCount(); j++) {
                    var record = store.getAt(j);
                    if( srcRecord.get('url') != '' && record.get('url') != '' && 
                            srcRecord.get('mdfid') == record.get('mdfid') && srcRecord.get('url') == record.get('url')) {
                        return 'Release Notes for Product \'' + record.get('product') + '\' has duplicate URL\'s.<br/>';
                    } 

                    if( srcRecord.get('label') != '' && record.get('label') != '' && 
                            srcRecord.get('mdfid') == record.get('mdfid') && srcRecord.get('label') == record.get('label')) {
                        return 'Release Notes Label for Product \'' + record.get('product') + '\' has duplicate label names.<br/>';
                    } 
                }
        }
        
        for(var i = 0; i < storeDefault.getCount(); i++) {
            var srcRecord = storeDefault.getAt(i);
                for(var j = i + 1; j < storeDefault.getCount(); j++) {
                    var record = storeDefault.getAt(j);
                    if( srcRecord.get('url') != '' && record.get('url') != ''
                            && srcRecord.get('url') == record.get('url')) {
                        return 'Release Notes should be unique.<br/>';
                    } 

                    if( srcRecord.get('label') != '' && record.get('label') != '' && 
                            srcRecord.get('label') == record.get('label')) {
                        return 'Release Notes Label should be unique.<br/>';
                    } 
                }
        }
        return '';
    }
    
	//CSCsr29014 - Validate URL - Validates Product and Release Notes URL
	// and returns the invalid URL error message
    function isReleaseURLValid() {
    	var invalidProductURL = '';
    	var loginProductURL = '';
    	var invalidReleaseURL = '';
    	var loginReleaseURL = '';
    	var invalidURL = '';
    	var imageId;
    	var accessLevelFlag = false;
    	
    	var x=document.getElementsByName("imageid");
		if(x!=null) {
			for (var count=0; count<x.length; count++) {
				if(x[count].checked) {
					imageId =  x[count].value.substring(0,x[count].value.indexOf(":"));
					var accessVar = 'accessLevel_'+imageId;		
					var accessLvl = document.getElementsByName(accessVar)[0].value;
					if (accessLvl == 'Guest Registered' || accessLvl == 'Anonymous') {					
						accessLevelFlag = true;
					}
				}
			}
		}
    	
    	
    	cursor_wait();
 
	    //Validate Product Notes URL
        for(var i = 0; i < store.getCount(); i++) {
            var srcRecord = store.getAt(i);
            var releaseurl = srcRecord.get('url');
			if( releaseurl != ''){
				var code = isURLValid(releaseurl);
				if ( code == 401 && accessLevelFlag) {
					loginProductURL += releaseurl + '<br>';
				} else {
					if (code == -1) {
	   					invalidProductURL = invalidProductURL + Ext.util.Format.htmlEncode(releaseurl) + ' <br>';
	   				}
	   			}
            }
        }

		//Validate Release Notes URL
        for(var i = 0; i < storeDefault.getCount(); i++) {
            var srcRecord = storeDefault.getAt(i);
            var releaseurl = srcRecord.get('url');
			if( releaseurl != ''){
				var code = isURLValid(releaseurl);
				if (code == 401 && accessLevelFlag) {
					loginReleaseURL += releaseurl + '<br>';
				} else {
					if (code == -1) {
	   					invalidReleaseURL = invalidReleaseURL + Ext.util.Format.htmlEncode(releaseurl)+' <br>';
	   				}
	   			}
            }
        }
                
        if(loginProductURL != '') {
			invalidURL += 'One or more images may be Guest Registered or Anonymous. All the url(s) must be public.<br>Following Product Release Notes URLs needs log in. Please enter the public URLs.<br>' + 
							loginProductURL + '<br>';        
        }
        if(invalidProductURL!=''){
        	invalidURL +=  'Following Product Release Notes URLs are invalid <br>' + invalidProductURL + '<br>';
        }        
        if(loginReleaseURL != '') {
        	invalidURL += 'One or more images may be Guest Registered or Anonymous. All the url(s) must be public.<br>Following Release Notes URLs needs log in. Please enter the public URLs.<br>' +
        					loginReleaseURL + '<br>';
        }
        if(invalidReleaseURL!=''){
        	invalidURL = invalidURL + ' Following Release Notes URLs are invalid <br>' + invalidReleaseURL+ '<br>';
        }
        cursor_clear();
        
        if(invalidURL!=''){
        	return invalidURL;
        }
        return '';
    }
    
    //CSCsr29014 - Validate input URL - AJAX call to NonIosAjaxHelper to validate input URL
    function isURLValid(releaseurl){
	    var message = -1;
    	if( releaseurl != ''){
	   			Ext.Ajax.request({
                url: 'NonIosAjaxHelper?url=' + releaseurl + '&action=validateURL',
                method: 'GET',
                success: function(response, options) {
                			message = trim(response.responseText);
                         },
                failure: function(response, options) {
                            message = -1;
                         },
                async: false,                         
                scope: this
            	});
         }
         return message;
    }
    
    //CSCsr29014
    function cursor_wait() {
  		document.body.style.cursor = 'wait';
	}

	//CSCsr29014
	function cursor_clear() {
  		document.body.style.cursor = 'default';
	}
    
    function getRecord(record) {
        var buffer = '';
        buffer += record.get('src') + '|';
        buffer += record.get('mdfid') + '|'; 
        buffer += record.get('product') + '|'; 
        buffer += record.get('label') + '|';
        buffer += record.get('url') + '|';
        buffer += record.get('id') + '#';
        
        return buffer;
    };

Ext.onReady(function() {
    Ext.QuickTips.init();
    deletedString = '';
    var fm = Ext.form;
    var deletedReleaseNotes = new Array();
    var delIndex = 0;
    var readOnly = '<%=request.getParameter( "readOnly")%>';
    
<% if( "Y".equals( request.getParameter( "releaseMessageRequired" )))  { %>     
    relMessageTextAre = new Ext.form.TextArea({
                id: 'releaseMessage',
                renderTo: 'release_message',
<% if( "1".equals(request.getParameter( "osTypeId" )))  {%>
                width:520,
<% } else { %>        
                width:720,
<% } %>        
                height: 75,
                <% if( "Y".equals(request.getParameter( "readOnly"))) { %>
                disabled: true,
                <% } %>
                value: '<%=message%>'
            });

<% } %>    
                
    var releaseNotesRecord = Ext.data.Record.create([
           {name: 'id', type: 'string'},
           {name: 'mdfid', type: 'string'},
           {name: 'product', type: 'string'},
           {name: 'label', type: 'string'},
           {name: 'url', type: 'string'},
           {name: 'src', type: 'string'}
      ]);

    var productRecord = Ext.data.Record.create([
           {name: 'mdfid', type: 'string'},
           {name: 'productname', type: 'string'}
      ]);

    Ext.override(Ext.grid.ColumnModel, {
        isCellEditable : function(colIndex, rowIndex) {
            if( readOnly == 'Y' ) 
                return false;
                
            //original
            return (this.config[colIndex].editable ||
                (typeof this.config[colIndex].editable == "undefined"
                        && this.config[colIndex].editor)) ? true : false;
        }
    });

    var myToolbarConfig = [];
    
    
    // asuman has added this comment
<% if( !"Y".equals(request.getParameter( "readOnly")) ) { %>    
    myToolbarConfig.push( //since it's just an array, we can use array functions
      '->',
      {
            xtype: "button", //a comboBox
            text: 'Add',
            tooltip: 'Click to add a new product level release notes',
            iconCls:'add',
            handler : function(){
                popupWindow.showDialog( null );
            }
      });
<% } %>

    var defaultToolbarConfig = [];
<% if( !"Y".equals(request.getParameter( "readOnly")) ) { %>    
    defaultToolbarConfig.push( //since it's just an array, we can use array functions
      '->',
      {
            xtype: "button", //a comboBox
            text: 'Add',
            tooltip: 'Click to add a new release notes',
            iconCls:'add',
            handler : function(){
                if(storeDefault.getCount() >= 3) {
                    Ext.MessageBox.alert('Error!!!', 'You can\'t add more than three release notes.');
                } else {
	                storeDefault.insert( storeDefault.getCount(), new  releaseNotesRecord({
	                                id: 'zzzNew', 
	                                mdfid: '',
	                                product: '',
	                                label :'Release Notes for '+'<%=request.getParameter("releaseName")%>',
	                                url : '',
	                                src : ''
	                                }));
                }
            }
      });
<% } %>

	// asuman has added this comment
    storeProducts = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy(new Ext.data.Connection(
                    { 
                        url:'go?action=productrelnotes&output=products&osTypeId=<%=request.getParameter("osTypeId")%>&releaseName=<%=request.getParameter("releaseName")%>', 
                        timeout:120000
                    })),
        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
               record: 'product'
           }, productRecord),
        sortInfo:{field: 'productname', direction: "ASC"}
    });

    
    // asuman has added this comment
    store = new Ext.data.GroupingStore({
        proxy: new Ext.data.HttpProxy(new Ext.data.Connection(
                    { 
                        url:'go?action=productrelnotes&output=prodrelnotesxml&osTypeId=<%=request.getParameter("osTypeId")%>&releaseName=<%=request.getParameter("releaseName")%>', 
                        timeout:120000
                    })),
        reader: new Ext.data.XmlReader({
               record: 'releasenote'
           }, releaseNotesRecord),
        sortInfo:{field: 'id', direction: "ASC"},
        groupField:'product'
    });

    
    storeDefault = new Ext.data.Store({
        proxy: new Ext.data.HttpProxy(new Ext.data.Connection(
                    { 
                        url:'go?action=productrelnotes&output=defaultrelnotesxml&osTypeId=<%=request.getParameter("osTypeId")%>&releaseName=<%=request.getParameter("releaseName")%>', 
                        timeout:120000
                    })),
        reader: new Ext.data.XmlReader({
               record: 'releasenote'
           }, releaseNotesRecord),
        sortInfo:{field: 'id', direction: "ASC"}
    });

// begin
        var action = new Ext.ux.grid.RowActions({
             header:'',
             autoWidth: false,
             width: 30
            ,actions:[{
                iconCls:'icon-cross'
                ,tooltip:'Remove'
            }]
            ,groupActions:[{
                 iconCls:'icon-cross'
                ,qtip:'Remove Release Notes'
            },{
                 iconCls:'icon-plus'
                ,qtip:'Add Release Notes'
            }]
           
            ,callbacks:{
            }
            
        });

        action.on({
            action:function(grid, record, action, row, col) {
                if( readOnly != 'Y' ) {
                    if( record.get('id') != 'zzzNew' ) {
                        deletedString += 'D|' + getRecord(record);
                    }                      
                    store.remove(record);
                } 
            }
            ,beforeaction:function() {
            }
            ,beforegroupaction:function() {
            }
            ,groupaction:function(grid, records, action, groupId) {
                if( action == 'icon-plus' ) {
	                if( records.length >= 3 ) {
	                    Ext.MessageBox.alert('Error!!!', 'You can\'t add more than three release notes.');
	                } else {
	                    var record = records[records.length-1];
	                    var index = store.indexOf(record);
	                    store.insert( index + 1, new  releaseNotesRecord({
	                                    id: 'zzzNew', 
	                                    mdfid: record.get('mdfid'),
	                                    product: record.get('product'),
	                                    label : 'Release Notes for ' + '<%=request.getParameter("releaseName")%>',
	                                    url : '',
	                                    src : ''
	                                    }));
	                }
	            } if( action == 'icon-cross' ) {
                   for(var i = 0; i < records.length; i++) {
                      if( records[i].get('id') != 'zzzNew' ) {
                          deletedString += 'D|' + getRecord(records[i]);
                      }                      
                      store.remove(records[i]);
                   }
	            }
            }
        });
        
        var defaultAction = new Ext.ux.grid.RowActions({
             header:'',
             autoWidth: false,
             width: 30
            ,actions:[{
                iconCls:'icon-cross'
                ,tooltip:'Remove'
            }]
            ,callbacks:{
            }
            
        });

        defaultAction.on({
            action:function(grid, record, action, row, col) {
                if( readOnly != 'Y' ) {
                    if( record.get('id') != 'zzzNew' ) {
                        deletedString += 'D|' + getRecord(record);
                    }                      
                    storeDefault.remove(record);
                } 
            }
            ,beforeaction:function() {
            }
            ,beforegroupaction:function() {
            }
            ,groupaction:function(grid, records, action, groupId) {
            }
        });
        
// end

    var getColumnModel = function(act) {
        var cm = new Ext.grid.ColumnModel([
           {
               header: "Product Name",
               dataIndex: 'product',
               width: 150,
               hidden: true
            },
           {
               header: "Release Label",
               dataIndex: 'label',
               width: 150,
               editor: new fm.TextField({
                  allowBlank: true
               })
            },
           {
               header: "Release Notes URL",
               dataIndex: 'url',
               width: 250,
               editor: new fm.TextField({
                  allowBlank: true
               }),
               renderer:txtFieldValEncode    
            }
<% if( !"1".equals(request.getParameter( "osTypeId" )))  {%>            
            ,
           { 
               header: "Source Location",
               dataIndex: 'src',
               width: 250,
               editor: new fm.TextField({
                  allowBlank: true
               })
            }
<% } %>            
           , act
        ]);

        cm.defaultSortable = true;

        return cm;
    }

    var gridView = new Ext.grid.EditorGridPanel({
        store: storeDefault,
        renderTo: 'view-div',
        cm: getColumnModel(defaultAction),
        clicksToEdit:2,
        plugins:[defaultAction],
        tbar: defaultToolbarConfig,
<% if( "1".equals(request.getParameter( "osTypeId" )))  {%>
        width:520,
<% } else { %>        
        width:720,
<% } %>        
        height:130
    });


    var grid = new Ext.grid.EditorGridPanel({
        store: store,
        cm: getColumnModel(action),
<% if( "1".equals(request.getParameter( "osTypeId" )))  {%>
        width:520,
<% } else { %>        
        width:720,
<% } %>        
        height:230,
        loadMask: true,        
        renderTo: 'editor-grid',

        view: new Ext.grid.GroupingView({
            forceFit:true
        }),
        el: 'content_div',
                         
        sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
        clicksToEdit:2,
        plugins:[action],
        tbar: myToolbarConfig
    });

    popupWindow = function() {
        var win;

        // return a public interface
        return {
          init  : function() {
            if(!win){ // lazy initialize the window and only create it once
              win = getRuleWindow();
              win.on('minimize', function(){
                    win.toggleCollapse(false);
              });
            }
          }, //init()

          showDialog  : function( record) {
            win.show();
          }
        };
    }();

    popupWindow.init();
	
	function txtFieldValEncode(val) {
		if (val != '') { 
			return Ext.util.Format.htmlEncode(val);
		}
		return val;	
	}

    function getRuleWindow() {

        var RuleWindow = function() {
        this.form = new Ext.form.FormPanel({
                baseCls: 'x-plain',
                name: 'innFormPanel',

                items: [
                {
                    xtype: "combo", 
                    displayField:'productname',
                    valueField:'productname',
                    width : 300,
                    mode: 'local',
                    fieldLabel: 'Select Product',
                    id: 'prodcombo',
                    forceSelection:true,
                    triggerAction: 'all',
                    anchor:'100%',
                    editable : false,
                    store: storeProducts
                }
                ]
                });

        RuleWindow.superclass.constructor.call(this,  {
                title: 'Product Mdf',
                id: 'platform-win',
                width: 430,
                height: 110,
                plain:true,
                modal: true,
                autoScroll: true,
                closeAction: 'hide',

                buttons:[
                    {
                        text: 'Update',
                        handler: this.onUpdate,
                        scope: this
                    },{
                        text: 'Cancel',
                        handler: this.hide.createDelegate(this, [])
                    }],

                items: this.form
              });

            this.addEvents({add:true});
        }; // end of RuleWindow fn()

        Ext.extend( RuleWindow, Ext.Window, {
            show : function(){
                RuleWindow.superclass.show.apply(this, arguments);
            },

            onUpdate: function() {
                
                var mdfid;
                var mdfname = this.items.first().items.item('prodcombo').getValue();
                if(mdfname == '') {
                    Ext.MessageBox.alert('Error!!!', 'Please select a product');
                    return;
                }

                var count = storeProducts.getCount(); 
                
                for(var i=0; i< store.getCount(); i++ ) {
                    var releaseNote = store.getAt(i);
                    if(mdfname == releaseNote.get( 'product' ) ) {
                        Ext.MessageBox.alert('Error!!!', 'The product you have selected has been added before');
                        return;
                    }
                }
                
                for( var i=0;i<count;i++) {
                    var releaseNote = storeProducts.getAt(i);
                    if(mdfname == releaseNote.get( 'productname' ) ) {
                        mdfid = releaseNote.get( 'mdfid' );
                        break;
                    }
                }
                
                var noOfRecords = store.getCount();
                for(var i=0;i<3;i++) {
                    var releaseNote = storeDefault.getAt(i);
                    
                    if( releaseNote != null )
                        grid.store.insert( noOfRecords + i, new  releaseNotesRecord({
                                    id: 'zzzNew', 
                                    mdfid: mdfid,
                                    product: mdfname,
                                    label : releaseNote.get('label'),
                                    url : releaseNote.get('url'),
                                    src : releaseNote.get('src')
                                    }));
                }
                
                if( storeDefault.getCount() == 0)
                     grid.store.insert( noOfRecords , new  releaseNotesRecord({
                                    id: 'zzzNew', 
                                    mdfid: mdfid,
                                    product: mdfname,
                                    label : 'Release Notes for ' + '<%=request.getParameter("releaseName")%>',
                                    url : '',
                                    src : ''
                                    }));  
                    
                
                                
                this.hide();
            },

            getAllocation : function(record) {
                //
            }
            });

            return new RuleWindow();
        }

    function dataChanged(o) {
        
    }

    function onSubmit() {
    	  
        buffer = getResultString('submit');
//        alert( buffer );
        
        if( buffer == 'ValidationError' )
            return;
            
        if( buffer != '' ) {
            var message;
            Ext.Ajax.request({
                url: 'go?action=productrelnotes&output=submit&osTypeId=<%=request.getParameter("osTypeId")%>&releaseName=<%=request.getParameter("releaseName")%>',
                method: 'POST',
                params: {
                    postData: buffer
                },
                success: function(response, options) {
                              message = 'Successfully saved';
                         },
                failure: function(response, options) {
                            message = 'Error occured while saving. Please try again.';
                         },
                scope: this,
                async: false
            });
            saving.hide();
            Ext.MessageBox.alert('', message);

            store.rejectChanges();
            store.reload();
            
        } else {        
            saving.hide();
            Ext.MessageBox.alert('', 'There is no data to save');
        }
    }; 

    // trigger the data store load
    store.load();
    storeDefault.load();
    storeProducts.load();
});

</script>

