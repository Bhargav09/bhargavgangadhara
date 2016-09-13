--Copyright (c) 2006 by Cisco Systems, Inc. - kdharmal
--Migrate data from ION_PATCH table to cspr_image_posting_status in order to sync data.

insert into sprit.cspr_image_posting_status
 ( image_id, cco_transaction_type, cco_transaction_status, 
   cco_transaction_time, cco_posted_time, cco_posted_by, created_by,
   created_date, adm_userid, adm_timestamp, adm_flag, adm_comment
 )
 (
 select 
  ip.image_id
  , 'Post' AS "CCO_TRANSACTION_TYPE"
  , DECODE( nvl(ip.is_posted_to_cco,'N'), 'Y', 'Success', 'N', 'Fail' ) AS "CCO_TRANSACTION_STATUS" 
  , ip.cco_date AS "CCO_TRANSACTION_TIME"
  , ip.cco_date AS "CCO_POSTED_TIME"
  , 'Spublish' AS "CCO_POSTED_BY"
  , 'Spublish' AS "CREATED_BY"
  , ip.CREATED_DATE
  , 'Spublish' AS "ADM_USERID"
  , ip.ADM_TIMESTAMP
  , ip.ADM_FLAG
  , ip.ADM_COMMENT
from
  ion_patch   ip
)




		

