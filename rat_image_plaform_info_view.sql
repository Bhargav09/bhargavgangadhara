CREATE OR REPLACE FORCE VIEW SHR_RDA.RAT_IMAGE_PLAFORM_INFO_VIEW
(
   IMAGE,
   PLATFORM,
   FEATUREDESC,
   RELEASE_NUMBER,
   MINDRAM,
   MINFLASH,
   DEFERRAL
)
AS
   SELECT                                                    /*+ FIRST_ROWS */
         DISTINCT si.image_name image,
                  sip.individual_platform_name platform,
                  sfsd.feature_set_desc featuredesc,
                  release_number release_number,
                  spi.dram mindram,
                  spi.min_flash minflash,
                  si.is_deferred deferral
     FROM   shr_image si,
            shr_platform_image spi,
            shr_image_feature_set sifs,
            --shr_pcode sp,
            shr_feature_set sfs,
            shr_feature_set_desc sfsd,
            --shr_feature_set_designator sfsdr,
            --shr_release_pcode_group srpg,
            shr_release_number srn,
            --shr_platform_pcode_group sppg,
            shr_individual_platform sip,
            --shr_pcode_group spg,
            shr_major_release smr,
            --shr_deployment_status sds,
            --shr_release_type srt,
            --shr_train_type stt,
            shr_os_type os
    --cspr_image_posting_status cips,
    --shr_image_posting_type sipt
    WHERE       si.release_number_id = srn.release_number_id
            AND srn.major_release_id = smr.major_release_id
            AND si.image_id = spi.image_id
            AND spi.individual_platform_id = sip.individual_platform_id
            AND si.image_id = sifs.image_id
            AND sifs.feature_set_id = sfs.feature_set_id
            AND sfs.feature_set_desc_id = sfsd.feature_set_desc_id
            AND os.os_type_id = smr.os_type_id
            AND sifs.adm_flag = 'V'
            AND si.adm_flag = 'V'
            AND sfs.adm_flag = 'V'
            AND spi.adm_flag = 'V'
            AND si.is_in_image_list = 'Y'
            AND spi.is_in_image_list = 'Y';


DROP SYNONYM SRDA_RAT.VW_IMAGE_FEATURE_PRODUCT;

CREATE SYNONYM SRDA_RAT.VW_IMAGE_FEATURE_PRODUCT FOR SHR_RDA.RAT_IMAGE_PLAFORM_INFO_VIEW;

GRANT SELECT ON SHR_RDA.RAT_IMAGE_PLAFORM_INFO_VIEW TO SRDA_RAT;

