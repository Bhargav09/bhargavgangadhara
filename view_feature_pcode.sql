--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE FORCE VIEW SHR_RDA.VIEW_FEATURE_PCODE
(
   PRODUCT,
   FEATURESET,
   FEATURE_DESCRIPTION,
   RELEASE_TRAIN,
   IMAGE,
   CREATE_DT,
   CREATE_USER
)
AS
   SELECT   DISTINCT
            sp.pcode_main product,
            sfsdr.feature_set_designator featureset,
            sfsd.feature_set_desc feature_description,
            smr.major_release_number || '.' || srn.z || srn.a release_train,
            si.image_name image,
            SYSDATE create_dt,
            USER create_user
     FROM   shr_image si,
            shr_image_feature_set sifs,
            shr_pcode sp,
            shr_feature_set sfs,
            shr_feature_set_desc sfsd,
            shr_feature_set_designator sfsdr,
            shr_release_number srn,
            shr_major_release smr
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
                  sfsdr.feature_set_designator_id
            AND sifs.image_feature_set_id = sp.image_feature_set_id
            AND sp.pcode_main IS NOT NULL
   UNION
   SELECT   DISTINCT
            sp.pcode_spare product,
            sfsdr.feature_set_designator featureset,
            sfsd.feature_set_desc feature_description,
            smr.major_release_number || '.' || srn.z || srn.a release_train,
            si.image_name image,
            SYSDATE create_dt,
            USER create_user
     FROM   shr_image si,
            shr_image_feature_set sifs,
            shr_pcode sp,
            shr_feature_set sfs,
            shr_feature_set_desc sfsd,
            shr_feature_set_designator sfsdr,
            shr_release_number srn,
            shr_major_release smr
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
                  sfsdr.feature_set_designator_id
            AND sifs.image_feature_set_id = sp.image_feature_set_id
            AND sp.pcode_spare IS NOT NULL;


DROP SYNONYM ITEDW.VIEW_FEATURE_PCODE;

CREATE SYNONYM ITEDW.VIEW_FEATURE_PCODE FOR SHR_RDA.VIEW_FEATURE_PCODE;


DROP SYNONYM SIIS_VIEW_USER.VIEW_FEATURE_PCODE;

CREATE SYNONYM SIIS_VIEW_USER.VIEW_FEATURE_PCODE FOR SHR_RDA.VIEW_FEATURE_PCODE;


GRANT SELECT ON SHR_RDA.VIEW_FEATURE_PCODE TO ITEDW;

GRANT SELECT ON SHR_RDA.VIEW_FEATURE_PCODE TO SIIS;

GRANT SELECT ON SHR_RDA.VIEW_FEATURE_PCODE TO SIIS_VIEW_USER;
