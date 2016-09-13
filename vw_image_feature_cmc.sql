--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE FORCE VIEW SHR_RDA.VW_IMAGE_FEATURE_CMC
(
   IMAGE_ID,
   RELEASE_NUMBER,
   IMAGE_NAME,
   IMAGE,
   FEATURE_SET_DESC,
   IS_CCO_ORDERABLE,
   IS_MFG_ORDERABLE,
   IS_IN_IMAGE_LIST,
   LAST_UPDATED_DATE,
   PLATFORM,
   PLATFORM_FAMILY,
   OS_TYPE,
   RELEASE_NUMBER_ID,
   INDIVIDUAL_PLATFORM_ID,
   PCODE_SYS,
   PCODE_SPR
)
AS
   SELECT                                                    /*+ FIRST_ROWS */
         si .image_id,
            release_number,
            si.image_name image_name,
               si.image_name
            || '.'
            || REPLACE (smr.major_release_number, '.', '')
            || '-'
            || zabp
            || DECODE (A, '', '', '.' || A || O)
               image,
            sfsd.feature_set_desc,
            si.is_cco_orderable,
            si.is_mfg_orderable,
            si.is_in_image_list,
            GREATEST (spi.adm_timestamp,
                      si.adm_timestamp,
                      sp.adm_timestamp,
                      sfs.adm_timestamp,
                      sfsd.adm_timestamp)
               LAST_UPDATED_DATE,
            sip.individual_platform_name platform,
            spf.platform_family_name,
            os_type_name os_type,
            srn.release_number_id,
            sip.individual_platform_id,
            sp.pcode_main pcode_sys,
            sp.pcode_spare pcode_spr
     FROM   shr_image si,
            shr_platform_image spi,
            shr_image_feature_set sifs,
            shr_pcode sp,
            shr_feature_set sfs,
            shr_feature_set_desc sfsd,
            shr_feature_set_designator sfsdr,
            shr_release_pcode_group srpg,
            shr_release_number srn,
            --//shr_platform_pcode_group sppg,
            shr_individual_platform sip,
            shr_platform_family spf,
            shr_pcode_group spg,
            shr_major_release smr,
            shr_os_type os
    --//cspr_image_posting_status cips,
    --//shr_image_posting_type sipt
    WHERE       si.release_number_id = srn.release_number_id
            AND srn.major_release_id = smr.major_release_id
            AND si.image_id = spi.image_id
            --AND si.image_id = cips.image_id(+)
            AND spi.individual_platform_id = sip.individual_platform_id
            --AND sip.individual_platform_id = sppg.individual_platform_id
            --AND sppg.pcode_group_id = spg.pcode_group_id
            AND si.image_id = sifs.image_id
            AND sifs.feature_set_id = sfs.feature_set_id
            AND sfs.feature_set_desc_id = sfsd.feature_set_desc_id
            AND sfs.feature_set_designator_id =
                  sfsdr.feature_set_designator_id(+)
            AND sifs.image_feature_set_id = sp.image_feature_set_id
            AND srpg.release_number_id = srn.release_number_id
            AND srpg.pcode_group_id = spg.pcode_group_id
            AND srpg.release_pcode_group_id = sp.release_pcode_group_id(+)
            --AND si.image_posting_type_id = sipt.image_posting_type_id(+)
            AND spf.platform_family_id = sip.platform_family_id
            AND sifs.adm_flag = 'V'
            AND si.adm_flag = 'V'
            AND sfs.adm_flag = 'V'
            AND spi.adm_flag = 'V'
            AND si.is_in_image_list = 'Y'
            AND spi.is_in_image_list = 'Y'
            AND os.os_type_id = smr.os_type_id
            AND os_type_name IN ('IOS')
            AND srn.release_type_id IN (1, 5)
   UNION ALL
   SELECT                                                    /*+ FIRST_ROWS */
         si .image_id,
            srn.release_name release_number,
            si.image_name image_name,
            si.image_name image,
            si.image_description feature_set_desc,
            NULL is_cco_orderable,
            NULL is_mfg_orderable,
            NULL is_in_image_list,
            GREATEST (spi.adm_timestamp, si.adm_timestamp, sp.adm_timestamp)
               last_updated_date,
            sip.individual_platform_name platform,
            platform_family_name platform_family,
            os_type_name os_type,
            srn.release_number_id,
            sip.individual_platform_id,
            product_name pcode_sys,
            NULL pcode_spr
     FROM   cspr_image si,
            cspr_platform_image spi,
            cspr_release_number srn,
            iox_opus sp,
            shr_individual_platform sip,
            shr_platform_family spf,
            --shr_major_release smr,
            shr_os_type os
    WHERE       si.release_number_id = srn.release_number_id
            AND si.image_id = spi.image_id
            AND spi.individual_platform_id = sip.individual_platform_id
            AND sip.platform_family_id = spf.platform_family_id
            AND si.image_name = sp.file_name(+)
            AND si.adm_flag = 'V'
            AND spi.adm_flag = 'V'
            AND os.os_type_id = srn.os_type_id
            AND os_type_display_name = 'IOS XR'
   UNION ALL
   SELECT                                                    /*+ FIRST_ROWS */
         si .image_id,
            srn.release_name release_number,
            si.image_name image_name,
            si.image_name image,
            si.image_description feature_set_desc,
            NULL is_cco_orderable,
            NULL is_mfg_orderable,
            NULL is_in_image_list,
            GREATEST (si.adm_timestamp, adm_timestamp_sp) last_updated_date,
            individual_platform_name platform,
            platform_family_name platform_family,
            os_type_name os_type,
            srn.release_number_id,
            individual_platform_id,
            pcode_main pcode_sys,
            pcode_spare
     FROM   cspr_image si,
            cspr_release_number srn,
            (  SELECT   MAX (DECODE (sp.pcode_type, 'MAIN', pcode, NULL))
                           pcode_main,
                        MAX (DECODE (sp.pcode_type, 'SPARE', pcode, NULL))
                           pcode_spare,
                        spi.image_id,
                        sip.individual_platform_id,
                        platform_family_name,
                        sip.individual_platform_name,
                        MAX (GREATEST (spi.adm_timestamp, sp.adm_timestamp))
                           adm_timestamp_sp
                 FROM   cspr_platform_image spi,
                        cspr_pcode sp,
                        shr_individual_platform sip,
                        shr_platform_family spf
                WHERE   spi.image_id = sp.image_id
                        AND sip.individual_platform_id =
                              spi.individual_platform_id
                        AND spf.platform_family_id = sip.platform_family_id
                        AND spi.adm_flag = 'V'
                        AND spf.adm_flag = 'V'
                        AND sip.adm_flag = 'V'
             GROUP BY   spi.image_id,
                        sip.individual_platform_id,
                        platform_family_name,
                        sip.individual_platform_name) sp,
            shr_os_type os
    WHERE       si.release_number_id = srn.release_number_id
            AND si.image_id = sp.image_id(+)
            AND si.adm_flag = 'V'
            AND os.os_type_id = srn.os_type_id;

-- Grants from shr_rda to SRDA_TAC user
GRANT SELECT ON SHR_RDA.VW_IMAGE_FEATURE_CMC TO SRDA_TAC;

-- Create synonymm in SRDA_TAC user
CREATE SYNONYM SRDA_TAC.VW_IMAGE_FEATURE_CMC FOR SHR_RDA.VW_IMAGE_FEATURE_CMC;



