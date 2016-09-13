<!--.........................................................................
: DESCRIPTION:
:  Dvd Major Release Rules
:
: AUTHORS:
: @author Raju (sraju@cisco.com)
:
: Copyright (c) 2008, 2011, 2013 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cisco.eit.sprit.beans.IoxCcoInfoBean" %>
<%@ page import="com.cisco.eit.sprit.logic.ypublishiox.IoxPostHelper" %>
<%@ page import="java.util.*" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@taglib uri="spritui" prefix="spritui"%>

<spritui:page title="SPRIT - DVD Major Release Mdf">
  <spritui:header/>
  <c:out value="${requestScope['subheader']}" escapeXml="false"/> <br/><br/><br/><br/>

  <link rel="stylesheet" type="text/css" href="../js/extjs/resources/css/ext-all.css" />
  <script type="text/javascript" src="../js/extjs/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="../js/extjs/ext-all-debug.js"></script>
  <script type="text/javascript" src="../js/sync.js"></script>
  <link rel="stylesheet" type="text/css" href="../js/extjs/examples/examples.css" />
  <!-- CSCuf35307 : WAS8 Testing<script type="text/javascript" src="../js/extjs/pPageSize.js"></script> -->
  <script type="text/javascript" src="../js/griddragdrop.js"></script>

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

    var iosReleaseComponentNames = [
        ['Major Release'],
        ['Train']
    ];

//    var noniosReleaseComponentNames = [
//        ['Software Type']
//    ];

    //contains all 
    var releaseComponentNames = new Array(2);

 
    function getReleaseComponents(os) {
        var nonioscomponent = '';
        var nonioscomponentlist = new Array(2);
        var nonioscomponentarray;
        //debugger;
        if( os == null || os == 'IOS' ){
            releaseComponentNames = iosReleaseComponentNames;
            //return iosReleaseComponentNames;
        }
        else{
             
             Ext.Ajax.request({
                url: 'go?action=dvdmajormdf&output=dvdmajorrelrulenoniosreleasecomp&ostypename=' + os,
                method: 'GET',
                success: function(response, options) {
                   nonioscomponent = response.responseText
                },
                failure: function(response, options) {
                    nonioscomponent = 'Error'
                },
                scope: this,
                async: false
             });
             
             nonioscomponentarray = nonioscomponent.split(",");
       
	         for(i = 0; i < nonioscomponentarray.length; i++){
	              releaseComponentNames[i] = new Array(1);
		          releaseComponentNames[i][0] = nonioscomponentarray[i];
	         }
        } 
       
        
        return releaseComponentNames;               
    }

