--Copyright (c) 2006 by Cisco Systems, Inc. -- kdharmal

DECLARE
  CURSOR c1 IS 
  SELECT shr_image_seq.nextval image_id, 
         ION_PATCH_SEQ_ID
   FROM ION_PATCH;
BEGIN
  FOR c1_rec IN c1 LOOP
    UPDATE ION_PATCH
	  SET image_id =  c1_rec.image_id
	WHERE ION_PATCH_SEQ_ID = c1_rec.ION_PATCH_SEQ_ID;
  END LOOP;
END;

insert into sprit.cspr_image_posting_status
 ( image_id, cco_transaction_type, cco_transaction_status, 
   cco_transaction_time, cco_posted_time, cco_posted_by, created_by,
   created_date, adm_userid, adm_timestamp, adm_flag, adm_comment
 )
 (
 select 
  ip.image_id
  , 'Post' AS "CCO_TRANSACTION_TYPE"
  , DECODE( nvl(ip.is_posted_to_cco,'N'), 'Y', 'Fail', 'N', 'Fail' ) AS "CCO_TRANSACTION_STATUS" 
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