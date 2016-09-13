/*
    Copyright (c) 2007 by Cisco Systems, Inc.
*/

CREATE OR REPLACE VIEW VW_IMAGE_POSTING_TYPE
(RELEASE_NUMBER, FULL_IMAGE_NAME, IMAGE_POSTING_TYPE_NAME, BUILDNUM)
AS 
select release_number
, image_name||'.'||replace(replace(replace(smr.major_release_number,'.','') 
   ||'-'||srn.z||srn.p||decode(srn.a,'','','.' 
   ||srn.a||srn.o),'(','.'),')','') full_image_name
       ,decode(image_posting_type_name,'Hidden with ACL','Hidden',image_posting_type_name)image_posting_type_name
        ,replace(replace(replace(smr.major_release_number,'.','') 
   ||'-'||srn.z||srn.p||decode(srn.a,'','','.' 
   ||srn.a||srn.o),'(','.'),')','')                                buildnum
from shr_release_number srn
,shr_major_release smr
        ,shr_image si
    ,shr_image_posting_type sipt
where srn.release_number_id=si.release_number_id
and srn.major_release_id=smr.major_release_id
and si.image_posting_type_id=sipt.image_posting_type_id
and is_in_image_list='Y'
and   si.adm_flag='V'
and srn.release_type_id in(1,5);

GRANT SELECT ON VW_IMAGE_POSTING_TYPE TO SIIS_BUILD;
