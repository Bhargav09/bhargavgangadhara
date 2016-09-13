--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE FORCE VIEW SHR_RDA.VIEW_PCODE_MFG
(
   PRODUCT,
   FEATURESET,
   IOS_DESCRIPTION,
   FEATUREDESCRIPTION,
   RELEASE_TRAIN,
   IMAGE,
   CREATE_DT,
   CREATE_USER,
   OS_TYPE_NAME
)
AS
   SELECT   DISTINCT
            mco.product_name product,
            sfsdr.feature_set_designator featureset,
            mco.product_desc ios_description,
            sfsd.feature_set_desc featuredescription,
            smr.major_release_number || '.' || srn.z || srn.a release_train,
            si.image_name image,
            SYSDATE create_dt,
            USER create_user,
            os.os_type_name os_type_name
     FROM   shr_image si,
            shr_image_feature_set sifs,
            sprit.mfg_cache_opus mco,
            shr_feature_set sfs,
            shr_feature_set_desc sfsd,
            shr_feature_set_designator sfsdr,
            shr_release_number srn,
            shr_major_release smr,
            shr_os_type os
    WHERE       si.release_number_id = srn.release_number_id
            AND srn.major_release_id = smr.major_release_id
            AND si.is_obsolete = 'N'
            AND sifs.adm_flag = 'V'
            AND si.adm_flag = 'V'
            AND sfs.adm_flag = 'V'
            AND si.is_in_image_list = 'Y'
            AND si.image_id = sifs.image_id
            AND sifs.feature_set_id = sfs.feature_set_id
            AND sfs.feature_set_desc_id = sfsd.feature_set_desc_id
            AND sfs.feature_set_designator_id =
                  sfsdr.feature_set_designator_id(+)
            AND mco.rel = smr.major_release_number
            AND mco.maint = srn.z
            AND NVL (mco.mren, 'N') = NVL (srn.p, 'N')
            AND NVL (mco.ed, 'N') = NVL (srn.a, 'N')
            AND NVL (mco.edr, 'N') = NVL (srn.o, 'N')
            AND SUBSTR (mco.image, 1, INSTR (mco.image, '.') - 1) =
                  si.image_name
            AND mco.product_desc LIKE '%' || sfsd.feature_set_desc || '%'
            AND mco.process_status = 'approved'
            AND os.os_type_id = smr.os_type_id;


DROP SYNONYM ITEDW.VIEW_PCODE_MFG;

CREATE SYNONYM ITEDW.VIEW_PCODE_MFG FOR SHR_RDA.VIEW_PCODE_MFG;


DROP SYNONYM SIIS_VIEW_USER.VIEW_PCODE_MFG;

CREATE SYNONYM SIIS_VIEW_USER.VIEW_PCODE_MFG FOR SHR_RDA.VIEW_PCODE_MFG;


GRANT SELECT ON SHR_RDA.VIEW_PCODE_MFG TO ITEDW;

GRANT SELECT ON SHR_RDA.VIEW_PCODE_MFG TO SIIS;

GRANT SELECT ON SHR_RDA.VIEW_PCODE_MFG TO SIIS_VIEW_USER;



