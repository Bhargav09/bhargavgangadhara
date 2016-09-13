--Copyright (c) 2006 by Cisco Systems, Inc. -kdharmal

insert into shr_os_type
 ( os_type_id, os_type_name, description, 
   adm_timestamp, adm_userid,adm_flag, adm_comment,created_by,
   created_date
 )
 values
 (SHR_OS_TYPE_SEQ.nextval,'ION Maintenance Pack', 'ION Maintenance Pack', sysdate , 'kdharmal', 'V', '', 'kdharmal', sysdate)

 insert into shr_os_type
 ( os_type_id, os_type_name, description, 
   adm_timestamp, adm_userid,adm_flag, adm_comment,created_by,
   created_date
 )
 values
 (SHR_OS_TYPE_SEQ.nextval,'ION Patch', 'ION Patch', sysdate , 'kdharmal', 'V', 'ION Patch', 'kdharmal', sysdate)