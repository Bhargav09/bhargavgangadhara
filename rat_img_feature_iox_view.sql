CREATE OR REPLACE FORCE VIEW SHR_RDA.RAT_IMG_FEATURE_IOX_VIEW
(
   IMAGE,
   FEATUREDESC,
   RELEASE,
   PLATFORM,
   PLATFORM_FAMILY,
   STATUS,
   RELEASE_NUMBER,
   MINDRAM,
   MINFLASH,
   CCOTIME
)
AS
   SELECT   DISTINCT ic.image_name image,
                     ic.image_description featuredesc,
                     io.release_component_1 release,
                     sip.individual_platform_name platform,
                     spf.platform_family_name platform_family,
                     'NA' status,
                     io.release_name release_number,
                     ic.dram mindram,
                     ic.min_flash minflash,
                     cips.cco_first_posted_time ccotime
     FROM   cspr_release_number io --iox_opus                                         io
                                  ,
            cspr_image ic --iox_cco                                          ic
                         ,
            cspr_platform_image cpi,
            shr_individual_platform sip,
            shr_platform_family spf,
            shr_os_type os,
            cspr_image_posting_status cips
    WHERE       io.RELEASE_NUMBER_ID = ic.RELEASE_NUMBER_ID
            AND cpi.INDIVIDUAL_PLATFORM_ID = sip.INDIVIDUAL_PLATFORM_ID
            AND sip.PLATFORM_FAMILY_ID = spf.PLATFORM_FAMILY_ID
            AND cpi.image_id = ic.image_id
            AND ic.image_id = cips.image_id
            AND io.os_type_id = os.os_type_id;


DROP SYNONYM SRDA_RAT.VW_IMAGE_FEATURE_PRODUCT_IOX;

CREATE SYNONYM SRDA_RAT.VW_IMAGE_FEATURE_PRODUCT_IOX FOR SHR_RDA.RAT_IMG_FEATURE_IOX_VIEW;


GRANT SELECT ON SHR_RDA.RAT_IMG_FEATURE_IOX_VIEW TO SRDA_RAT;

