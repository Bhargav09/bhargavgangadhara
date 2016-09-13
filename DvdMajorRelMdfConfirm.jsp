<!--.........................................................................
: DESCRIPTION:
:  IOX Cco Post
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2008 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cisco.eit.sprit.beans.IoxCcoInfoBean" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublishiox.IoxPostHelper" %>
<%@ page import="java.util.*" %>

<%@ taglib prefix="c"  uri="http://java.sun.com/jstl/core" %>
<%@taglib uri="spritui" prefix="spritui"%>

<spritui:page title="SPRIT - DVD Major Release Mdf">
  <spritui:header/>
  <c:out value="${requestScope['subheader']}" escapeXml="false"/> <br/><br/><br/><br/>

  <link rel="stylesheet" type="text/css" href="../js/extjs/resources/css/ext-all.css" />
  <script type="text/javascript" src="../js/extjs/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="../js/extjs/ext-all-debug.js"></script>
  <link rel="stylesheet" type="text/css" href="../js/extjs/examples/examples.css" />
  <script type="text/javascript" src="../js/extjs/pPageSize.js"></script>

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
    }
  </style>

<script type="text/javascript">

Ext.onReady(function() {
    Ext.QuickTips.init();

    // shorthand alias
    var fm = Ext.form;

    var getColumnModel = function() {
        var cm = new Ext.grid.ColumnModel([
           {
               header: "Release Train",
               dataIndex: 'train',
               width: 100
           },
           {
               header: "Major Release",
               dataIndex: 'major',
               width: 100
           },
           {
               header: "Release Name",
               dataIndex: 'release',
               width: 100
           },
           {
               header: "Mdf Concept Id",
               dataIndex: 'mdfid',
               width: 100
           },
           {
               header: "Mdf Concept Name",
               dataIndex: 'mdf',
               width: 250
           }
        ]);

        cm.defaultSortable = true;
        return cm;
    }

    // this could be inline, but we want to define the Plant record
    // type so we can add records dynamically
    var TrainRecord = Ext.data.Record.create([
           {name: 'major', type: 'string'},
           {name: 'train', type: 'string'},
           {name: 'mdfid', type: 'string'},
           {name: 'mdf', type: 'string'},
           {name: 'release', type: 'string'}
      ]);

    // create the Data Store
    var store = new Ext.data.GroupingStore({
        // load using HTTP
        proxy: new Ext.data.HttpProxy({ 
             "url": "go?action=dvdmajormdf&output=<c:out value="${requestScope['xmlurl']}"/>&ostype=<c:out value="${requestScope['ostype']}"/>", "method": "POST"
               }),
        baseParams: {
            postdata: '<c:out value="${requestScope['ajaxdata']}" />'
        },       
        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
               record: 'majorrelease'
           }, TrainRecord),
        sortInfo:{field: 'train', direction: "ASC"},
        groupField:'major'
    });

    Ext.Ajax.timeout = 300000;
    
    var grid = new Ext.grid.GridPanel({
        store: store,
        cm: getColumnModel(),
        width:780,
        height:400,
	    loadMask: true,        

        view: new Ext.grid.GroupingView({
            forceFit:true,
            groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
        }),
                
        sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
        clicksToEdit:1
/*        
        bbar: new Ext.PagingToolbar( {
          pageSize: 200,
          store: store,
          displayInfo: true,
          displayMsg: 'Displaying records {0} - {1} of {2}',
          emptyMsg: "No records to display"
        })
         */
    });

  
    var simple = new Ext.FormPanel({
        frame:true,
        title: 'Dvd Major Release Mdf',
        width:800,
        height:500,

        buttons: [{
            text: 'Confirm',
            handler : onSubmit
        },{
            text: 'Cancel',
            handler : function() {
                Ext.Msg.confirm('Cancel Changes?', 'Do you really want cancel all the changes?', 
                        function(btn, text){
                            if (btn == 'yes'){
                                document.location = Ext.get('previousurl').dom.value;
                            }
                        });
                
            }
        }]
    });

    simple.add(grid);
    simple.render('editor-grid');

    var saving = new Ext.LoadMask('editor-grid', {msg: 'Saving changes to db...'});
    
    function onSubmit() {
        saving.show();
        
        var index = 0;
        var buffer = '';
        while( index < grid.store.getCount() ) {
            var record = grid.store.getAt(index);
            buffer = buffer + record.get('major') + '|' +
                record.get('train') + '|' + record.get('release')  + '|' + record.get('mdfid') + '#';
            index++;
        }
        
        
        if( buffer != '' || Ext.get('rulesdata').dom.value != '') {
            var obj = Ext.get('postdata');
            obj.dom.value = buffer;
            Ext.get('dvdform').dom.submit();
        } else {
            saving.hide();
            Ext.MessageBox.alert('', "No data modified to save." );
        }
    }; // end of onSubmit

    // trigger the data store load
    store.load();
});
</script>
<div id="editor-grid"></div>
<form name="dvdform" method="post" action="go?action=dvdmajormdf&output=submit">
    <input type="hidden" id="postdata" name="postdata" value="">
    <input type="hidden" id="rulesdata" name="rulesdata" value="<c:out value="${param.rulesdata}"/>">
    <input type="hidden" id="ostype" name="ostype" value="<c:out value="${param.ostype}"/>">
    <input type="hidden" id="frompage" name="frompage" value="<c:out value="${param.frompage}"/>">
    <input type="hidden" id="previousurl" name="previousurl" value="<%=request.getAttribute("previousurl")%>">
</form>    

    <spritui:footer/>
</spritui:page>