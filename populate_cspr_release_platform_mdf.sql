--Copyright (c) 2007 by Cisco Systems, Inc.
INSERT INTO cspr_release_platform_mdf 
    ( CSPR_RELEASE_PLATFORM_MDF_ID
      , RELEASE_NUMBER_ID
      , PLATFORM_ID
      , MDF_CONCEPT_ID
      , IS_GOING_TO_CCO
      , CREATED_BY
      , CREATED_DATE
      , ADM_USERID
      , ADM_TIMESTAMP
      , ADM_FLAG
      , ADM_COMMENT )
SELECT 
    cspr_release_platform_mdf_seq.nextval, 
    release_number_id, 
    individual_platform_id, 
    mdf_concept_id, 
    'Y', 
    'sraju',
    sysdate, 
    'sraju',
    sysdate, 
    'V', 
    'Data migration'
FROM     
    (SELECT DISTINCT 
        rn.release_number_id, 
        ip.individual_platform_id,
        ipm.mdf_concept_id
    FROM
        shr_image i
        , shr_release_number rn
        , shr_platform_image pi
        , shr_individual_platform ip
        , shr_individual_platform_mdf ipm
    WHERE
        i.release_number_id = rn.release_number_id 
        AND i.image_id = pi.image_id
        AND pi.individual_platform_id = ip.individual_platform_id
        AND ip.individual_platform_id = ipm.individual_platform_id
        AND i.adm_flag = 'V'
        AND i.is_posted_to_cco = 'Y'
        AND i.is_in_image_list = 'Y'
        AND rn.adm_flag = 'V'
        AND pi.adm_flag = 'V'
        AND ip.adm_flag = 'V'
        AND ipm.adm_flag = 'V'
    );
    
