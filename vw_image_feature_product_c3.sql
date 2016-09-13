CREATE OR REPLACE FORCE VIEW SHR_RDA.VW_IMAGE_FEATURE_PRODUCT_C3
(
   RELEASE,
   MAINTENANCE,
   MRENUMBER,
   ED_DESIGNATOR,
   ED_RENUMBER,
   RELEASE_NUMBER,
   TRAIN_TYPE,
   RELEASE_TYPE_NAME,
   STATUS,
   IMAGE,
   IMAGE_ID,
   PLATFORM,
   INDIVIDUAL_PLATFORM_ID,
   MINDRAM,
   MINFLASH,
   FEATUREDESC,
   FEATURE_DESIGNATOR,
   CCO,
   CCOTIME,
   PLATFORM_FAMILY,
   IMAGESIZE,
   MD5CHKSUM,
   BUILD,
   BUILDTIME,
   MFGTIME,
   BUILDNUM,
   NETBOOT,
   SWADVISE,
   SOFTWARE_ADVISORY_ID,
   DEFERRAL,
   DEFERRAL_REQUEST_ID,
   PCODE_SYS,
   PCODE_SPR,
   ADM_TIMESTAMP,
   OS_TYPE,
   CCO_TRANSACTION_STATUS,
   CCO_TRANSACTION_TYPE,
   IS_POSTED_TO_CCO,
   IS_OBSOLETE,
   IMAGE_POSTING_TYPE_NAME
)
AS
   SELECT                                                    /*+ FIRST_ROWS */
         smr.major_release_number release,
            -- 03/24/2009     qkong   modified vw_image_feature_product per sabgopal's request (aathaval mgr)
            srn.z maintenance,
            srn.p mrenumber,
            srn.a ed_designator,
            srn.o ed_renumber,
            --, ED_NUM_PKG.ED_NUM_GEN(o)                                        ed_renumber_sort
            --, smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o  RELEASE_NUMBER
            release_number release_number,
            stt.train_type train_type,
            srt.release_type_name release_type_name,
            sds.deployment_status_name status,
            si.image_name image,
            si.image_id image_id,
            sip.individual_platform_name platform,
            sip.individual_platform_id individual_platform_id,
            spi.dram mindram,
            spi.min_flash minflash,
            sfsd.feature_set_desc featuredesc,
            sfsdr.feature_set_designator feature_designator,
            si.is_going_to_cco cco,
            si.cco_posted_time ccotime,
            spg.pcode_group_name platform_family,
            si.image_size_compressed imagesize,
            si.md5chksum md5chksum,
            NULL BUILD,
            si.image_build_time buildtime,
            NULL mfgtime,
            REPLACE (
               REPLACE (
                     REPLACE (smr.major_release_number, '.', '')
                  || '-'
                  || srn.z
                  || srn.p
                  || DECODE (srn.a, '', '', '.' || srn.a || srn.o),
                  '(',
                  '.'
               ),
               ')',
               ''
            )
               buildnum,
            NULL netboot,
            si.is_software_advisory swadvise,
            si.software_advisory_id software_advisory_id,
            NVL (si.is_deferred, 'N') deferral,
            si.deferral_id deferral_request_id,
            sp.pcode_main pcode_sys,
            sp.pcode_spare pcode_spr,
            GREATEST (spi.adm_timestamp,
                      si.adm_timestamp,
                      sp.adm_timestamp,
                      sfs.adm_timestamp,
                      sfsd.adm_timestamp,
                      sds.adm_timestamp,
                      srt.adm_timestamp,
                      stt.adm_timestamp)
               adm_timestamp,
            os_type_name os_type,
            cco_transaction_status cco_transaction_status,
            cco_transaction_type cco_transaction_type,
            is_posted_to_cco is_posted_to_cco,
            sppg.is_obsolete,
            image_posting_type_name
     FROM   shr_image si,
            shr_platform_image spi,
            shr_image_feature_set sifs,
            shr_pcode sp,
            shr_feature_set sfs,
            shr_feature_set_desc sfsd,
            shr_feature_set_designator sfsdr,
            shr_release_pcode_group srpg,
            shr_release_number srn,
            shr_platform_pcode_group sppg,
            shr_individual_platform sip,
            shr_pcode_group spg,
            shr_major_release smr,
            shr_deployment_status sds,
            shr_release_type srt,
            shr_train_type stt,
            shr_os_type os,
            cspr_image_posting_status cips,
            shr_image_posting_type sipt
    WHERE       si.release_number_id = srn.release_number_id
            AND srn.major_release_id = smr.major_release_id
            AND srn.deployment_status_id = sds.deployment_status_id
            AND srn.release_type_id = srt.release_type_id
            AND smr.train_type_id = stt.train_type_id
            AND si.image_id = spi.image_id
            AND si.image_id = cips.image_id(+)
            AND spi.individual_platform_id = sip.individual_platform_id
            AND sip.individual_platform_id = sppg.individual_platform_id
            AND sppg.pcode_group_id = spg.pcode_group_id
            AND si.image_id = sifs.image_id
            AND sifs.feature_set_id = sfs.feature_set_id
            AND sfs.feature_set_desc_id = sfsd.feature_set_desc_id
            AND sfs.feature_set_designator_id =
                  sfsdr.feature_set_designator_id
            -- (+)
            AND sifs.image_feature_set_id = sp.image_feature_set_id
            AND srpg.release_number_id = srn.release_number_id
            AND srpg.pcode_group_id = spg.pcode_group_id
            AND srpg.release_pcode_group_id = sp.release_pcode_group_id(+)
            AND si.image_posting_type_id = sipt.image_posting_type_id(+)
            AND sifs.adm_flag = 'V'
            AND si.adm_flag = 'V'
            AND sfs.adm_flag = 'V'
            AND spi.adm_flag = 'V'
            AND si.is_in_image_list = 'Y'
            AND spi.is_in_image_list = 'Y'
            AND os.os_type_id = smr.os_type_id
            -- 03/23/2009  This line below are for C3_Service metadata requirements
            AND os.os_type_id IN (1, 23)                  -- 'IOS' and 'CatOS'
            AND sp.pcode_main IS NOT NULL                         -- PCODE_SYS
            AND srn.z IS NOT NULL;
-- MAINTENANCE
-- FEATURE_DESIGNATOR
-- PLATFORM_FAMILY
-- PLATFORM
-- STATUS
-- DEFERRAL;


DROP SYNONYM C3_SERVICE.VW_IMAGE_FEATURE_PRODUCT_C3;

CREATE SYNONYM C3_SERVICE.VW_IMAGE_FEATURE_PRODUCT_C3 FOR SHR_RDA.VW_IMAGE_FEATURE_PRODUCT_C3;


GRANT SELECT ON SHR_RDA.VW_IMAGE_FEATURE_PRODUCT_C3 TO C3_SERVICE;