Ext.onReady(function() {
    Ext.QuickTips.init();

    var modifiedMajorReleases = new Array();
    var modifiedRecordsIndex = 0;
    var os = "<%=request.getAttribute("ostype")%>";
    
    // shorthand alias
    var fm = Ext.form;

    var osTypes = [
<% 
    List list = (List) request.getAttribute("listostypes");
    for(int i=0;i<list.size();i++) {
%>    
        ['<%=list.get(i)%>']
<%      if( i != ( list.size() - 1)) { %>                       
          ,
<%      }
    }                        
%>                        
    ];
    
    var storeOsTypes = new Ext.data.SimpleStore({
                fields: ['ostype'],
                data : osTypes
                });

    var storeComponentNames = new Ext.data.SimpleStore({
                fields: ['releasecomponentname'],
                data : getReleaseComponents('<c:out value="${requestScope['ostype']}"/>')
                });

    var operators = [
        ['Equal'],
        ['Like']
    ];

    var storeOperators = new Ext.data.SimpleStore({
                fields: ['operator'],
                data : operators
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
        store: storeOsTypes
      }, '-',
      {
            xtype: "button", //a comboBox
            text: 'Add New Rule',
            tooltip: 'Click to Add a new Rule',
            iconCls:'add',
            handler : function(){
            	popupWindow.showDialog( null );
            }
      },
      {
            xtype: "button", //a comboBox
            text: 'Delete Rule',
            tooltip: 'Delete selected rules',
            iconCls:'remove',
            handler : function(){
                var store = grid.getStore();
                var records = grid.selModel.getSelections(); 
            
                var obj = Ext.get('deleteddata');
                var buffer = obj.dom.value;
                 
                for(var i = 0; i < records.length; i++){
                    buffer = buffer +  'D|' + getRecordDataAsString(records[i]);
                    
                    var major = records[i].get('major');
                    var sequence = records[i].get('seq');
                    var index = store.indexOf(records[i]);
                    
                    if(index != -1 ) {
                        for(var j=index + 1; j<store.getCount();j++) {
                            if( major == store.getAt(j).get('major') ) {
                                store.getAt(j).set( 'seq', sequence );
                                sequence++;
                            } else {
                                break;
                            }
                        }
                    }
                    
                    var found = false;
                    for(var k=0;k<modifiedRecordsIndex;k++) {
                        if(modifiedMajorReleases[k] == major) {
                            found = true;
                            break;
                        }
                    }
                    
                    if( !found )  {
                        modifiedMajorReleases[modifiedRecordsIndex++] = major;
                     }
                        
                    store.remove(records[i]);
                }//end for
                obj.dom.value = buffer;
            }
      }
    );

    function getRecordAsString(record) {
        return 
            record.get('id') + '|' + 
            record.get('major') + '|' + 
            record.get('compname') + '|' +
            record.get('operator') + '|' +
            record.get('compvalue') + '|' +
            record.get('mdf') + '|' +
            record.get('seq') + '#';
    }

    var getColumnModel = function() {
        var cm = new Ext.grid.ColumnModel([
           {
               header: "Major Release",
               dataIndex: 'major',
               width: 150
            },
           {
               header: "Sequence",
               dataIndex: 'seq',
               width: 150
            },
           { 
               header: "Component Name",
               dataIndex: 'compname',
               width: 125,
               editor: new Ext.form.ComboBox({
                   typeAhead: true,
                   triggerAction: 'all',
                   displayField:'releasecomponentname',
                   mode: 'local',
                   store: storeComponentNames,
//                   transform:'componentname',
                   editable : false,
                   lazyRender:true,
                   listClass: 'x-combo-list-small'
                })
            },
           {
               header: "Operator",
               dataIndex: 'operator',
               width: 125,
               editor: new Ext.form.ComboBox({
                   typeAhead: true,
                   triggerAction: 'all',
                   transform:'ruleoperator',
                   lazyRender:true,
                   listClass: 'x-combo-list-small'
                })
            },
            {
               header: "Component Value",
               dataIndex: 'compvalue',
               width: 100,
               editor: new fm.TextField({
                    allowBlank: false
               })
            },
           {
               header: "Mdf Id",
               dataIndex: 'mdf',
               width: 100,
               editor: new fm.TextField({
                  allowBlank: false
               })
            },
           {
               header: "Mdf Name",
               dataIndex: 'mdfname',
               width: 350
            }
        ]);

        // by default columns are sortable
        cm.defaultSortable = true;

        return cm;
    }

    // this could be inline, but we want to define the Plant record
    // type so we can add records dynamically
    var TrainRecord = Ext.data.Record.create([
           {name: 'id', type: 'string'},
           {name: 'major', type: 'string'},
           {name: 'compname', type: 'string'},
           {name: 'operator', type: 'string'},
           {name: 'compvalue', type: 'string'},
           {name: 'mdf', type: 'string'},
           {name: 'mdfname', type: 'string'},
           {name: 'seq', type: 'int'}
      ]);


    Ext.override(Ext.grid.ColumnModel, {
        isCellEditable : function(colIndex, rowIndex) {

            var record = grid.getStore().getAt(rowIndex);
            if( record.get("major") == '' ) {
                if( colIndex == 0 || colIndex == 2 || colIndex == 3 || colIndex == 4) {
                    return false;
                }
            }// else if( os != 'IOS' && colIndex == 2 ) {
            //    return false;
           // }

            //original
            return (this.config[colIndex].editable ||
                (typeof this.config[colIndex].editable == "undefined"
                        && this.config[colIndex].editor)) ? true : false;
        }
    });

    // create the Data Store
    var store = new Ext.data.GroupingStore({
        // load using HTTP
        proxy: new Ext.data.HttpProxy(new Ext.data.Connection(
                    { 
                        url:'go?action=dvdmajormdf&output=dvdmajorrelrulesxml', 
                        timeout:120000
                    })),
//        baseParams: {ostype: os},
        // the return will be XML, so lets set up a reader
        reader: new Ext.data.XmlReader({
               record: 'majorreleaserule'
           }, TrainRecord),
        sortInfo:{field: 'seq', direction: "ASC"},
        groupField:'major'
    });

    var grid = new Ext.grid.EditorGridPanel({
        store: store,
        cm: getColumnModel(),
        width:820,
        height:430,
	    loadMask: true,        

        view: new Ext.grid.GroupingView({
            forceFit:true,
            groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
        }),
        
        ddGroup: 'testDDGroup',
        enableDragDrop: true,
        el: 'content_div',
                         
        sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
        clicksToEdit:1,
        listeners: {
            beforeedit : function( o ) {
                //dataChanged(o);
            },
            afteredit : function(o) {
                dataChanged(o);
            },
            render: function(g) {
                // Best to create the drop target after render, so we don't need to worry about whether grid.el is null
                // constructor parameters:
                //    grid (required): GridPanel or EditorGridPanel (with enableDragDrop set to true and optionally a value specified for ddGroup, which defaults to 'GridDD')
                //    config (optional): config object
                // valid config params:
                //    anything accepted by DropTarget
                //    listeners: listeners object. There are 4 valid listeners, all listed in the example below
                //    copy: boolean. Determines whether to move (false) or copy (true) the row(s) (defaults to false for move)
                var ddrow = new Ext.ux.dd.GridReorderDropTarget(g, {
                    copy: false
                    ,listeners: {
                        beforerowmove: function(objThis, oldIndex, newIndex, records) {
                            // code goes here
                            // return false to cancel the move
                        }
                        ,afterrowmove: function(objThis, oldIndex, newIndex, records) {
                            var src = grid.store.getAt(oldIndex);
                            var dst = grid.store.getAt(newIndex);
                            
                            if( src.get('major') == dst.get('major') ) {
                                var sequence = grid.store.getAt(newIndex).get('seq');
                                
                                if(  oldIndex < newIndex ) {
                                    for(var j=newIndex; j > oldIndex; j--) {
                                        var record = grid.store.getAt(j);
                                        record.set( 'seq', grid.store.getAt(j-1).get('seq'));
                                    }
                                } else {
                                    for(var j=newIndex; j < oldIndex; j++) {
                                        var record = grid.store.getAt(j);
                                        record.set( 'seq', grid.store.getAt(j+1).get('seq'));
                                    }
                                }
                                src.set( 'seq', sequence);
                                
                                grid.store.sort('seq', 'ASC');
                            }
                        }
                        ,beforerowcopy: function(objThis, oldIndex, newIndex, records) {
                            // code goes here
                            // return false to cancel the copy
                        }
                        ,afterrowcopy: function(objThis, oldIndex, newIndex, records) {
                            // code goes here
                        }
                    }
                });

                // if you need scrolling, register the grid view's scroller with the scroll manager
                Ext.dd.ScrollManager.register(g.getView().getEditorParent());
            }
            ,beforedestroy: function(g) {
                // if you previously registered with the scroll manager, unregister it (if you don't it will lead to problems in IE)
                Ext.dd.ScrollManager.unregister(g.getView().getEditorParent());
            },
            cellclick:  function (o, row, cell, e) {
            }
        },
        tbar: myToolbarConfig
/*        
        bbar: new Ext.PagingToolbar( {
          pageSize: 200,
          store: store,
          displayInfo: true,
          displayMsg: 'Displaying records {0} - {1} of {2}',
          emptyMsg: "No records to display"
        }) */
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
            var items = win.form.items;
            // debugger;
           
            if( items.item("majortextfield") != 'undefined' ) { 
                items.item("majortextfield").setValue('');
                
                //if ( os == 'IOS' )
                    items.item("majortextfield").enable();
                //else 
                //    items.item("majortextfield").disable();                    
                
            }

            if( items.item("releasecomponentnamecombo") != 'undefined' ) {
              //  if ( os == 'IOS' )
              //      items.item("releasecomponentnamecombo").setValue('Train');
              //  else 
              //      items.item("releasecomponentnamecombo").setValue('Software Type');
              items.item("releasecomponentnamecombo").setValue(releaseComponentNames[0][0]);
            }

            if( items.item("operatorcombo") != 'undefined' ) {
                items.item("operatorcombo").setValue('Equal');

             //   if ( os == 'IOS' )
                    items.item("operatorcombo").enable();
             //   else 
             //     items.item("operatorcombo").disable();                    
            }

            if( items.item("releasecomponentvalue") != 'undefined' ) {
             //   if ( os == 'IOS' ) {
                    items.item("releasecomponentvalue").enable();
                    items.item("releasecomponentvalue").setValue('');
             //   } else  {
             //      items.item("releasecomponentvalue").disable();
             //      items.item("releasecomponentvalue").setValue(os);
             //   }                    
            }

            if( items.item("mdfidvalue") != 'undefined' ) 
                items.item("mdfidvalue").setValue('');
                
            win.show();
//            win.getAllocation(record);
          }
        };
    }();

    popupWindow.init();

    function getRuleWindow() {

	    var RuleWindow = function() {
		this.form = new Ext.form.FormPanel({
				baseCls: 'x-plain',
				name: 'innFormPanel',

				items: [
				{
					xtype: 'textfield',
					fieldLabel: 'Major Release',
					id: 'majortextfield',
                    width : 100,
					name: 'majortextfield',
					anchor:'100%'  // anchor width by percentage
				},
				{
				    xtype: "combo", //a comboBox
				    displayField:'releasecomponentname',
				    valueField:'releasecomponentname',
                    width : 100,
				    mode: 'local',
				    fieldLabel: 'Release Component Name',
				    id: 'releasecomponentnamecombo',
				    forceSelection:true,
				    triggerAction: 'all',
				    selectOnFocus:true,
                    anchor:'100%',
				    store: storeComponentNames,
				    listeners: {
				        change: function(thisObj, newValue, oldValue) {
				            //debugger;
                            if( newValue == 'Software Type' ) {
                                Ext.getCmp('majortextfield').setValue('');
                                Ext.getCmp('majortextfield').disable();
                                
                                Ext.getCmp('operatorcombo').setValue('Equal');
                                Ext.getCmp('operatorcombo').disable();

                                Ext.getCmp('releasecomponentvalue').setValue(os);
                                Ext.getCmp('releasecomponentvalue').disable();

                            } else if( oldValue == 'Software Type' ) {
                                Ext.getCmp('majortextfield').enable();
                                Ext.getCmp('operatorcombo').enable();

                                Ext.getCmp('releasecomponentvalue').setValue('');
                                Ext.getCmp('releasecomponentvalue').enable();
                            }
				        }
				    }
				},				
				{
				    xtype: "combo", //a comboBox
				    displayField:'operator',
				    valueField:'operator',
                    width : 100,
				    mode: 'local',
                    fieldLabel: 'Operator',
				    id: 'operatorcombo',
                    forceSelection:true,
				    triggerAction: 'all',
				    selectOnFocus:true,
                    anchor:'100%',
				    store: storeOperators
				},
                {
                    xtype: 'textfield',
                    boxLabel: 'Release Component Value',
                    width : 100,
                    id: 'releasecomponentvalue',
                    name: 'releasecomponentvalue',
                    fieldLabel: 'Release Component Value',
                    blankText : "Release Component Value can't be null",
                    allowBlank : false,
                    anchor:'100%'  // anchor width by percentage
                },                               
                {
                    xtype: 'textfield',
                    boxLabel: 'Mdf Id',
                    width : 100,
                    id: 'mdfidvalue',
                    name: 'mdfidvalue',
                    fieldLabel: 'Mdf Id',
                    blankText : "Mdf Id can't be null",
                    allowBlank : false,
                    anchor:'100%'  // anchor width by percentage
                }                               
				]
			    });

		RuleWindow.superclass.constructor.call(this,  {
			    title: 'Create New Rule',
			    id: 'platform-win',
			    width: 250,
			    height: 280,
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

            mdfCallback : function () {
                              alert('Check this' ); 
                              if (success) {
                                  mdfname = response.responseText;
                              } else{
                                  Ext.MessageBox.alert('Error!!!', response.responseText);
                              }
                           },
			onUpdate: function() {
			    
                var major = this.items.first().items.item('majortextfield').getValue();
                var releasecomp = this.items.first().items.item('releasecomponentnamecombo').getValue();

			    if( releasecomp != 'Software Type') {  
    				if( major == '' ) {
    				    Ext.MessageBox.alert('Error', "Major Release can't be empty" );
    				    return;
    				}
                }
                				
                if( releasecomp == '' ) {
                    Ext.MessageBox.alert('Error', "Release Component Name can't be empty" );
                    return;
                }

                var releaseop = this.items.first().items.item('operatorcombo').getValue();
                if( releaseop == '' ) {
                    Ext.MessageBox.alert('Error', "Operator can't be empty" );
                    return;
                }

                var releasevalue = this.items.first().items.item('releasecomponentvalue').getValue();
                if( releasevalue == '' ) {
                    Ext.MessageBox.alert('Error', "Release Component Value can't be empty" );
                    return;
                }

                var mdfid = this.items.first().items.item('mdfidvalue').getValue();
                if( mdfid == '' ) {
                    Ext.MessageBox.alert('Error', "Mdf Id can't be empty" );
                    return;
                }
                var mdfconceptname = '';

                Ext.Ajax.request({
                    url: 'go?action=dvdmajormdf&output=mdfname&mdfid=' + mdfid,
                    method: 'GET',
                    success: function(response, options) {
                                  mdfconceptname = response.responseText
                             },
                    failure: function(response, options) {
                                mdfconceptname = 'Error'
                             },
                    scope: this,
                    async: false
                });
                
                if( mdfconceptname == 'Error' ) {
                    Ext.MessageBox.alert('Error', "Unable to get the mdf concept name for id - " + mdfid );
                    return;
                }
            
                if( mdfconceptname == 'Invalid' ) {
                    Ext.MessageBox.alert('Error', "Invalid mdf id entered. Please check and submit again" );
                    return;
                }

				var count = grid.store.getCount();
				var max = -1;
				var index = -1;

                for(var j=0; j<count; j++) {
                    var record = grid.store.getAt(j);
                    if( record.get('major') == major && 
                            record.get('compname') == releasecomp &&
                                record.get('operator') == releaseop &&
                                    record.get('compvalue') == releasevalue) {
                        Ext.MessageBox.alert('Error', "Duplicate Rule found. Please check and submit again" );
                        return;
                    } 
                }

				for(var i=0; i<count; i++) {
					var record = grid.store.getAt(i);
					if( record.get('major') == major ) {
						if(record.get('seq') > max )
							max = record.get('seq') ;
							index = i;
					} else if( record.get('major') < major ) {
					       index = i;
					}
				}
				
				max++;
				grid.store.insert(index + 1, new  TrainRecord({
           					id: 'NewRule', 
           					major: '' + major,
           					compname: this.items.first().items.item('releasecomponentnamecombo').getValue(),
           					operator : this.items.first().items.item('operatorcombo').getValue(),
           					compvalue : this.items.first().items.item('releasecomponentvalue').getValue(),
           					seq : max,
           					mdf : this.items.first().items.item('mdfidvalue').getValue(),
           					mdfname : mdfconceptname
           					}));

                    var found = false;
                    for(var k=0;k<modifiedRecordsIndex;k++) {
                        if(modifiedMajorReleases[k] == major) {
                            found = true;
                            break;
                        }
                    }
                    
                    if( !found )  {
                        modifiedMajorReleases[modifiedRecordsIndex++] = major;
                    }
           					
				this.hide();
			},

            getAllocation : function(record) {
                Ext.MessageBox.alert('Message', "AllocWin: this will isssue AJAX request" );
			}
	    	});

        	return new RuleWindow();
    	}

    var simple = new Ext.FormPanel({
        frame:true,
        title: 'Dvd Major Release Rule Engine',
        width:830,
        height:500,

        buttons: [{
            text: 'Save',
            handler : onSubmit
        },{
            text: 'Cancel',
            handler : function() {
                var changed = false;
                if( grid.store.getModifiedRecords().length > 0 || Ext.get('deleteddata').dom.value != '') {
                    changed = true; 
                } else {
                    for(var i=0; i<grid.store.getCount(); i++) {
                        var currecord = grid.store.getAt(i);
                        if( currecord.get('id').indexOf('NewRule') != -1) {
                            changed = true;
                            break;
                        }
                    }                
                }
        
                if(changed) {
                    Ext.Msg.confirm('Cancel Changes?', 'Do you really want cancel all the changes?', 
                        function(btn, text){
                            if (btn == 'yes'){
                                store.rejectChanges();
                                store.reload();
                                modifiedMajorReleases = new Array();
                                Ext.get('deleteddata').dom.value = '';
                            }
                        });
                } else {
                    Ext.MessageBox.alert('Cancel Changes?', "None of the rules were changed." );
                }
            }
        }]
    });

    function dataChanged(o) {
        if( o.field == "mdf" ) {
            var mdfconceptname = '';
             
            Ext.Ajax.request({
                url: 'go?action=dvdmajormdf&output=mdfname&mdfid=' + o.value,
                method: 'GET',
                success: function(response, options) {
                              mdfconceptname = response.responseText
                         },
                failure: function(response, options) {
                            mdfconceptname = 'Error'
                         },
                scope: this,
                async: false
            });

            if( mdfconceptname == 'Error' || mdfconceptname == 'Invalid') {
                if( mdfconceptname == 'Error' )
                    Ext.MessageBox.alert('Error', "Unable to get the mdf concept name for id - " + o.value );
                else 
                    Ext.MessageBox.alert('Error', "Invalid mdf id entered. Please check and submit again" );
                    
                o.record.set( "mdf", o.originalValue );
                return;
            }
            
            var id = o.record.get("imageid");
            o.record.set( "mdfname", mdfconceptname );
        } else if( o.field == "compname" || o.field == "operator" || o.field == "compvalue" ) {
            for(var j=0; j<grid.store.getCount(); j++) {
                var record = grid.store.getAt(j);
                if( record != o.record &&
                        record.get('major') == o.record.get('major') && 
                            record.get('compname') == o.record.get('compname') &&
                                record.get('operator') == o.record.get('operator') &&
                                    record.get('compvalue') == o.record.get('compvalue')) {
                    Ext.MessageBox.alert('Error', "Duplicate Rule found. Please make sure you enter unique rules. " );
                    o.record.set( o.field, o.originalValue );
                } 
            }
        }
    }

    simple.add(grid);
    simple.render('editor-grid');
    
    var saving = new Ext.LoadMask('editor-grid', {msg: 'Applying the rules...'});    

    function getRecordDataAsString(record) {
            return record.get('id') + '|' +
                record.get('major') + '|' + 
                record.get('compname') + '|' + 
                record.get('operator') + '|' + 
                record.get('compvalue') + '|' + 
                record.get('mdf') + '|' + 
                record.get('seq') + '#';
    }

    function onSubmit() {
    
        saving.show();
        
        var modifiedRecords = grid.store.getModifiedRecords();
        var index = 0;
        var buffer = '';
        
        for(var index=0; index<modifiedRecords.length; index++) {
            var record = modifiedRecords[index];
            var major = record.get('major');
            var found = false;
            
            for(var k=0;k<modifiedRecordsIndex;k++) {
                if(modifiedMajorReleases[k] ==  major) {
                    found = true;
                    break;
                }
            }
            
            if( !found ) {
                modifiedMajorReleases[modifiedRecordsIndex++] = major;
            }
        }
        
        for(var i=0; i<grid.store.getCount(); i++) {
            var currecord = grid.store.getAt(i);
            
            var found = false;
            for(var k=0;k<modifiedRecordsIndex;k++) {
                if(modifiedMajorReleases[k] == currecord.get('major') ) {
                    found = true;
                    break;
                }
            }
            
            if(found) {
                if( currecord.get('id').indexOf('NewRule') != -1)
                    buffer = buffer + 'N';
                else {
                    var modified = false;
                    for(var index=0; index<modifiedRecords.length; index++) {
                        var record = modifiedRecords[index];
                        if( currecord == record ) {
                            modified = true;
                            break;
                        }
                    }
                    
                    if( modified )
                        buffer = buffer + 'M';
                    else 
                        buffer = buffer + 'U';   
                    
                }
                buffer += '|' + getRecordDataAsString(currecord);
            }
        }
        
        buffer = Ext.get('deleteddata').dom.value + buffer;
        
        if( buffer != '' ) {
            var obj = Ext.get('ostype');
            obj.dom.value = os;
            
            obj = Ext.get('rulesdata');
            obj.dom.value = buffer;
            
            Ext.get('dvdform').dom.submit();
        } else {
            saving.hide();
            Ext.MessageBox.alert('Warning', "None of the rules changed to submit." );
        }

    }; // end of onSubmit

    // trigger the data store load
    store.load({params: {ostype: os, start:0, limit:25} });

    Ext.getCmp('ostypecombo').setValue( '<c:out value="${requestScope['ostype']}"/>' );
    Ext.getCmp('ostypecombo').on('select', function() {
            os = this.getValue();

        	store.commitChanges();
            storeComponentNames.loadData( getReleaseComponents(os) );
            
            modifiedMajorReleases = new Array();
            Ext.get('deleteddata').dom.value = '';
        	
        	store.load( {params: {ostype: os, start:0, limit:25} });
    });    

/* start of tree */
/*
    var Tree = Ext.tree;
    
    var tree = new Tree.TreePanel({
        el:'mdf-div',
        useArrows:true,
        autoScroll:true,
        animate:true,
        enableDD:false,
        containerScroll: true, 
        loader: new Tree.TreeLoader({
            dataUrl:'go?action=mdftreenodes'
        })
    });

    // set the root node
    var root = new Tree.AsyncTreeNode({
        text: 'Cisco Products',
        draggable:false,
        id:'268437593'
    });
    tree.setRootNode(root);

    // render the tree
    tree.render();
    root.expand(); */
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
//            var id = record.get("check");
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
<div id="content_div"></div>


<%
List on1=(List)request.getAttribute("ruleoperatorlist");
out.println("<select name='ruleoperator' id='ruleoperator'>");
Iterator it1=on1.iterator();
while(it1.hasNext())
 out.println("<option>"+(String)it1.next()+"</option>");
 
out.println("</select>");
%>
<form name="dvdform" method="post" action="go?action=dvdmajormdf&output=dvdmajorrelrulesconfpage">
    <input type="hidden" id="rulesdata" name="rulesdata" value="">
    <input type="hidden" id="deleteddata" name="deleteddata" value="">
    <input type="hidden" id="ostype" name="ostype" value="">
    <input type="hidden" id="frompage" name="frompage" value="DvdMajorReleaseRules">
</form>    

<div id="mdf-div"></div>
    <spritui:footer/>
</spritui:page>
