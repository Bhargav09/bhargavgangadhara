--
-- Copyright (c) 2003 by Cisco Systems, Inc.
--


CREATE OR REPLACE FORCE VIEW 
  SHR_RDA_TEST.VW_IMAGE_FEATURE_CMC (
    SEQ, 
    RELEASE, 
    IMAGE, 
    FEATUREDESC, 
    IS_CCO_ORDERABLE, 
    IS_MFG_ORDERABLE, 
    IS_IN_IMAGE_LIST, 
    LAST_UPDATED_DATE
  ) AS SELECT 
    img.image_id,
    mjr.major_release_number
      ||'('       
      ||zabp       
      ||')'       
      ||A       
      ||O,
    img.image_name       
      ||'.'       
      ||replace(
        mjr.major_release_number,
        '.',
        ''
      )
      ||'-'       
      ||zabp       
      ||decode(
        A,
        '',
        '',
        '.'||A||O
      ),
    ifs.feature_set_desc,
    img.is_cco_orderable,
    img.is_mfg_orderable,
    img.is_in_image_list,
    greatest(       
      nvl(mjr.adm_timestamp,to_date('01-01-0001','MM-DD-YYYY')),
      nvl(rel.adm_timestamp,to_date('01-01-0001','MM-DD-YYYY')),
      nvl(img.adm_timestamp,to_date('01-01-0001','MM-DD-YYYY')),
      nvl(imgfsetdate,to_date('01-01-0001','MM-DD-YYYY')),
      nvl(fsetdate,to_date('01-01-0001','MM-DD-YYYY')),
      nvl(descdate,to_date('01-01-0001','MM-DD-YYYY'))     
    )
  FROM 
    shr_image img,
    shr_major_release mjr,
    shr_release_number rel,
    ( select         
	ifs.image_id,
	ifs.adm_timestamp imgfsetdate,
	fst.adm_timestamp fsetdate,  
	fsd.adm_timestamp descdate,
	feature_set_desc       
      from         
        shr_feature_set fst,
        shr_feature_set_desc fsd,
        shr_image_feature_set ifs
      WHERE 
        ifs.feature_set_id=fst.feature_set_id and
        fst.feature_set_desc_id=fsd.feature_set_desc_id and
        fst.adm_flag='V' and
        fsd.adm_flag='V' and
        ifs.adm_flag='V'
    ) ifs  
  where    
    img.release_number_id=rel.release_number_id and
    img.adm_flag='V' and
    rel.adm_flag='V' and
    mjr.major_release_id=rel.major_release_id and
    mjr.adm_flag='V' and
    img.image_id=ifs.image_id(+);

GRANT SELECT ON  SHR_RDA_TEST.VW_IMAGE_FEATURE_CMC TO SPRIT_DEV;

GRANT SELECT ON  SHR_RDA_TEST.VW_IMAGE_FEATURE_CMC TO SPRIT_TEST;

