<!--.........................................................................
: DESCRIPTION:
:  IOX Cco Post
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2008, 2013 by Cisco Systems, Inc.
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
  <%=request.getAttribute("subheader")%><br/><br/><br/><br/>

  <link rel="stylesheet" type="text/css" href="../js/extjs/resources/css/ext-all.css" />
  <script type="text/javascript" src="../js/extjs/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="../js/extjs/ext-all-debug.js"></script>
  <link rel="stylesheet" type="text/css" href="../js/extjs/examples/examples.css" />
 <!-- CSCuf35307 : WAS8 Testing<script type="text/javascript" src="../js/extjs/pPageSize.js"></script> -->

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
    var os = "<%=request.getAttribute("ostype")%>";
    
    var storeComb = [
        ['IOS']
    ];
    
    var cbstore = new Ext.data.SimpleStore({
                fields: ['ostype'],
                data : storeComb
                });
    cbstore.on('load',function(ds,records,o) {
	//myCombo.setValue(records[0].data.myDataColumn);
    });

    var myToolbarConfig = [];
    myToolbarConfig.push( //since it's just an array, we can use array functions
      'Os Type: ', //a simple label
      {
        xtype: "combo", //a comboBox
        displayField:'ostype',
        valueField:'ostype',
        mode: 'local',
        id: 'ostypecombo',
        triggerAction: 'all',
        selectOnFocus:true,
        editable : false,
        store: cbstore
      }
    );

    var checkDeleteColumn = new Ext.grid.CheckColumn({
       header: "Select",
       dataIndex: 'delete',
       width: 55
    });

    var getColumnModel = function() {
        var cm = new Ext.grid.ColumnModel([
            checkDeleteColumn,
           {
               header: "Release Train",
               dataIndex: 'train',
               width: 75
            },
           {
               header: "Major Release",
               dataIndex: 'major',
               width: 75
            },
            {
               header: "Mdf Concept Name",
               dataIndex: 'mdf',
               width: 200
            },
            {
               header: "Transaction Status",
               dataIndex: 'transtatus',
               width: 100
            }
        ]);

        // by default columns are sortable
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
           {name: 'transtatus', type: 'string'},
           {name: 'delete', type: 'bool'}
      ]);

    // create the Data Store
    var store = new Ext.data.GroupingStore({
        // load using HTTP
        proxy: new Ext.data.HttpProxy(new Ext.data.Connection(
                    { 
                        url:'go?action=dvdmajormdf&output=dvdmajorrelxml', 
                        timeout:120000
                    })),

        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
               record: 'majorrelease',
               totalRecords: 'totalCount'
           }, TrainRecord),
        sortInfo:{field: 'train', direction: "ASC"},
        groupField:'major'
    });

    var grid = new Ext.grid.GridPanel({
        store: store,
        cm: getColumnModel(),
        width:620,
        height:430,
	    loadMask: true,        
        plugins: [checkDeleteColumn],

        view: new Ext.grid.GroupingView({
            forceFit:true,
            groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
        }),
                
        sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
        clicksToEdit:1,
        tbar: myToolbarConfig,
        bbar: new Ext.PagingToolbar( {
          pageSize: 200,
          store: store,
          displayInfo: true,
          displayMsg: 'Displaying records {0} - {1} of {2}',
          emptyMsg: "No records to display"
        }) 
    });

  
    var simple = new Ext.FormPanel({
        frame:true,
        title: 'Dvd Major Release Mdf',
        width:630,
        height:500,

        buttons: [{
            text: 'Save',
            handler : onSubmit
        },{
            text: 'Cancel',
            handler : function() {
                var changed = false;
                if( grid.store.getModifiedRecords().length > 0 ) {
                    Ext.Msg.confirm('Cancel Changes?', 'Do you really want cancel all the changes?', 
                        function(btn, text){
                            if (btn == 'yes'){
                                grid.store.rejectChanges();
                                grid.store.reload();
                            }
                        });
                } else {
                    Ext.MessageBox.alert('Cancel Changes?', "None of the rules were changed." );
                }
            }
            
        }]
    });

    simple.add(grid);
    simple.render('editor-grid');

    var saving = new Ext.LoadMask('editor-grid', {msg: 'Applying the rules...'});
    
    function onSubmit() {
        
        saving.show();
        
        var modifiedRecords =  grid.store.getModifiedRecords();
        var index = 0;
        var buffer = '';

        while(index < modifiedRecords.length) {
            var record = modifiedRecords[index];
            if( record.get('delete') ) { 
                buffer = buffer + record.get('major') + '|' +
                    record.get('train') + '||' + record.get('mdfid') + '#';
            }
            index++;
        }
        
        if( buffer != '' ) {
            var obj = Ext.get('ostype');
            obj.dom.value = os;
        
            var obj = Ext.get('postdata');
            obj.dom.value = buffer;
            Ext.get('dvdform').dom.submit();
        } else {
            saving.hide();
            Ext.MessageBox.alert('', "No records selected to submit." );
        }
    }; // end of onSubmit

    // trigger the data store load
    store.load({params: {ostype: os, start:0, limit:200} });

    Ext.getCmp('ostypecombo').setValue( '<%=request.getAttribute("subheader")%>' );
    Ext.getCmp('ostypecombo').on('select', function() {
            os = this.getValue();
            store.commitChanges();
            store.load( {params: {ostype: os, start:0, limit:200} });
    });    
});

Ext.grid.CheckColumn = function(config) {
    Ext.apply(this, config);
    if(!this.id){
        this.id = Ext.id();
    }
    this.renderer = this.renderer.createDelegate(this);
};

Ext.grid.CheckColumn.prototype ={
    init : function(grid){
        this.grid = grid;
        this.grid.on('render', function(){
            var view = this.grid.getView();
            view.mainBody.on('mousedown', this.onMouseDown, this);
        }, this);
    },

    onMouseDown : function(e, t) {
        if(t.className && t.className.indexOf('x-grid3-cc-' + this.id) != -1){
            e.stopEvent();

            var index = this.grid.getView().findRowIndex(t);
            var record = this.grid.store.getAt(index);
            if(record.get("mdf") == '')
                Ext.MessageBox.alert('Info!', "It can't be selected as there is no mdfid" );
            else 
                record.set( this.dataIndex, !record.data[this.dataIndex]);
        }
    },

    renderer : function(v, p, record){
        p.css += ' x-grid3-check-col-td';
        return '<div class="x-grid3-check-col'+(v?'-on':'')+' x-grid3-cc-'+this.id+'">&#160;</div>';
    }
};


</script>
<div id="editor-grid"></div>
<form name="dvdform" method="post" action="go?action=dvdmajormdf&output=dvdmajorrelconfpage">
    <input type="hidden" id="postdata" name="postdata" value="">
    <input type="hidden" id="ostype" name="ostype" value="">
    <input type="hidden" id="frompage" name="frompage" value="DvdMajorReleaseMdf">
</form>    
    <spritui:footer/>
</spritui:page>
