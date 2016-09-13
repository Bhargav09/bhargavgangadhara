-- Copyright (c) 2006-2007 by Cisco Systems, Inc. -- kdharmal

INSERT INTO shr_release_number_mdf
(
  release_number_mdf_id, release_number_id, mdf_concept_id, created_by, created_date,
  adm_userid, adm_timestamp, adm_flag, adm_comment
) SELECT SHR_RELEASE_MDF_SEQ.nextval, release_number_id,mdf_concept_id
      , 'kdharmal' AS "CREATED_BY"
      , sysdate
      , 'kdharmal' AS "ADM_USERID"
      , sysdate
      , 'V'
      , 'Initial Data Population'
FROM shr_release_number a
  ,SHR_MDF_PRODUCTS_ATTR b
WHERE b.mdf_concept_name like '%'|| release_number and a.release_number is not null
