--Insert Guest Registered MetaData in cspr_metadata table
insert into cspr_metadata (
 Metadata_id
,Metadata_name
,Metadata_ui_label
,Metadata_xml_element_name
,Metadata_table_name
,Metadata_column_name
,Metadata_desc
,Metadata_validation_query
,Is_cco_required
,Created_by    
,Created_date    
,Adm_userid    
,Adm_timestamp    
,Adm_flag    
,Adm_comment)
values (
 cspr_metadata_seq.nextval
,'GUEST_REGISTERED_APPROVAL_REQUIRED'
,'GUEST_REGISTERED_APPROVAL_REQUIRED'
,'GUEST_REGISTERED_APPROVAL_REQUIRED'
,'CSPR_IMAGE'
,'CDC_ACCESS_LEVEL_ID'
,'GUEST_REGISTERED_APPROVAL_REQUIRED'
,'FROM cspr_image WHERE image_id IN'
,'N'
,'aburadka'
,sysdate
,'aburadka'
,sysdate
,'V'
,'Manually Populated'
);

-- rename the guest_registered_approval_required to free_sw_publish_allowed 
-- in manage metadata under admin role 

 update cspr_metadata
set metadata_name = 'FREE_SW_PUBLISH_ALLOWED',
    metadata_ui_label = 'FREE_SW_PUBLISH_ALLOWED',
    metadata_xml_element_name = 'FREE_SW_PUBLISH_ALLOWED',
    metadata_desc = 'FREE_SW_PUBLISH_ALLOWED',
    adm_userid = 'spathala',
    adm_timestamp = sysdate,
    adm_comment = 'Manually Populated, changed GUEST_REG to FREE_SW'
where metadata_id in (select metadata_id
                        from cspr_metadata
                       where metadata_name = 'GUEST_REGISTERED_APPROVAL_REQUIRED');

commit;

--Populate the sprit_email_alias table with email Ids for pending approval and approval change notifications
insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)                     
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'GuestRegBUFinContoller','dev', 'sprit-notification-test@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'GuestRegBUFinContoller','test', 'sprit-notification-test@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'GuestRegBUFinContoller','prod', 'sprit-notification@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG,ADM_COMMENT)
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'GuestRegBUFinContoller','prod', 'cdo_fin_ops@cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

-- update the sprit_email_alias table with the new activity name FreeSwBUFinController for GuestRegBUFinContoller

update sprit_email_alias
set activity_name = 'FreeSwBUFinController',
    adm_userid = 'spathala',
    adm_timestamp = sysdate
where activity_name = 'GuestRegBUFinContoller';

commit;

--Populate the SPRIT_PROPERTIES table with approver type metadata
insert into sprit_properties (PROPERTY_ID, PROPERTY_NAME, PROPERTY_SEQ, PROPERTY_DESC, PROD_VALUE, DEV_VALUE, TEST_VALUE, ADM_TIMESTAMP, ADM_USERID, ADM_FLAG, ADM_COMMENT)
values(sprit_properties_seq.nextval,'GUESTREGAPPROVER',1,'BU Manager','BU Manager','BU Manager','BU Manager',sysdate,'aburadka','V','Added Manually');

insert into sprit_properties (PROPERTY_ID, PROPERTY_NAME, PROPERTY_SEQ, PROPERTY_DESC, PROD_VALUE, DEV_VALUE, TEST_VALUE, ADM_TIMESTAMP, ADM_USERID, ADM_FLAG, ADM_COMMENT)
values(sprit_properties_seq.nextval,'GUESTREGAPPROVER',2,'BU Finance/Controller','BU Finance/Controller','BU Finance/Controller','BU Finance/Controller',sysdate,'aburadka','V','Added Manually');

insert into sprit_properties (PROPERTY_ID, PROPERTY_NAME, PROPERTY_SEQ, PROPERTY_DESC, PROD_VALUE, DEV_VALUE, TEST_VALUE, ADM_TIMESTAMP, ADM_USERID, ADM_FLAG, ADM_COMMENT)
values(sprit_properties_seq.nextval,'GUESTREGAPPROVER',3,'Revenue PGD','Revenue PGD','Revenue PGD','Revenue PGD',sysdate,'aburadka','V','Added Manually');

-- update the property_name from 'GUESTREGAPPROVER' to 'FREESWAPPROVER' in sprit_properties table

 update sprit_properties
 set property_name = 'FREESWAPPROVER',
     adm_comment = 'Manually added, changed guest reg to free sw'
 where property_id in (select property_id 
                       from   sprit_properties
                       where  property_name = 'GUESTREGAPPROVER');

commit;

--Populate the CSPR_APPROVER_TYPE table with approver type metadata
Insert into CSPR_APPROVER_TYPE (APPROVER_TYPE_ID,PROPERTY_ID,APPROVAL_REQUIRED,APPROVER_ADMIN_CONTROLLER,ADM_TIMESTAMP,ADM_USERID,ADM_FLAG,ADM_COMMENT,CREATED_BY,CREATED_DATE)
values(CSPR_APPROVER_TYPE_SEQ.nextVal,51,'Y','N',sysdate,'aburadka','V','Manually added','aburadka',sysdate);

Insert into CSPR_APPROVER_TYPE (APPROVER_TYPE_ID,PROPERTY_ID,APPROVAL_REQUIRED,APPROVER_ADMIN_CONTROLLER,ADM_TIMESTAMP,ADM_USERID,ADM_FLAG,ADM_COMMENT,CREATED_BY,CREATED_DATE)
values(CSPR_APPROVER_TYPE_SEQ.nextVal,52,'Y','Y',sysdate,'aburadka','V','Manually added','aburadka',sysdate);

Insert into CSPR_APPROVER_TYPE (APPROVER_TYPE_ID,PROPERTY_ID,APPROVAL_REQUIRED,APPROVER_ADMIN_CONTROLLER,ADM_TIMESTAMP,ADM_USERID,ADM_FLAG,ADM_COMMENT,CREATED_BY,CREATED_DATE)
values(CSPR_APPROVER_TYPE_SEQ.nextVal,53,'Y','N',sysdate,'aburadka','V','Manually added','aburadka',sysdate);
commit;


--Populate the sprit_email_alias table with SMTP Host server
insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG,ADM_COMMENT) 
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'SmtpHost','dev', 'champ.cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'SmtpHost','test', 'champ.cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

insert into sprit_email_alias(SPRIT_EMAIL_ALIAS_ID, OS_TYPE_ID, ACTIVITY_NAME, ENVIRONMENT, EMAIL_ALIAS, CREATED_BY, CREATED_DATE, ADM_USERID, ADM_TIMESTAMP, ADM_FLAG, ADM_COMMENT)
values(SPRIT_EMAIL_ALIAS_SEQ.nextval, null, 'SmtpHost','prod', 'champ.cisco.com', 'aburadka', sysdate, 'aburadka', sysdate, 'V', 'created by aburadka');

commit;